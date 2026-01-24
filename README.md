# debug-helpers

一个简单的 Python 调试辅助工具包。

[![PyPI version](https://badge.fury.io/py/debug-helpers.svg)](https://pypi.org/project/debug-helpers/)
[![Python Version](https://img.shields.io/pypi/pyversions/debug-helpers.svg)](https://pypi.org/project/debug-helpers/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 功能特性

- ✅ `hello(name)` - 返回问候语
- ✅ `add(a, b)` - 两数相加
- ✅ `print_dict(data, level)` - 格式化打印字典，支持日志分级

## 安装

### 从 PyPI 安装（推荐）

```bash
pip install debug-helpers
```

### 从 TestPyPI 安装（测试版本）

```bash
pip install -i https://test.pypi.org/simple/ debug-helpers
```

### 开发模式安装

```bash
git clone <repository>
cd python_debug_helpers
pip install -e .
```

## 快速开始

```python
from debug_helpers import hello, add, print_dict

# 基本功能
print(hello("World"))  # Hello, World!
print(add(1, 2))       # 3

# 打印字典
data = {
    "name": "Alice",
    "age": 30,
    "hobbies": ["reading", "coding"]
}
print_dict(data)
```

输出：
```json
{
  "name": "Alice",
  "age": 30,
  "hobbies": [
    "reading",
    "coding"
  ]
}
```

## 高级用法

### 日志分级

`print_dict` 支持不同的日志级别：

```python
import logging
logging.basicConfig(level=logging.DEBUG)

from debug_helpers import print_dict

# 不同级别的日志
print_dict({"info": "data"}, level="info")      # INFO 级别
print_dict({"warning": "msg"}, level="warning") # WARNING 级别
print_dict({"error": "msg"}, level="error")     # ERROR 级别
print_dict({"debug": "msg"}, level="debug")     # DEBUG 级别
```

### 嵌套结构

支持复杂的嵌套数据结构：

```python
from debug_helpers import print_dict

complex_data = {
    "project": "debug_helpers",
    "version": "0.3.0",
    "features": ["hello", "add", "print_dict"],
    "metadata": {
        "author": "Example Author",
        "tags": ["python", "debug", "tools"]
    }
}

print_dict(complex_data)
```

## 本地开发

### 使用 Makefile（推荐）

```bash
# 查看所有命令
make help

# 开发模式安装
make install-local

# 运行示例
make example

# 运行测试
make test

# 清理构建文件
make clean

# 构建包
make build
```

### 手动操作

```bash
# 克隆项目
git clone <repository>
cd python_debug_helpers

# 开发模式安装
pip install -e .

# 运行示例
python examples/test.py

# 运行测试
pytest tests/ -v

# 构建
python -m build
```

## 项目结构

```
python_debug_helpers/
├── src/
│   └── debug_helpers/      # 源代码
│       ├── __init__.py
│       ├── main.py
│       └── print.py
├── tests/                  # 单元测试
│   └── test_example.py
├── examples/               # 使用示例
│   ├── test.py
│   └── readme.md
├── docs/                   # 文档
│   ├── 01_README.md       # 文档索引
│   ├── 01_release.md      # 发布指南
│   ├── 02_local_development.md
│   ├── 03_package_vs_module_name.md
│   └── ...
├── scripts/                # 发布脚本
│   ├── publish_testpypi.sh
│   └── publish_pypi.sh
├── Makefile               # 自动化任务
├── pyproject.toml         # 项目配置
├── CHANGELOG.md           # 更新日志
├── LICENSE                # 许可证
└── README.md              # 本文件
```

## 文档

### 快速链接

- [📖 文档索引](docs/01_README.md) - 所有文档的入口
- [🚀 发布指南](docs/01_release.md) - 如何发布新版本
- [💻 本地开发](docs/02_local_development.md) - 本地开发指南
- [📦 包名说明](docs/03_package_vs_module_name.md) - 包名与模块名的区别
- [🛠️ Makefile 指南](docs/07_makefile_guide.md) - Makefile 详细说明
- [📅 更新日志](CHANGELOG.md) - 版本更新记录

### 重要说明

**包名 vs 模块名**

- **安装时使用**：`pip install debug-helpers`（包名，带连字符）
- **导入时使用**：`from debug_helpers import ...`（模块名，带下划线）

详见：[包名与模块名详解](docs/03_package_vs_module_name.md)

## 发布流程

### 使用 Makefile（推荐）

```bash
# 1. 发布到 TestPyPI 测试
make publish-test

# 2. 从 TestPyPI 安装验证
make install-test

# 3. 发布到正式 PyPI
make publish-pypi

# 4. 从 PyPI 安装验证
make install
```

### 使用脚本

```bash
# 发布到 TestPyPI
./scripts/publish_testpypi.sh

# 发布到正式 PyPI
./scripts/publish_pypi.sh
```

详见：[发布指南](docs/01_release.md)

## 系统要求

- Python >= 3.9
- pip >= 21.0

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| 0.3.0 | 2026-01-24 | 改名为 debug-helpers，优化示例代码，添加 Makefile |
| 0.2.0 | 2026-01-24 | 添加 print_dict 功能 |
| 0.1.0 | 2026-01-24 | 初始版本 |

完整更新日志：[CHANGELOG.md](CHANGELOG.md)

## 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 问题反馈

如果遇到问题或有建议，请：

1. 查看 [文档](docs/01_README.md)
2. 查看 [已知问题](docs/08_issue_name_conflict.md)
3. 提交 Issue

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 作者

Example Author

## 相关链接

- [PyPI 项目页](https://pypi.org/project/debug-helpers/)
- [TestPyPI 项目页](https://test.pypi.org/project/debug-helpers/)
- [完整教程](../how_to_publish_to_pypi.md)

---

**注意**：本项目原名为 `debug-tools`，因 PyPI 名称冲突改为 `debug-helpers`。详见 [Issue 记录](docs/08_issue_name_conflict.md)。
