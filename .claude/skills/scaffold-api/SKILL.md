---
name: scaffold-api
description: FastAPI endpoint scaffolding patterns. Use when creating new API endpoints with routers, Pydantic models, and tests.
---

# FastAPI Endpoint Scaffolding

## Router Structure

```python
# src/api/routes/items.py
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.db import get_db
from src.api.schemas.items import (
    ItemCreate,
    ItemUpdate,
    ItemResponse,
    ItemListResponse,
)
from src.services.items import ItemService

router = APIRouter(prefix="/items", tags=["items"])

DB = Annotated[AsyncSession, Depends(get_db)]


@router.get("", response_model=ItemListResponse)
async def list_items(
    db: DB,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
) -> ItemListResponse:
    service = ItemService(db)
    items = await service.list(skip=skip, limit=limit)
    total = await service.count()
    return ItemListResponse(items=items, total=total, skip=skip, limit=limit)


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(item_id: str, db: DB) -> ItemResponse:
    service = ItemService(db)
    item = await service.get(item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
    return item


@router.post("", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(data: ItemCreate, db: DB) -> ItemResponse:
    service = ItemService(db)
    return await service.create(data)


@router.patch("/{item_id}", response_model=ItemResponse)
async def update_item(item_id: str, data: ItemUpdate, db: DB) -> ItemResponse:
    service = ItemService(db)
    item = await service.update(item_id, data)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
    return item


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(item_id: str, db: DB) -> None:
    service = ItemService(db)
    deleted = await service.delete(item_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
```

## Pydantic Schemas

```python
# src/api/schemas/items.py
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict


class ItemBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: str | None = Field(None, max_length=500)
    price: float = Field(..., gt=0)
    is_active: bool = True


class ItemCreate(ItemBase):
    pass


class ItemUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str | None = Field(None, min_length=1, max_length=100)
    description: str | None = Field(None, max_length=500)
    price: float | None = Field(None, gt=0)
    is_active: bool | None = None


class ItemResponse(ItemBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    created_at: datetime
    updated_at: datetime


class ItemListResponse(BaseModel):
    items: list[ItemResponse]
    total: int
    skip: int
    limit: int
```

## Service Layer

```python
# src/services/items.py
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Item
from src.api.schemas.items import ItemCreate, ItemUpdate


class ItemService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get(self, item_id: str) -> Item | None:
        result = await self.db.execute(select(Item).where(Item.id == item_id))
        return result.scalar_one_or_none()

    async def list(self, skip: int = 0, limit: int = 20) -> list[Item]:
        result = await self.db.execute(
            select(Item).offset(skip).limit(limit).order_by(Item.created_at.desc())
        )
        return list(result.scalars().all())

    async def count(self) -> int:
        result = await self.db.execute(select(func.count(Item.id)))
        return result.scalar_one()

    async def create(self, data: ItemCreate) -> Item:
        item = Item(**data.model_dump())
        self.db.add(item)
        await self.db.commit()
        await self.db.refresh(item)
        return item

    async def update(self, item_id: str, data: ItemUpdate) -> Item | None:
        item = await self.get(item_id)
        if not item:
            return None
        for key, value in data.model_dump(exclude_unset=True).items():
            setattr(item, key, value)
        await self.db.commit()
        await self.db.refresh(item)
        return item

    async def delete(self, item_id: str) -> bool:
        item = await self.get(item_id)
        if not item:
            return False
        await self.db.delete(item)
        await self.db.commit()
        return True
```

## Test File

```python
# tests/api/test_items.py
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Item


@pytest.fixture
async def sample_item(db: AsyncSession) -> Item:
    item = Item(name="Test Item", description="A test item", price=9.99)
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


class TestListItems:
    async def test_list_empty(self, client: AsyncClient):
        response = await client.get("/items")
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
        assert data["total"] == 0

    async def test_list_with_items(self, client: AsyncClient, sample_item: Item):
        response = await client.get("/items")
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 1
        assert data["items"][0]["id"] == sample_item.id

    async def test_list_pagination(self, client: AsyncClient):
        response = await client.get("/items", params={"skip": 0, "limit": 10})
        assert response.status_code == 200


class TestGetItem:
    async def test_get_existing(self, client: AsyncClient, sample_item: Item):
        response = await client.get(f"/items/{sample_item.id}")
        assert response.status_code == 200
        assert response.json()["name"] == sample_item.name

    async def test_get_not_found(self, client: AsyncClient):
        response = await client.get("/items/nonexistent-id")
        assert response.status_code == 404


class TestCreateItem:
    async def test_create_valid(self, client: AsyncClient):
        response = await client.post(
            "/items",
            json={"name": "New Item", "price": 19.99},
        )
        assert response.status_code == 201
        assert response.json()["name"] == "New Item"

    async def test_create_invalid(self, client: AsyncClient):
        response = await client.post("/items", json={"name": ""})
        assert response.status_code == 422


class TestUpdateItem:
    async def test_update_partial(self, client: AsyncClient, sample_item: Item):
        response = await client.patch(
            f"/items/{sample_item.id}",
            json={"name": "Updated Name"},
        )
        assert response.status_code == 200
        assert response.json()["name"] == "Updated Name"

    async def test_update_not_found(self, client: AsyncClient):
        response = await client.patch("/items/nonexistent", json={"name": "X"})
        assert response.status_code == 404


class TestDeleteItem:
    async def test_delete_existing(self, client: AsyncClient, sample_item: Item):
        response = await client.delete(f"/items/{sample_item.id}")
        assert response.status_code == 204

    async def test_delete_not_found(self, client: AsyncClient):
        response = await client.delete("/items/nonexistent")
        assert response.status_code == 404
```

## Test Fixtures

```python
# tests/conftest.py
import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from src.main import app
from src.db import get_db, Base

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"


@pytest.fixture(scope="session")
def anyio_backend():
    return "asyncio"


@pytest.fixture
async def db():
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        yield session

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
async def client(db: AsyncSession):
    def override_get_db():
        return db

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client
    app.dependency_overrides.clear()
```

## File Structure

```
src/
├── api/
│   ├── routes/
│   │   └── items.py      # Router with endpoints
│   └── schemas/
│       └── items.py      # Pydantic models
├── services/
│   └── items.py          # Business logic
└── db/
    └── models.py         # SQLAlchemy models

tests/
├── api/
│   └── test_items.py     # API tests
└── conftest.py           # Shared fixtures
```
