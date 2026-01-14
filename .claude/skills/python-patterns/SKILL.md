---
name: python-patterns
description: Python development patterns for data engineering and API development. Use when writing Python code, especially for data processing with Polars/PySpark, async operations, or FastAPI endpoints.
---

# Python Patterns

## Polars over Pandas

```python
# Polars - lazy evaluation, better performance
import polars as pl

df = (
    pl.scan_parquet("data/*.parquet")
    .filter(pl.col("date") >= "2024-01-01")
    .group_by("category")
    .agg([
        pl.col("amount").sum().alias("total"),
        pl.col("id").n_unique().alias("unique_ids")
    ])
    .collect()
)

# Pandas - eager, memory issues with large data
import pandas as pd
df = pd.read_parquet("data/")  # Loads everything into memory
```

## Type Hints

```python
# Full type hints with modern syntax (Python 3.10+)
from collections.abc import Callable, Iterable, Sequence

def process_items[T, R](
    items: Iterable[T],
    transform: Callable[[T], R],
    batch_size: int = 100
) -> list[R]:
    results: list[R] = []
    for batch in batched(items, batch_size):
        results.extend(transform(item) for item in batch)
    return results
```

## Async Patterns

```python
# Concurrent execution with proper error handling
import asyncio
from httpx import AsyncClient

async def fetch_all(urls: list[str]) -> list[dict]:
    async with AsyncClient(timeout=30.0) as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return [
            r.json() if not isinstance(r, Exception) else {"error": str(r), "url": url}
            for r, url in zip(responses, urls)
        ]

# Semaphore for rate limiting
async def fetch_with_limit(urls: list[str], max_concurrent: int = 10):
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch_one(url: str):
        async with semaphore:
            async with AsyncClient() as client:
                return await client.get(url)

    return await asyncio.gather(*[fetch_one(url) for url in urls])
```

## FastAPI Patterns

```python
# Dependency injection with proper typing
from typing import Annotated
from collections.abc import AsyncGenerator
from fastapi import Depends, HTTPException, status

async def get_db() -> AsyncGenerator[Database, None]:
    db = await Database.connect()
    try:
        yield db
    finally:
        await db.close()

DB = Annotated[Database, Depends(get_db)]

@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: str, db: DB) -> Item:
    item = await db.items.get(item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found"
        )
    return item
```

## Pydantic Models

```python
# Pydantic v2 patterns
from pydantic import BaseModel, Field, field_validator, ConfigDict

class OrderRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    product_id: str = Field(..., pattern=r"^PROD-\d{6}$")
    quantity: int = Field(..., ge=1, le=100)
    notes: str | None = Field(None, max_length=500)

    @field_validator("product_id")
    @classmethod
    def validate_product_id(cls, v: str) -> str:
        return v.upper()
```

## Dataclasses for Internal Data

```python
# Frozen dataclasses for immutable internal data
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True, slots=True)
class OrderResult:
    order_id: str
    status: str
    items: tuple[str, ...]  # Use tuple for immutability
    created_at: datetime = field(default_factory=datetime.now)
```

## Error Handling

```python
# Specific exceptions with context
class OrderError(Exception):
    def __init__(self, order_id: str, message: str):
        self.order_id = order_id
        super().__init__(f"Order {order_id}: {message}")

class InsufficientInventory(OrderError):
    def __init__(self, order_id: str, product_id: str, available: int, requested: int):
        self.product_id = product_id
        self.available = available
        self.requested = requested
        super().__init__(
            order_id,
            f"Need {requested} of {product_id}, only {available} available"
        )
```

## Context Efficiency Pattern

When processing data, return summaries instead of raw data:

```python
# Process and summarize - return only what's needed
from collections import Counter
from pathlib import Path

def analyze_logs(log_dir: Path) -> dict:
    errors = []
    for log_file in log_dir.glob("*.log"):
        content = log_file.read_text()
        errors.extend(parse_errors(content))

    return {
        "total_errors": len(errors),
        "by_type": dict(Counter(e.type for e in errors)),
        "critical": [
            {"file": e.file, "line": e.line, "message": e.message}
            for e in errors if e.severity == "critical"
        ][:10]  # Limit output
    }

# Don't return raw log contents
```
