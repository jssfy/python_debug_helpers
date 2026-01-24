"""Python 调试工具包"""

__version__ = "0.3.0"

def hello(name: str) -> str:
    """返回问候语"""
    return f"Hello, {name}!"

def add(a: int, b: int) -> int:
    """两数相加"""
    return a + b

# 导出 print 模块的功能
from .print import print_dict

__all__ = ['hello', 'add', 'print_dict']
