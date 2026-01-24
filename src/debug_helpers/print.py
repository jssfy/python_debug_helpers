"""字典格式化和打印工具模块"""

import json
import logging
import sys
from typing import Any

# 创建logger
logger = logging.getLogger(__name__)

def _ensure_logger_configured():
    """确保logger至少有一个handler，用于默认输出"""
    if not logger.handlers and not logging.getLogger().handlers:
        # 如果logger和根logger都没有配置handler，添加一个默认的StreamHandler
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(logging.INFO)
        # 简单格式，只输出消息内容
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
        logger.propagate = False  # 不传播到根logger，避免重复输出

def _format_dict_recursive(data: Any, indent: int = 0) -> str:
    """
    递归格式化字典为JSON格式，缩进为2个空格
    
    Args:
        data: 要格式化的数据
        indent: 当前缩进级别
        
    Returns:
        str: 格式化后的字符串
    """
    if isinstance(data, dict):
        if not data:
            return "{}"
        
        lines = ["{"]
        items = []
        for key, value in data.items():
            formatted_value = _format_dict_recursive(value, indent + 1)
            items.append(f"{'  ' * (indent + 1)}{json.dumps(key)}: {formatted_value}")
        
        lines.append(",\n".join(items))
        lines.append(f"{'  ' * indent}}}")
        return "\n".join(lines)
    
    elif isinstance(data, list):
        if not data:
            return "[]"
        
        lines = ["["]
        items = []
        for item in data:
            formatted_item = _format_dict_recursive(item, indent + 1)
            items.append(f"{'  ' * (indent + 1)}{formatted_item}")
        
        lines.append(",\n".join(items))
        lines.append(f"{'  ' * indent}]")
        return "\n".join(lines)
    
    else:
        # 对于基本类型，使用json.dumps确保正确的转义
        # 特殊处理MongoDB的ObjectId类型
        if hasattr(data, '__class__') and data.__class__.__name__ == 'ObjectId':
            return f'ObjectId("{str(data)}")'
        elif hasattr(data, '__class__') and 'datetime' in data.__class__.__name__:
            # 处理datetime类型
            return f'"{data.isoformat()}"'
        elif hasattr(data, '__dataclass_fields__'):
            # 处理dataclass对象，转换为字典
            return _format_dict_recursive(data.__dict__, indent)
        elif hasattr(data, 'value') and hasattr(data, 'name'):
            # 处理枚举对象
            return json.dumps(data.value, ensure_ascii=False)
        elif hasattr(data, '__dict__'):
            # 处理其他有__dict__属性的对象
            return _format_dict_recursive(data.__dict__, indent)
        else:
            # 检查是否是字符串且可能是JSON或Python字典格式
            if isinstance(data, str) and len(data) > 50:
                try:
                    # 首先尝试解析为JSON
                    parsed_json = json.loads(data)
                    return _format_dict_recursive(parsed_json, indent)
                except (json.JSONDecodeError, TypeError):
                    # 如果JSON解析失败，检查是否是Python字典格式
                    if data.startswith('{') and data.endswith('}'):
                        # 对于包含ObjectId和datetime的字符串，进行简单的格式化
                        # 将逗号后添加换行和缩进
                        formatted_lines = []
                        current_line = ""
                        brace_level = 0
                        in_string = False
                        escape_next = False
                        
                        for char in data:
                            if escape_next:
                                current_line += char
                                escape_next = False
                                continue
                                
                            if char == '\\':
                                escape_next = True
                                current_line += char
                                continue
                                
                            if char == '"' and not escape_next:
                                in_string = not in_string
                                current_line += char
                                continue
                                
                            if not in_string:
                                if char == '{':
                                    brace_level += 1
                                    current_line += char
                                    if brace_level == 1:
                                        formatted_lines.append(current_line)
                                        current_line = ""
                                        continue
                                elif char == '}':
                                    brace_level -= 1
                                    current_line += char
                                    if brace_level == 0:
                                        formatted_lines.append(current_line)
                                        break
                                elif char == ',':
                                    current_line += char
                                    formatted_lines.append(current_line)
                                    current_line = "  " * (brace_level - 1)
                                    continue
                                elif char == ' ' and current_line.strip() == "":
                                    continue
                                    
                            current_line += char
                        
                        if current_line.strip():
                            formatted_lines.append(current_line)
                        
                        return "\n".join(formatted_lines)
            return json.dumps(data, ensure_ascii=False)

def print_dict(data: Any, level: str = "info") -> None:
    """
    打印字典，格式化为易读的 JSON 格式，支持日志分级
    
    Args:
        data: 要打印的数据（字典、列表或其他类型）
        level: 日志级别，可选值: "debug", "info", "warning", "error", "critical"
               默认为 "info"
    
    Examples:
        >>> print_dict({"key": "value"})  # 使用 info 级别
        >>> print_dict({"error": "msg"}, level="error")  # 使用 error 级别
    """
    # 确保logger已配置
    _ensure_logger_configured()
    
    # 格式化数据
    formatted = _format_dict_recursive(data)
    
    # 根据指定的级别输出
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