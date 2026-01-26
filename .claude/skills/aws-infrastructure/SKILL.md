---
name: aws-infrastructure
description: AWS infrastructure patterns for data engineering. Use when working with EMR Serverless, Glue, Athena, CDK, or Iceberg tables.
---

# AWS Infrastructure Patterns

## EMR Serverless Job Submission

```python
# Standard PySpark job with monitoring
import boto3
from datetime import datetime

def submit_emr_job(
    app_id: str,
    role_arn: str,
    script_path: str,
    args: list[str] | None = None,
    spark_config: dict | None = None,
) -> str:
    client = boto3.client("emr-serverless")

    # Default Spark configuration
    default_config = {
        "spark.executor.memory": "4G",
        "spark.executor.cores": "2",
        "spark.dynamicAllocation.enabled": "true",
        "spark.dynamicAllocation.minExecutors": "1",
        "spark.dynamicAllocation.maxExecutors": "10",
    }
    config = {**default_config, **(spark_config or {})}

    spark_params = " ".join(f"--conf {k}={v}" for k, v in config.items())

    response = client.start_job_run(
        applicationId=app_id,
        executionRoleArn=role_arn,
        jobDriver={
            "sparkSubmit": {
                "entryPoint": script_path,
                "entryPointArguments": args or [],
                "sparkSubmitParameters": spark_params,
            }
        },
        configurationOverrides={
            "monitoringConfiguration": {
                "s3MonitoringConfiguration": {
                    "logUri": f"s3://logs-bucket/emr/{datetime.now():%Y/%m/%d}/"
                }
            }
        },
        tags={"submitted_at": datetime.now().isoformat()},
    )

    return response["jobRunId"]
```

## Iceberg Table Operations

```python
# Spark session with Iceberg and Glue catalog
from pyspark.sql import SparkSession

def get_spark_session(app_name: str = "iceberg-app") -> SparkSession:
    return SparkSession.builder \
        .appName(app_name) \
        .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.glue_catalog.warehouse", "s3://warehouse-bucket/") \
        .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .getOrCreate()

# Reading with partition pruning (happens automatically)
spark = get_spark_session()
df = spark.read.format("iceberg") \
    .load("glue_catalog.database.my_table") \
    .filter("date >= '2024-01-01' AND region = 'us-west-2'")

# MERGE INTO for upserts
spark.sql("""
    MERGE INTO glue_catalog.database.target t
    USING glue_catalog.database.updates u
    ON t.id = u.id
    WHEN MATCHED THEN UPDATE SET *
    WHEN NOT MATCHED THEN INSERT *
""")

# Table maintenance
spark.sql("CALL glue_catalog.system.expire_snapshots('db.table', TIMESTAMP '2024-01-01 00:00:00')")
spark.sql("CALL glue_catalog.system.rewrite_data_files('db.table')")
spark.sql("CALL glue_catalog.system.rewrite_manifests('db.table')")
```

## Athena Async Queries

```python
# Athena query execution with pagination
import boto3
from typing import Iterator

def run_athena_query(
    query: str,
    database: str,
    output_location: str,
    timeout: int = 300,
) -> str:
    athena = boto3.client("athena")

    response = athena.start_query_execution(
        QueryString=query,
        QueryExecutionContext={"Database": database},
        ResultConfiguration={"OutputLocation": output_location},
    )

    execution_id = response["QueryExecutionId"]

    # Wait for completion
    import time
    start = time.time()
    while True:
        result = athena.get_query_execution(QueryExecutionId=execution_id)
        state = result["QueryExecution"]["Status"]["State"]

        if state == "SUCCEEDED":
            return execution_id
        elif state in ("FAILED", "CANCELLED"):
            reason = result["QueryExecution"]["Status"].get("StateChangeReason", "Unknown")
            raise Exception(f"Query {state}: {reason}")

        if time.time() - start > timeout:
            athena.stop_query_execution(QueryExecutionId=execution_id)
            raise TimeoutError(f"Query timed out after {timeout}s")

        time.sleep(2)

def get_athena_results(execution_id: str) -> Iterator[dict]:
    athena = boto3.client("athena")
    paginator = athena.get_paginator("get_query_results")

    columns = None
    for page in paginator.paginate(QueryExecutionId=execution_id):
        result_set = page["ResultSet"]

        if columns is None:
            columns = [col["Name"] for col in result_set["ResultSetMetadata"]["ColumnInfo"]]
            rows = result_set["Rows"][1:]  # Skip header
        else:
            rows = result_set["Rows"]

        for row in rows:
            values = [field.get("VarCharValue") for field in row["Data"]]
            yield dict(zip(columns, values))
```

## CDK Stack Pattern

```python
# Well-structured CDK stack
from aws_cdk import (
    Stack,
    RemovalPolicy,
    Tags,
    Duration,
    aws_s3 as s3,
    aws_glue as glue,
    aws_iam as iam,
    aws_lambda as lambda_,
)
from constructs import Construct

class DataPipelineStack(Stack):
    def __init__(
        self,
        scope: Construct,
        id: str,
        env_name: str,
        **kwargs
    ) -> None:
        super().__init__(scope, id, **kwargs)

        prefix = f"{env_name}-pipeline"

        # Data bucket with lifecycle rules
        self.data_bucket = s3.Bucket(
            self, "DataBucket",
            bucket_name=f"{prefix}-data-{self.account}",
            removal_policy=RemovalPolicy.RETAIN,
            versioned=True,
            encryption=s3.BucketEncryption.S3_MANAGED,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            lifecycle_rules=[
                s3.LifecycleRule(
                    id="archive-old-data",
                    transitions=[
                        s3.Transition(
                            storage_class=s3.StorageClass.INTELLIGENT_TIERING,
                            transition_after=Duration.days(90),
                        )
                    ],
                ),
            ],
        )

        # Glue database
        self.database = glue.CfnDatabase(
            self, "Database",
            catalog_id=self.account,
            database_input=glue.CfnDatabase.DatabaseInputProperty(
                name=f"{prefix.replace('-', '_')}_db",
                description=f"Database for {env_name} data pipeline",
            ),
        )

        # Apply standard tags
        Tags.of(self).add("Environment", env_name)
        Tags.of(self).add("Project", "DataPipeline")
        Tags.of(self).add("ManagedBy", "CDK")
```
