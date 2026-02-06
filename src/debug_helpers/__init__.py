"""Python 调试工具包"""

from .print import print_dict

__version__ = "0.4.3"  # x-release-please-version


def hello(name: str) -> str:
    """返回问候语"""
    return f"Hello, {name}!"


def add(a: int, b: int) -> int:
    """两数相加"""
    return a + b


__all__ = ["hello", "add", "print_dict"]
