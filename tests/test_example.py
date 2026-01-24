"""示例测试"""

from example_package import hello, add, print_dict

def test_hello() -> None:
    """测试 hello 函数"""
    assert hello("World") == "Hello, World!"
    assert hello("Python") == "Hello, Python!"

def test_add() -> None:
    """测试 add 函数"""
    assert add(1, 2) == 3
    assert add(0, 0) == 0
    assert add(-1, 1) == 0

def test_print_dict() -> None:
    """测试 print_dict 函数"""
    # 测试基本字典
    data = {"name": "test", "value": 123}
    # 不应该抛出异常
    print_dict(data)
    
    # 测试嵌套字典
    nested_data = {
        "level1": {
            "level2": {
                "value": "nested"
            }
        }
    }
    print_dict(nested_data)
    
    # 测试列表
    list_data = [1, 2, 3, {"key": "value"}]
    print_dict(list_data)
