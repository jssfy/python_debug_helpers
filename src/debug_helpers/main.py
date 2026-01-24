"""主模块示例"""

from . import hello, add

def main() -> None:
    """主函数"""
    print(hello("World"))
    print(f"1 + 2 = {add(1, 2)}")

if __name__ == "__main__":
    main()
