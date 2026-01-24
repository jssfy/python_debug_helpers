# 本地开发和测试指南

本指南说明如何在本地安装和测试 `example_package` 包。

## 环境准备

### 1. Python 版本
确保安装了 Python 3.9 或更高版本：
```bash
python3 --version
```

### 2. 安装构建工具
```bash
pip install --user build pytest
```

## 本地安装方式

### 方式一：开发模式安装（推荐）

开发模式安装允许你修改代码后立即生效，无需重新安装。

```bash
# 进入项目目录
cd /Users/admin/Downloads/sdk-generation/pypi/example_package

# 开发模式安装
pip install -e .
```

**优点**：
- 代码修改后立即生效
- 方便开发和调试
- 不需要重新安装

**验证安装**：
```bash
pip list | grep example-package
# 应该看到: yeannhua-example-package-demo 0.2.0 /path/to/src
```

### 重要说明：包名 vs 模块名

#### pip list 显示的名字（包名）
- **名称**：`yeannhua-example-package-demo`
- **定义位置**：`pyproject.toml` 中的 `name` 字段
- **用途**：用于 pip 安装、PyPI 上的包名称
- **命令**：
  ```bash
  pip install yeannhua-example-package-demo
  pip uninstall yeannhua-example-package-demo
  pip list | grep yeannhua-example-package-demo
  ```

#### from 导入使用的名字（模块名）
- **名称**：`example_package`
- **定义位置**：`src/example_package/` 目录名
- **用途**：Python 代码中导入模块
- **使用**：
  ```python
  from example_package import hello, add, print_dict
  import example_package
  ```

#### 配置示例

**pyproject.toml**:
```toml
[project]
name = "yeannhua-example-package-demo"  # ← pip list 看到的名字（包名）

[tool.hatch.build.targets.wheel]
packages = ["src/example_package"]      # ← 指向 src/example_package 目录（模块名）
```

**目录结构**:
```
src/
└── example_package/        # ← from example_package import xxx（模块名）
    ├── __init__.py
    ├── main.py
    └── print.py
```

#### 为什么要区分？

1. **包名**（`yeannhua-example-package-demo`）
   - 可以包含连字符 `-`
   - 在 PyPI 上全局唯一
   - 用户安装时使用

2. **模块名**（`example_package`）
   - 必须是合法的 Python 标识符（不能有 `-`）
   - 代码导入时使用
   - 通常使用下划线 `_`

#### 常见的命名约定

| 包名（pip） | 模块名（import） | 说明 |
|------------|-----------------|------|
| `requests` | `import requests` | 一致 |
| `Pillow` | `from PIL import Image` | 不一致 |
| `beautifulsoup4` | `from bs4 import BeautifulSoup` | 不一致 |
| `scikit-learn` | `import sklearn` | 不一致（因为 `-` 不能在模块名中） |
| `yeannhua-example-package-demo` | `import example_package` | 不一致（本项目） |

### 方式二：从源码构建安装

如果想测试实际的打包效果：

```bash
# 1. 清理旧的构建文件
rm -rf dist/ build/ *.egg-info src/*.egg-info

# 2. 构建包
python3 -m build

# 3. 安装构建的包
pip install dist/yeannhua_example_package_demo-0.2.0-py3-none-any.whl
```

### 方式三：直接从源码安装

```bash
# 直接安装（会复制文件到 site-packages）
pip install .
```

## 运行测试

### 1. 运行所有测试

```bash
# 使用 pytest
pytest tests/

# 或显示详细输出
pytest tests/ -v

# 或显示打印输出
pytest tests/ -s
```

### 2. 运行特定测试

```bash
# 运行特定测试文件
pytest tests/test_example.py

# 运行特定测试函数
pytest tests/test_example.py::test_hello
pytest tests/test_example.py::test_print_dict
```

### 3. 查看测试覆盖率

```bash
# 安装 coverage
pip install coverage pytest-cov

# 运行测试并生成覆盖率报告
pytest tests/ --cov=example_package --cov-report=html

# 查看 HTML 报告
open htmlcov/index.html  # macOS
# 或
xdg-open htmlcov/index.html  # Linux
```

## 交互式测试

### 1. Python 交互式环境

```bash
# 启动 Python
python3

# 或使用 IPython（更好的交互体验）
pip install ipython
ipython
```

在交互式环境中：

```python
# 导入模块
from example_package import hello, add, print_dict

# 测试 hello 函数
print(hello("World"))
# 输出: Hello, World!

# 测试 add 函数
result = add(10, 20)
print(result)
# 输出: 30

# 测试 print_dict 函数
data = {
    "name": "测试",
    "age": 25,
    "hobbies": ["编程", "阅读"],
    "address": {
        "city": "上海",
        "country": "中国"
    }
}
print_dict(data)
```

