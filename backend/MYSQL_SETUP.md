# MySQL 8.0 配置指南

本项目已从 SQLite 迁移到 MySQL 8.0。请按照以下步骤配置数据库。

## 前置要求

1. 安装 MySQL 8.0 或更高版本
2. 确保 MySQL 服务正在运行

## 数据库设置

### 1. 创建数据库

连接到 MySQL 服务器并创建数据库：

```bash
mysql -u root -p
```

在 MySQL 命令行中执行：

```sql
CREATE DATABASE opencoreui CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. 创建数据库用户（推荐）

为了安全起见，建议创建专门的数据库用户：

```sql
CREATE USER 'opencoreui'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON opencoreui.* TO 'opencoreui'@'localhost';
FLUSH PRIVILEGES;
```

### 3. 配置环境变量

在项目根目录创建 `.env` 文件或设置环境变量：

```bash
# MySQL 连接配置
DATABASE_URL=mysql://opencoreui:your_secure_password@localhost:3306/opencoreui

# 连接池配置（可选）
DATABASE_POOL_SIZE=10
DATABASE_POOL_MAX_OVERFLOW=10
DATABASE_POOL_TIMEOUT=30
DATABASE_POOL_RECYCLE=3600
```

### 4. 默认配置

如果未设置 `DATABASE_URL` 环境变量，应用将使用以下默认连接：

```
mysql://root:password@localhost:3306/opencoreui
```

**注意**：默认配置仅用于开发环境，生产环境请务必设置正确的环境变量。

## 数据库迁移

应用启动时会自动执行数据库迁移，创建所有必需的表和索引。

## 从 SQLite 迁移数据（可选）

如果您之前使用 SQLite 并需要迁移数据，可以使用以下工具：

1. **使用 MySQL Workbench**
   - 导入 SQLite 数据库
   - 导出到 MySQL

2. **使用命令行工具**
   ```bash
   # 从 SQLite 导出数据
   sqlite3 data.sqlite3 .dump > data.sql

   # 编辑 data.sql 文件，调整语法差异
   # 导入到 MySQL
   mysql -u opencoreui -p opencoreui < data.sql
   ```

## 依赖变更

项目依赖已更新：

- **Cargo.toml**: sqlx features 从 `"sqlite"` 改为 `"mysql"`
- **数据库驱动**: 使用 `sqlx-mysql` 而非 `sqlx-sqlite`

## 数据类型映射

SQLite 到 MySQL 的类型映射：

| SQLite | MySQL 8.0 |
|--------|-----------|
| TEXT | VARCHAR(255) / TEXT |
| INTEGER (时间戳) | BIGINT |
| INTEGER (布尔) | TINYINT |
| INTEGER PRIMARY KEY AUTOINCREMENT | INT AUTO_INCREMENT PRIMARY KEY |

## 表特性

所有表使用：
- **存储引擎**: InnoDB（支持事务和外键）
- **字符集**: utf8mb4
- **排序规则**: utf8mb4_unicode_ci（支持完整 Unicode，包括表情符号）

## 验证安装

启动应用后，检查日志输出：

```
Initializing database schema
Database schema initialization completed
```

如果出现错误，请检查：
1. MySQL 服务是否运行
2. 数据库连接字符串是否正确
3. 用户权限是否足够
4. 数据库是否已创建

## 性能优化建议

1. **连接池配置**: 根据应用负载调整连接池大小
2. **索引优化**: 已为常用查询字段创建索引
3. **慢查询日志**: 启用 MySQL 慢查询日志监控性能
4. **定期维护**: 使用 `OPTIMIZE TABLE` 优化表结构

## 故障排查

### 连接失败

```
Error: failed to connect to MySQL
```

**解决方法**:
- 检查 MySQL 服务状态: `systemctl status mysql` (Linux) 或 `services.msc` (Windows)
- 验证连接字符串格式
- 确认防火墙设置

### 权限错误

```
Error: Access denied for user
```

**解决方法**:
- 验证用户名和密码
- 检查用户权限: `SHOW GRANTS FOR 'opencoreui'@'localhost';`

### 字符集问题

```
Error: Incorrect string value
```

**解决方法**:
- 确保数据库使用 utf8mb4 字符集
- 检查连接字符串是否包含字符集参数

## 技术支持

如有问题，请查看：
- MySQL 8.0 官方文档: https://dev.mysql.com/doc/refman/8.0/en/
- sqlx 文档: https://docs.rs/sqlx/latest/sqlx/
