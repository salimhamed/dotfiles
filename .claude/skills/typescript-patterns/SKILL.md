---
name: typescript-patterns
description: TypeScript and React patterns for frontend development. Use when writing React components, hooks, or TypeScript utilities, especially with Ant Design.
---

# TypeScript Patterns

## React Component Structure

```tsx
// Well-structured component with proper typing
import { useState, useCallback, useMemo } from 'react';
import { Table, Button, Space, message } from 'antd';
import type { ColumnsType } from 'antd/es/table';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

interface UserTableProps {
  users: User[];
  onDelete?: (userId: string) => Promise<void>;
  loading?: boolean;
}

export function UserTable({
  users,
  onDelete,
  loading = false
}: UserTableProps) {
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleDelete = useCallback(async (userId: string) => {
    if (!onDelete) return;

    setDeletingId(userId);
    try {
      await onDelete(userId);
      message.success('User deleted');
    } catch (error) {
      message.error('Failed to delete user');
    } finally {
      setDeletingId(null);
    }
  }, [onDelete]);

  const columns = useMemo<ColumnsType<User>>(() => [
    {
      title: 'Name',
      dataIndex: 'name',
      sorter: (a, b) => a.name.localeCompare(b.name)
    },
    { title: 'Email', dataIndex: 'email' },
    {
      title: 'Role',
      dataIndex: 'role',
      filters: [
        { text: 'Admin', value: 'admin' },
        { text: 'User', value: 'user' },
        { text: 'Guest', value: 'guest' },
      ],
      onFilter: (value, record) => record.role === value,
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_, record) => (
        <Space>
          <Button
            danger
            size="small"
            loading={deletingId === record.id}
            onClick={() => handleDelete(record.id)}
            disabled={!onDelete}
          >
            Delete
          </Button>
        </Space>
      ),
    },
  ], [deletingId, handleDelete, onDelete]);

  return (
    <Table
      columns={columns}
      dataSource={users}
      rowKey="id"
      loading={loading}
      pagination={{ pageSize: 10 }}
    />
  );
}
```

## Custom Hooks

```tsx
// Data fetching hook with proper state management
import { useState, useEffect, useCallback, useRef } from 'react';

interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

interface UseAsyncResult<T> extends AsyncState<T> {
  refetch: () => Promise<void>;
}

export function useAsync<T>(
  asyncFn: () => Promise<T>,
  deps: unknown[] = []
): UseAsyncResult<T> {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  // Track if component is mounted
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    return () => { mountedRef.current = false; };
  }, []);

  const execute = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    try {
      const data = await asyncFn();
      if (mountedRef.current) {
        setState({ data, loading: false, error: null });
      }
    } catch (error) {
      if (mountedRef.current) {
        setState({ data: null, loading: false, error: error as Error });
      }
    }
  }, deps);

  useEffect(() => {
    execute();
  }, [execute]);

  return { ...state, refetch: execute };
}
```

## Type Utilities

```typescript
// Useful type helpers
type Nullable<T> = T | null | undefined;

type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

type AsyncReturnType<T extends (...args: unknown[]) => Promise<unknown>> =
  T extends (...args: unknown[]) => Promise<infer R> ? R : never;

// Discriminated unions for results
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function isSuccess<T, E>(result: Result<T, E>): result is { success: true; data: T } {
  return result.success;
}

// Exhaustive switch helper
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}
```

## Ant Design Form Patterns

```tsx
// Typed form with validation
import { Form, Input, Select, Button, message } from 'antd';
import type { Rule } from 'antd/es/form';

interface CreateUserForm {
  name: string;
  email: string;
  role: 'admin' | 'user';
}

const rules: Record<keyof CreateUserForm, Rule[]> = {
  name: [
    { required: true, message: 'Name is required' },
    { min: 2, message: 'Name must be at least 2 characters' },
    { max: 50, message: 'Name must be at most 50 characters' },
  ],
  email: [
    { required: true, message: 'Email is required' },
    { type: 'email', message: 'Please enter a valid email' },
  ],
  role: [{ required: true, message: 'Role is required' }],
};

interface CreateUserFormProps {
  onSubmit: (values: CreateUserForm) => Promise<void>;
  initialValues?: Partial<CreateUserForm>;
}

export function CreateUserForm({ onSubmit, initialValues }: CreateUserFormProps) {
  const [form] = Form.useForm<CreateUserForm>();
  const [loading, setLoading] = useState(false);

  const handleFinish = async (values: CreateUserForm) => {
    setLoading(true);
    try {
      await onSubmit(values);
      form.resetFields();
      message.success('User created successfully');
    } catch (error) {
      message.error('Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form
      form={form}
      layout="vertical"
      onFinish={handleFinish}
      initialValues={initialValues}
    >
      <Form.Item name="name" label="Name" rules={rules.name}>
        <Input placeholder="Enter name" />
      </Form.Item>

      <Form.Item name="email" label="Email" rules={rules.email}>
        <Input type="email" placeholder="Enter email" />
      </Form.Item>

      <Form.Item name="role" label="Role" rules={rules.role}>
        <Select
          placeholder="Select role"
          options={[
            { label: 'Admin', value: 'admin' },
            { label: 'User', value: 'user' },
          ]}
        />
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit" loading={loading}>
          Create User
        </Button>
      </Form.Item>
    </Form>
  );
}
```

## API Service Pattern

```typescript
// Type-safe API service
const API_BASE = '/api/v1';

async function fetchJSON<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.message || `HTTP ${response.status}`);
  }

  return response.json();
}

// Usage
interface User {
  id: string;
  name: string;
}

const userService = {
  list: () => fetchJSON<User[]>('/users'),
  get: (id: string) => fetchJSON<User>(`/users/${id}`),
  create: (data: Omit<User, 'id'>) =>
    fetchJSON<User>('/users', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
};
```