### 2. 运行示例脚本

```bash
# 运行 main 模块
python3 -m example_package.main
```

### 3. 创建测试脚本

创建一个测试脚本 `test_local.py`：

```python
#!/usr/bin/env python3
"""本地测试脚本"""

from example_package import hello, add, print_dict

def main():
    print("=== 测试 hello 函数 ===")
    print(hello("本地测试"))
    print()
    
    print("=== 测试 add 函数 ===")
    print(f"1 + 2 = {add(1, 2)}")
    print(f"100 + 200 = {add(100, 200)}")
    print()
    
    print("=== 测试 print_dict 函数 ===")
    test_data = {
        "name": "示例数据",
        "version": "0.2.0",
        "features": ["hello", "add", "print_dict"],
        "metadata": {
            "author": "测试用户",
            "date": "2026-01-24"
        }
    }
    print_dict(test_data)

if __name__ == "__main__":
    main()
```

运行测试脚本：
```bash
python3 test_local.py
```

## 开发工作流

### 1. 修改代码后测试

```bash
# 1. 修改代码（如果使用 -e 安装，改动立即生效）

# 2. 运行测试
pytest tests/

# 3. 手动测试
python3 -c "from example_package import print_dict; print_dict({'test': 'ok'})"
```

### 2. 代码格式检查

```bash
# 安装 ruff（如果还没安装）
pip install ruff

# 检查代码格式
ruff check src/

# 自动修复
ruff check --fix src/
```

### 3. 类型检查

```bash
# 安装 mypy
pip install mypy

# 运行类型检查
mypy src/example_package/
```

## 卸载

### 卸载开发模式安装的包

```bash
pip uninstall yeannhua-example-package-demo
```

### 清理构建文件

```bash
# 清理所有构建产物
rm -rf dist/ build/ *.egg-info src/*.egg-info
rm -rf .pytest_cache/ htmlcov/ .coverage
find . -type d -name __pycache__ -exec rm -rf {} +
```

## 常见问题

### 1. 导入错误：找不到模块

**问题**：
```python
ImportError: No module named 'example_package'
```

**解决方案**：
```bash
# 确认是否已安装
pip list | grep example

# 如果未安装，使用开发模式安装
pip install -e .
```

### 2. 修改代码后不生效

**问题**：修改了代码，但运行时使用的还是旧代码。

**解决方案**：
- 如果使用 `-e` 安装：重启 Python 解释器
- 如果不是 `-e` 安装：重新安装包

```bash
# 卸载后重新安装
pip uninstall yeannhua-example-package-demo
pip install -e .
```

### 3. 测试失败

**问题**：`pytest` 找不到或测试失败。

**解决方案**：
```bash
# 确保在项目根目录
cd /Users/admin/Downloads/sdk-generation/pypi/example_package

# 确认 pytest 已安装
pip install pytest

# 显示详细错误信息
pytest tests/ -v --tb=short
```

### 4. 虚拟环境问题

建议使用虚拟环境隔离开发环境：

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate  # Linux/macOS
# 或
venv\Scripts\activate  # Windows

# 在虚拟环境中安装
pip install -e .

# 退出虚拟环境
deactivate
```

## 快速参考

```bash
# === 安装 ===
pip install -e .                    # 开发模式安装

# === 测试 ===
pytest tests/                       # 运行所有测试
pytest tests/ -v                    # 详细输出
pytest tests/ --cov=example_package # 测试覆盖率

# === 交互测试 ===
python3 -m example_package.main     # 运行示例
python3 -c "from example_package import hello; print(hello('test'))"

# === 清理 ===
pip uninstall yeannhua-example-package-demo
rm -rf dist/ build/ *.egg-info
```

## 推荐工作流

1. **首次设置**：
   ```bash
   cd /Users/admin/Downloads/sdk-generation/pypi/example_package
   pip install -e .
   pip install pytest pytest-cov
   ```

2. **日常开发**：
   ```bash
   # 修改代码
   vim src/example_package/print.py
   
   # 运行测试
   pytest tests/
   
   # 交互测试
   python3
   >>> from example_package import print_dict
   >>> print_dict({"test": "data"})
   ```

3. **发布前**：
   ```bash
   # 运行完整测试
   pytest tests/ -v
   
   # 构建和检查
   python3 -m build
   python3 -m twine check dist/*
   
   # 发布到 TestPyPI
   ./scripts/publish_testpypi.sh
   ```

## 相关文档

- [../README.md](../README.md) - 项目介绍
- [docs/release.md](docs/release.md) - 发布指南
- [docs/upload_instructions.md](docs/upload_instructions.md) - 上传说明
