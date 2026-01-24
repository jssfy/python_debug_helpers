# Python 版本升级说明

## 变更内容

### 最低 Python 版本要求：3.9 → 3.10

**原因**：使用了 Python 3.10+ 的 `match-case` 语句（结构模式匹配）

### 代码改进

**之前** (if-elif 链):
```python
level = level.lower()
if level == "debug":
    logger.debug(formatted)
elif level == "info":
    logger.info(formatted)
elif level == "warning" or level == "warn":
    logger.warning(formatted)
elif level == "error":
    logger.error(formatted)
elif level == "critical":
    logger.critical(formatted)
else:
    logger.info(formatted)
```

**现在** (match-case):
```python
level = level.lower()
match level:
    case "debug":
        logger.debug(formatted)
    case "info":
        logger.info(formatted)
    case "warning" | "warn":
        logger.warning(formatted)
    case "error":
        logger.error(formatted)
    case "critical":
        logger.critical(formatted)
    case _:
        logger.info(formatted)
```

### 优势

1. ✅ **更清晰的语法**：match-case 是专门为模式匹配设计的
2. ✅ **更简洁**：使用 `|` 运算符处理多个值（`"warning" | "warn"`）
3. ✅ **更符合现代 Python**：遵循 Python 3.10+ 的最佳实践
4. ✅ **更好的性能**：编译器可以更好地优化 match 语句

---

## 测试环境要求

### 当前系统
- Python 版本：3.9.6
- 状态：❌ 不支持 match-case 语法

### 升级方案

#### 方案 1: 使用 pyenv 安装 Python 3.10+

```bash
# 安装 pyenv（如果未安装）
brew install pyenv

# 安装 Python 3.12
pyenv install 3.12.0

# 在项目目录设置本地版本
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
pyenv local 3.12.0

# 验证
python3 --version  # 应该显示 3.12.0
```

#### 方案 2: 使用 Homebrew 安装

```bash
# 安装 Python 3.12
brew install python@3.12

# 使用完整路径运行
/opt/homebrew/bin/python3.12 examples/test.py
```

#### 方案 3: 使用官方安装包

1. 访问 https://www.python.org/downloads/
2. 下载 Python 3.12+ for macOS
3. 安装后使用 `python3.12` 命令

---

## 测试

安装 Python 3.10+ 后，运行测试：

```bash
cd /Users/admin/Downloads/sdk-generation/pypi/example_package

# 基础测试
python3 examples/test.py

# 日志分级测试
python3 examples/test_logging.py

# 单元测试
pytest tests/
```

---

## pyproject.toml 变更

```toml
[project]
name = "yeannhua-example-package-demo"
version = "0.2.0"
requires-python = ">=3.10"  # 从 3.9 改为 3.10

classifiers = [
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
]
```

---

## 兼容性说明

### 支持的版本
- ✅ Python 3.10
- ✅ Python 3.11
- ✅ Python 3.12
- ✅ Python 3.13

### 不再支持
- ❌ Python 3.9（缺少 match-case 语法）
- ❌ Python 3.8 及更早版本

---

## 如果需要保持 Python 3.9 兼容

如果必须支持 Python 3.9，可以恢复 if-elif 语法：

```python
# 将 match-case 改回 if-elif
level = level.lower()
if level == "debug":
    logger.debug(formatted)
elif level == "info":
    logger.info(formatted)
elif level == "warning" or level == "warn":
    logger.warning(formatted)
elif level == "error":
    logger.error(formatted)
elif level == "critical":
    logger.critical(formatted)
else:
    logger.info(formatted)
```

并在 `pyproject.toml` 中恢复：
```toml
requires-python = ">=3.9"
```

---

## 推荐

✅ **建议使用 Python 3.10+**

理由：
1. match-case 是 Python 的未来趋势
2. Python 3.9 将在 2025-10 停止维护
3. Python 3.10+ 性能更好，功能更强
4. 大多数项目已迁移到 3.10+

---

**注意**：发布到 PyPI 时，包会在 PyPI 的服务器上构建，支持所有声明的 Python 版本。本地开发环境的 Python 版本需要 >= 3.10 才能运行测试。
