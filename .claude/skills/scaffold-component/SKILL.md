---
name: scaffold-component
description: React component scaffolding patterns. Use when creating new React components with TypeScript, hooks, tests, and Ant Design integration.
---

# React Component Scaffolding

## Basic Component

```tsx
// src/components/UserCard/UserCard.tsx
import { memo } from 'react';
import { Card, Avatar, Typography, Space } from 'antd';
import { UserOutlined } from '@ant-design/icons';

const { Text, Title } = Typography;

export interface UserCardProps {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string;
  role?: 'admin' | 'user' | 'guest';
  onClick?: (id: string) => void;
}

export const UserCard = memo(function UserCard({
  id,
  name,
  email,
  avatarUrl,
  role = 'user',
  onClick,
}: UserCardProps) {
  const handleClick = () => {
    onClick?.(id);
  };

  return (
    <Card
      hoverable={!!onClick}
      onClick={onClick ? handleClick : undefined}
      style={{ width: 300 }}
    >
      <Space direction="vertical" align="center" style={{ width: '100%' }}>
        <Avatar
          size={64}
          src={avatarUrl}
          icon={!avatarUrl && <UserOutlined />}
        />
        <Title level={5} style={{ margin: 0 }}>
          {name}
        </Title>
        <Text type="secondary">{email}</Text>
        <Text code>{role}</Text>
      </Space>
    </Card>
  );
});
```

## Component with Data Fetching

```tsx
// src/components/UserList/UserList.tsx
import { useState, useCallback } from 'react';
import { Table, Button, Space, message, Input } from 'antd';
import { PlusOutlined, SearchOutlined } from '@ant-design/icons';
import type { ColumnsType, TablePaginationConfig } from 'antd/es/table';

import { useUsers } from '@/hooks/useUsers';
import { User } from '@/types/user';

interface UserListProps {
  onSelect?: (user: User) => void;
  onAdd?: () => void;
}

export function UserList({ onSelect, onAdd }: UserListProps) {
  const [search, setSearch] = useState('');
  const [pagination, setPagination] = useState<TablePaginationConfig>({
    current: 1,
    pageSize: 10,
  });

  const { data, loading, error, refetch } = useUsers({
    search,
    page: pagination.current ?? 1,
    limit: pagination.pageSize ?? 10,
  });

  const handleTableChange = useCallback((newPagination: TablePaginationConfig) => {
    setPagination(newPagination);
  }, []);

  const columns: ColumnsType<User> = [
    {
      title: 'Name',
      dataIndex: 'name',
      sorter: (a, b) => a.name.localeCompare(b.name),
    },
    {
      title: 'Email',
      dataIndex: 'email',
    },
    {
      title: 'Role',
      dataIndex: 'role',
      filters: [
        { text: 'Admin', value: 'admin' },
        { text: 'User', value: 'user' },
      ],
      onFilter: (value, record) => record.role === value,
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_, record) => (
        <Button type="link" onClick={() => onSelect?.(record)}>
          View
        </Button>
      ),
    },
  ];

  if (error) {
    message.error('Failed to load users');
  }

  return (
    <Space direction="vertical" style={{ width: '100%' }}>
      <Space>
        <Input
          placeholder="Search users..."
          prefix={<SearchOutlined />}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ width: 200 }}
        />
        {onAdd && (
          <Button type="primary" icon={<PlusOutlined />} onClick={onAdd}>
            Add User
          </Button>
        )}
      </Space>

      <Table
        columns={columns}
        dataSource={data?.users}
        rowKey="id"
        loading={loading}
        pagination={{
          ...pagination,
          total: data?.total,
          showSizeChanger: true,
          showTotal: (total) => `Total ${total} users`,
        }}
        onChange={handleTableChange}
      />
    </Space>
  );
}
```

## Custom Hook

```tsx
// src/hooks/useUsers.ts
import { useState, useEffect, useCallback, useRef } from 'react';
import { userService, User, UserListParams } from '@/services/userService';

interface UseUsersResult {
  data: { users: User[]; total: number } | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

export function useUsers(params: UserListParams): UseUsersResult {
  const [data, setData] = useState<{ users: User[]; total: number } | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
    };
  }, []);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await userService.list(params);
      if (mountedRef.current) {
        setData(result);
      }
    } catch (err) {
      if (mountedRef.current) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      }
    } finally {
      if (mountedRef.current) {
        setLoading(false);
      }
    }
  }, [params.search, params.page, params.limit]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  return { data, loading, error, refetch: fetchUsers };
}
```

