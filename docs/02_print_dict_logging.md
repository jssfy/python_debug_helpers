# print_dict 模块修复总结

## 问题描述

用户反馈 `print_dict()` 函数没有输出内容，并指出使用 `print()` 不能实现日志分级功能。

## 解决方案

### 修复内容

1. **恢复 logging 功能**：使用 Python 标准 logging 模块，支持日志分级
2. **自动配置**：添加 `_ensure_logger_configured()` 函数，如果用户没有配置logger，自动配置默认输出
3. **避免重复输出**：设置 `logger.propagate = False`，防止日志传播到根logger造成重复

### 核心改进

**src/example_package/print.py**:

```python
import logging
import sys

logger = logging.getLogger(__name__)

def _ensure_logger_configured():
    """确保logger至少有一个handler，用于默认输出"""
    if not logger.handlers and not logging.getLogger().handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(logging.INFO)
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
        logger.propagate = False  # 避免重复输出

def print_dict(data: Any, level: str = "info") -> None:
    """
    打印字典，支持日志分级
    
    Args:
        data: 要打印的数据
        level: 日志级别（debug/info/warning/error/critical）
    """
    _ensure_logger_configured()
    formatted = _format_dict_recursive(data)
    
    if level == "debug":
        logger.debug(formatted)
    elif level == "info":
        logger.info(formatted)
    elif level == "warning":
        logger.warning(formatted)
    elif level == "error":
        logger.error(formatted)
    elif level == "critical":
        logger.critical(formatted)
```

## 使用方式

### 1. 简单使用（自动配置）

```python
from example_package import print_dict

# 直接使用，自动配置logger
print_dict({"key": "value"})
```

### 2. 指定日志级别

```python
from example_package import print_dict

print_dict(data, level="debug")     # DEBUG
print_dict(data, level="info")      # INFO（默认）
print_dict(data, level="warning")   # WARNING
print_dict(data, level="error")     # ERROR
print_dict(data, level="critical")  # CRITICAL
```

### 3. 自定义日志配置

```python
import logging
from example_package import print_dict

# 配置日志格式
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(levelname)s] %(message)s'
)

# 使用
print_dict({"test": "data"}, level="debug")
```

## 测试结果

### examples/test.py（简单版本）
✅ 输出正常，格式化的JSON显示清晰

### examples/test_logging.py（完整版本）
✅ 所有日志级别正常工作：
- DEBUG - 带 [DEBUG] 前缀
- INFO - 带 [INFO] 前缀  
- WARNING - 带 [WARNING] 前缀
- ERROR - 带 [ERROR] 前缀
- CRITICAL - 带 [CRITICAL] 前缀

## 新增文档

- **docs/logging_guide.md**: 完整的日志分级使用指南
  - 基本用法
  - 日志配置方式
  - 日志级别说明
  - 实际应用示例
  - 高级配置（文件输出、多handler）

## 文件修改

1. `src/example_package/print.py` - 实现日志分级功能
2. `examples/test.py` - 简化版示例（自动配置）
3. `examples/test_logging.py` - 日志分级完整示例
4. `docs/logging_guide.md` - 日志使用指南

## 优势

1. ✅ **零配置可用**：不配置logger也能正常输出
2. ✅ **灵活配置**：支持自定义logger配置
3. ✅ **日志分级**：支持5个标准日志级别
4. ✅ **无重复输出**：正确处理logger传播
5. ✅ **向后兼容**：保持原有API不变
