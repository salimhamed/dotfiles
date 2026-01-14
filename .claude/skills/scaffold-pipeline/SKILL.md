---
name: scaffold-pipeline
description: PySpark and Polars data pipeline patterns. Use when creating data processing jobs with Iceberg tables, partitioning, and incremental processing.
---

# Data Pipeline Scaffolding

## PySpark Job Entry Point

```python
# jobs/process_orders.py
import argparse
from datetime import date
from pyspark.sql import SparkSession

from transforms.orders import transform_orders
from io_utils.iceberg import read_iceberg, write_iceberg


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Process daily orders")
    parser.add_argument("--date", type=date.fromisoformat, required=True)
    parser.add_argument("--env", choices=["dev", "staging", "prod"], default="dev")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def get_spark_session(app_name: str, env: str) -> SparkSession:
    builder = (
        SparkSession.builder
        .appName(app_name)
        .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog")
        .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog")
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
    )

    if env == "dev":
        builder = builder.config("spark.sql.shuffle.partitions", "10")

    return builder.getOrCreate()


def main():
    args = parse_args()
    spark = get_spark_session(f"process_orders_{args.date}", args.env)

    try:
        # Read source data
        raw_orders = read_iceberg(spark, "raw.orders", filter_date=args.date)

        # Transform
        processed = transform_orders(raw_orders)

        # Write output
        if not args.dry_run:
            write_iceberg(
                df=processed,
                table="processed.orders",
                partition_by=["order_date"],
                mode="overwrite_partitions",
            )
            print(f"Wrote {processed.count()} records to processed.orders")
        else:
            processed.show(20)
            print(f"Dry run: would write {processed.count()} records")

    finally:
        spark.stop()


if __name__ == "__main__":
    main()
```

## Transform Module

```python
# transforms/orders.py
from pyspark.sql import DataFrame
from pyspark.sql import functions as F
from pyspark.sql.window import Window


def transform_orders(df: DataFrame) -> DataFrame:
    return (
        df
        .filter(F.col("status") != "cancelled")
        .withColumn("order_date", F.to_date("created_at"))
        .withColumn("total_amount", F.col("quantity") * F.col("unit_price"))
        .withColumn(
            "customer_order_rank",
            F.row_number().over(
                Window.partitionBy("customer_id").orderBy(F.desc("created_at"))
            )
        )
        .select(
            "order_id",
            "customer_id",
            "product_id",
            "order_date",
            "quantity",
            "unit_price",
            "total_amount",
            "customer_order_rank",
        )
    )


def aggregate_daily_orders(df: DataFrame) -> DataFrame:
    return (
        df
        .groupBy("order_date", "product_id")
        .agg(
            F.count("order_id").alias("order_count"),
            F.sum("quantity").alias("total_quantity"),
            F.sum("total_amount").alias("total_revenue"),
            F.countDistinct("customer_id").alias("unique_customers"),
        )
    )
```

## Iceberg I/O Utilities

```python
# io_utils/iceberg.py
from datetime import date
from pyspark.sql import SparkSession, DataFrame


def read_iceberg(
    spark: SparkSession,
    table: str,
    filter_date: date | None = None,
    catalog: str = "glue_catalog",
) -> DataFrame:
    full_table = f"{catalog}.{table}"
    df = spark.read.format("iceberg").load(full_table)

    if filter_date:
        df = df.filter(f"date = '{filter_date}'")

    return df


def write_iceberg(
    df: DataFrame,
    table: str,
    partition_by: list[str] | None = None,
    mode: str = "append",
    catalog: str = "glue_catalog",
) -> None:
    full_table = f"{catalog}.{table}"
    writer = df.write.format("iceberg")

    if partition_by:
        writer = writer.partitionBy(*partition_by)

    if mode == "overwrite_partitions":
        writer.option("overwrite-mode", "dynamic").mode("overwrite")
    else:
        writer.mode(mode)

    writer.saveAsTable(full_table)
```

## Polars Pipeline

```python
# pipelines/orders_polars.py
from pathlib import Path
from datetime import date
import polars as pl


def process_orders(
    input_path: Path,
    output_path: Path,
    process_date: date,
) -> pl.DataFrame:
    # Lazy evaluation for efficiency
    df = (
        pl.scan_parquet(input_path / "*.parquet")
        .filter(pl.col("order_date") == process_date)
        .filter(pl.col("status") != "cancelled")
        .with_columns([
            (pl.col("quantity") * pl.col("unit_price")).alias("total_amount"),
            pl.col("created_at").dt.date().alias("date"),
        ])
        .select([
            "order_id",
            "customer_id",
            "product_id",
            "date",
            "quantity",
            "unit_price",
            "total_amount",
        ])
    )

    # Materialize and write
    result = df.collect()
    result.write_parquet(
        output_path / f"date={process_date}" / "data.parquet",
        compression="zstd",
    )

    return result


def aggregate_orders(df: pl.DataFrame) -> pl.DataFrame:
    return (
        df
        .group_by("date", "product_id")
        .agg([
            pl.count("order_id").alias("order_count"),
            pl.sum("quantity").alias("total_quantity"),
            pl.sum("total_amount").alias("total_revenue"),
            pl.n_unique("customer_id").alias("unique_customers"),
        ])
        .sort("date", "product_id")
    )


def join_with_products(
    orders: pl.LazyFrame,
    products: pl.LazyFrame,
) -> pl.LazyFrame:
    return (
        orders
        .join(products, on="product_id", how="left")
        .with_columns([
            pl.col("category").fill_null("Unknown"),
        ])
    )
```