## Test File

```tsx
// src/components/UserCard/UserCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';

import { UserCard, UserCardProps } from './UserCard';

const defaultProps: UserCardProps = {
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  role: 'user',
};

describe('UserCard', () => {
  it('renders user information', () => {
    render(<UserCard {...defaultProps} />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('user')).toBeInTheDocument();
  });

  it('renders avatar with image when provided', () => {
    render(<UserCard {...defaultProps} avatarUrl="https://example.com/avatar.jpg" />);

    const avatar = screen.getByRole('img');
    expect(avatar).toHaveAttribute('src', 'https://example.com/avatar.jpg');
  });

  it('calls onClick with id when clicked', () => {
    const handleClick = vi.fn();
    render(<UserCard {...defaultProps} onClick={handleClick} />);

    fireEvent.click(screen.getByText('John Doe').closest('.ant-card')!);
    expect(handleClick).toHaveBeenCalledWith('1');
  });

  it('is not clickable when onClick is not provided', () => {
    render(<UserCard {...defaultProps} />);

    const card = screen.getByText('John Doe').closest('.ant-card');
    expect(card).not.toHaveClass('ant-card-hoverable');
  });
});
```

## Storybook Story

```tsx
// src/components/UserCard/UserCard.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { fn } from '@storybook/test';

import { UserCard } from './UserCard';

const meta: Meta<typeof UserCard> = {
  title: 'Components/UserCard',
  component: UserCard,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
  args: {
    onClick: fn(),
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'user',
  },
};

export const WithAvatar: Story = {
  args: {
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    role: 'admin',
    avatarUrl: 'https://i.pravatar.cc/150?u=jane',
  },
};

export const NonClickable: Story = {
  args: {
    id: '3',
    name: 'Guest User',
    email: 'guest@example.com',
    role: 'guest',
    onClick: undefined,
  },
};
```

## Index Export

```tsx
// src/components/UserCard/index.ts
export { UserCard } from './UserCard';
export type { UserCardProps } from './UserCard';
```

## File Structure

```
src/components/UserCard/
├── UserCard.tsx           # Main component
├── UserCard.test.tsx      # Unit tests
├── UserCard.stories.tsx   # Storybook stories (optional)
└── index.ts               # Barrel export

src/hooks/
└── useUsers.ts            # Data fetching hook

src/services/
└── userService.ts         # API service
```

## Form Component Pattern

```tsx
// src/components/UserForm/UserForm.tsx
import { Form, Input, Select, Button, message } from 'antd';
import type { Rule } from 'antd/es/form';

export interface UserFormValues {
  name: string;
  email: string;
  role: 'admin' | 'user';
}

interface UserFormProps {
  initialValues?: Partial<UserFormValues>;
  onSubmit: (values: UserFormValues) => Promise<void>;
  onCancel?: () => void;
  loading?: boolean;
}

const rules: Record<keyof UserFormValues, Rule[]> = {
  name: [
    { required: true, message: 'Name is required' },
    { min: 2, message: 'Name must be at least 2 characters' },
  ],
  email: [
    { required: true, message: 'Email is required' },
    { type: 'email', message: 'Please enter a valid email' },
  ],
  role: [{ required: true, message: 'Role is required' }],
};

export function UserForm({
  initialValues,
  onSubmit,
  onCancel,
  loading,
}: UserFormProps) {
  const [form] = Form.useForm<UserFormValues>();

  const handleFinish = async (values: UserFormValues) => {
    try {
      await onSubmit(values);
      form.resetFields();
      message.success('User saved successfully');
    } catch {
      message.error('Failed to save user');
    }
  };

  return (
    <Form
      form={form}
      layout="vertical"
      initialValues={initialValues}
      onFinish={handleFinish}
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
          Save
        </Button>
        {onCancel && (
          <Button onClick={onCancel} style={{ marginLeft: 8 }}>
            Cancel
          </Button>
        )}
      </Form.Item>
    </Form>
  );
}
```
