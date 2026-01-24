# 使用示例

本目录包含 `debug-tools` 包的使用示例。

## 前置要求

在运行示例之前，需要先安装包：

### 方式一：开发模式安装（推荐用于本地开发）

```bash
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
pip install -e .
```

开发模式的好处：
- ✅ 修改代码后立即生效，无需重新安装
- ✅ 适合本地开发和调试

### 方式二：从源码构建安装

```bash
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
python3 -m build
pip install dist/debug_tools-0.2.0-py3-none-any.whl
```

### 方式三：从 PyPI 安装（正式发布后）

```bash
pip install debug-tools
```

## 运行示例

安装完成后，运行示例：

```bash
# 方式一：在项目根目录运行
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
python3 examples/test.py

# 方式二：在 examples 目录运行
cd examples
python3 test.py

# 方式三：在任意目录运行
python3 /path/to/examples/test.py
```

## 示例说明

### test.py

演示 `debug-tools` 的基本功能：

1. **hello()** - 问候函数
2. **add()** - 加法函数
3. **print_dict()** - 格式化打印字典

**预期输出**：

```
==================================================
测试 debug_tools v0.2.0
==================================================

1. 测试 hello 函数
------------------------------
Hello, World!
Hello, Python开发者!

2. 测试 add 函数
------------------------------
1 + 2 = 3
100 + 200 = 300

3. 测试 print_dict 函数
------------------------------
简单字典:
{
  "name": "测试",
  "value": 123
}
...
```

## 常见问题

### 问题：ModuleNotFoundError: No module named 'debug_tools'

**原因**：包未安装

**解决**：
```bash
# 开发模式安装
pip install -e .

# 或使用安装脚本
./scripts/install_and_test.sh
```

### 问题：ImportError: cannot import name 'xxx'

**原因**：可能安装了旧版本

**解决**：
```bash
# 卸载旧版本
pip uninstall debug-tools

# 重新安装
pip install -e .
```

## 快速开始

```bash
# 一键安装和测试
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
./scripts/install_and_test.sh
```

这个脚本会：
1. 检查并卸载旧版本
2. 开发模式安装
3. 自动运行 examples/test.py
