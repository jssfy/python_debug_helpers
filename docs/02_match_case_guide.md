# match-case 语法使用说明

## Python 3.10+ 的 match-case 语句

`match-case` 是 Python 3.10 引入的结构模式匹配（Structural Pattern Matching）语法，类似于其他语言的 switch-case。

## 基本语法

### 简单匹配

```python
match value:
    case 1:
        print("一")
    case 2:
        print("二")
    case _:  # 默认情况（类似 default）
        print("其他")
```

### 多值匹配（使用 | 运算符）

```python
match status:
    case "active" | "running":
        print("运行中")
    case "paused" | "stopped":
        print("已停止")
    case _:
        print("未知状态")
```

## 在 print_dict 中的应用

### 代码位置
`src/example_package/print.py` 第 164-176 行

### 实现

```python
def print_dict(data: Any, level: str = "info") -> None:
    """打印字典，支持日志分级"""
    _ensure_logger_configured()
    formatted = _format_dict_recursive(data)
    
    # 使用 match-case 实现日志级别分发
    level = level.lower()
    match level:
        case "debug":
            logger.debug(formatted)
        case "info":
            logger.info(formatted)
        case "warning" | "warn":  # 支持两种写法
            logger.warning(formatted)
        case "error":
            logger.error(formatted)
        case "critical":
            logger.critical(formatted)
        case _:  # 默认使用 info
            logger.info(formatted)
```

### 对比 if-elif

**if-elif** (Python 3.9 兼容):
```python
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

**match-case** (Python 3.10+):
```python
match level:
    case "debug":
        logger.debug(formatted)
    case "info":
        logger.info(formatted)
    case "warning" | "warn":  # 更简洁
        logger.warning(formatted)
    case "error":
        logger.error(formatted)
    case "critical":
        logger.critical(formatted)
    case _:
        logger.info(formatted)
```

## match-case 的优势

### 1. 语义更清晰
- `match` 明确表达"我要匹配这个值"
- `case` 明确表达"这是一个匹配分支"
- 比 if-elif 链更容易理解意图

### 2. 多值匹配更简洁
```python
# if-elif: 需要 or
elif level == "warning" or level == "warn":

# match-case: 使用 |
case "warning" | "warn":
```

### 3. 模式匹配功能强大

```python
# 匹配类型
match value:
    case int():
        print("整数")
    case str():
        print("字符串")
    case _:
        print("其他类型")

# 匹配结构
match point:
    case (0, 0):
        print("原点")
    case (x, 0):
        print(f"在 x 轴上: {x}")
    case (0, y):
        print(f"在 y 轴上: {y}")
    case (x, y):
        print(f"坐标: ({x}, {y})")

# 匹配字典
match user:
    case {"role": "admin", "active": True}:
        print("活跃管理员")
    case {"role": "admin"}:
        print("管理员")
    case {"active": True}:
        print("活跃用户")
```

### 4. 性能优化潜力
编译器可以对 match 语句进行更好的优化，生成更高效的字节码。

## 兼容性考虑

### Python 版本要求

| Python 版本 | match-case 支持 | 状态 |
|------------|----------------|------|
| 3.9 及以下 | ❌ 不支持 | 会产生 SyntaxError |
| 3.10+ | ✅ 完全支持 | 推荐使用 |

### 项目配置

`pyproject.toml`:
```toml
[project]
requires-python = ">=3.10"  # 必须声明最低版本

classifiers = [
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
```

## 最佳实践

### 1. 使用 case _ 作为默认分支
```python
match value:
    case "known":
        handle_known()
    case _:  # 总是添加默认分支
        handle_unknown()
```

### 2. 利用多值匹配
```python
# 好的做法
match status:
    case "active" | "running" | "online":
        handle_active()

# 不好的做法
if status == "active" or status == "running" or status == "online":
    handle_active()
```

### 3. 保持分支简洁
```python
# 如果逻辑复杂，提取到函数
match command:
    case "start":
        handle_start()  # 函数封装复杂逻辑
    case "stop":
        handle_stop()
```

## 迁移指南

### 从 if-elif 迁移到 match-case

1. 确认 Python 版本 >= 3.10
2. 将 `if expression ==` 改为 `match expression:`
3. 将 `elif value:` 改为 `case value:`
4. 将 `else:` 改为 `case _:`
5. 合并多个 or 条件为 `|`

### 示例

**Before**:
```python
if x == 1:
    print("一")
elif x == 2 or x == 3:
    print("二或三")
else:
    print("其他")
```

**After**:
```python
match x:
    case 1:
        print("一")
    case 2 | 3:
        print("二或三")
    case _:
        print("其他")
```

## 参考资源

- [PEP 634 – Structural Pattern Matching: Specification](https://peps.python.org/pep-0634/)
- [PEP 635 – Structural Pattern Matching: Motivation and Rationale](https://peps.python.org/pep-0635/)
- [Python 3.10 文档 - match 语句](https://docs.python.org/3.10/reference/compound_stmts.html#the-match-statement)

---

**总结**：match-case 是 Python 3.10+ 的现代特性，提供了更清晰、更强大的模式匹配能力。在 `example_package` 中使用它可以让代码更易读和维护。