## Incremental Processing Pattern

```python
# pipelines/incremental.py
from datetime import date, timedelta
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F


def get_watermark(spark: SparkSession, table: str) -> date | None:
    try:
        df = spark.read.format("iceberg").load(f"glue_catalog.{table}")
        result = df.select(F.max("process_date")).collect()
        max_date = result[0][0]
        return max_date
    except Exception:
        return None


def process_incremental(
    spark: SparkSession,
    source_table: str,
    target_table: str,
    transform_fn,
    start_date: date | None = None,
    end_date: date | None = None,
) -> int:
    # Determine date range
    watermark = get_watermark(spark, target_table)
    process_start = start_date or (watermark + timedelta(days=1) if watermark else date(2020, 1, 1))
    process_end = end_date or date.today()

    if process_start > process_end:
        print(f"No new data to process (watermark: {watermark})")
        return 0

    # Read source data for date range
    source_df = (
        spark.read.format("iceberg").load(f"glue_catalog.{source_table}")
        .filter(F.col("date").between(process_start, process_end))
    )

    # Transform
    result_df = transform_fn(source_df)

    # Write with partition overwrite
    result_df.write.format("iceberg") \
        .option("overwrite-mode", "dynamic") \
        .mode("overwrite") \
        .partitionBy("date") \
        .saveAsTable(f"glue_catalog.{target_table}")

    count = result_df.count()
    print(f"Processed {count} records from {process_start} to {process_end}")
    return count
```

## Configuration Pattern

```python
# config/pipeline_config.py
from dataclasses import dataclass
from pathlib import Path
import yaml


@dataclass(frozen=True)
class SourceConfig:
    database: str
    table: str
    partition_column: str = "date"


@dataclass(frozen=True)
class TargetConfig:
    database: str
    table: str
    partition_by: tuple[str, ...] = ("date",)
    write_mode: str = "overwrite_partitions"


@dataclass(frozen=True)
class PipelineConfig:
    name: str
    source: SourceConfig
    target: TargetConfig
    spark_config: dict


def load_config(config_path: Path) -> PipelineConfig:
    with open(config_path) as f:
        raw = yaml.safe_load(f)

    return PipelineConfig(
        name=raw["name"],
        source=SourceConfig(**raw["source"]),
        target=TargetConfig(**raw["target"]),
        spark_config=raw.get("spark", {}),
    )
```

```yaml
# config/orders_pipeline.yaml
name: orders_pipeline
source:
  database: raw
  table: orders
  partition_column: order_date
target:
  database: processed
  table: orders_daily
  partition_by:
    - order_date
  write_mode: overwrite_partitions
spark:
  spark.sql.shuffle.partitions: 200
  spark.executor.memory: 4g
```

## File Structure

```
pipelines/
├── jobs/
│   └── process_orders.py    # Entry point scripts
├── transforms/
│   └── orders.py            # Transformation logic
├── io_utils/
│   ├── iceberg.py           # Iceberg read/write
│   └── s3.py                # S3 utilities
├── config/
│   ├── pipeline_config.py   # Config dataclasses
│   └── orders_pipeline.yaml # Pipeline config
└── tests/
    └── test_transforms.py   # Unit tests
```

## Testing Pattern

```python
# tests/test_transforms.py
import pytest
from pyspark.sql import SparkSession
from datetime import date

from transforms.orders import transform_orders, aggregate_daily_orders


@pytest.fixture(scope="session")
def spark():
    return (
        SparkSession.builder
        .master("local[2]")
        .appName("test")
        .getOrCreate()
    )


@pytest.fixture
def sample_orders(spark):
    data = [
        ("o1", "c1", "p1", 2, 10.0, "completed", "2024-01-15 10:00:00"),
        ("o2", "c1", "p2", 1, 20.0, "completed", "2024-01-15 11:00:00"),
        ("o3", "c2", "p1", 3, 10.0, "cancelled", "2024-01-15 12:00:00"),
    ]
    return spark.createDataFrame(
        data,
        ["order_id", "customer_id", "product_id", "quantity", "unit_price", "status", "created_at"]
    )


def test_transform_filters_cancelled(spark, sample_orders):
    result = transform_orders(sample_orders)
    assert result.count() == 2
    assert result.filter("order_id = 'o3'").count() == 0


def test_transform_calculates_total(spark, sample_orders):
    result = transform_orders(sample_orders)
    row = result.filter("order_id = 'o1'").collect()[0]
    assert row.total_amount == 20.0  # 2 * 10.0
```
