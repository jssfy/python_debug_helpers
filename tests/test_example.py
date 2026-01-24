"""示例测试"""

import unittest
from debug_helpers import hello, add, print_dict


class TestDebugHelpers(unittest.TestCase):
    """debug_helpers 测试类"""
    
    def test_hello(self) -> None:
        """测试 hello 函数"""
        self.assertEqual(hello("World"), "Hello, World!")
        self.assertEqual(hello("Python"), "Hello, Python!")
    
    def test_add(self) -> None:
        """测试 add 函数"""
        self.assertEqual(add(1, 2), 3)
        self.assertEqual(add(0, 0), 0)
        self.assertEqual(add(-1, 1), 0)
    
    def test_print_dict(self) -> None:
        """测试 print_dict 函数"""
        # 测试基本字典
        data = {"name": "test", "value": 123}
        # 不应该抛出异常
        try:
            print_dict(data)
        except Exception as e:
            self.fail(f"print_dict raised {e} unexpectedly!")
        
        # 测试嵌套字典
        nested_data = {
            "level1": {
                "level2": {
                    "value": "nested"
                }
            }
        }
        try:
            print_dict(nested_data)
        except Exception as e:
            self.fail(f"print_dict raised {e} unexpectedly!")
        
        # 测试列表
        list_data = [1, 2, 3, {"key": "value"}]
        try:
            print_dict(list_data)
        except Exception as e:
            self.fail(f"print_dict raised {e} unexpectedly!")


if __name__ == '__main__':
    unittest.main()
