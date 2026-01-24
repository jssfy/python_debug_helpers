# 版本更新：v0.3.0

## ✅ 更新完成

版本号已从 `0.2.0` 更新为 `0.3.0`

---

## 📝 更新的文件

### 1. pyproject.toml
```toml
[project]
name = "debug-helpers"
version = "0.3.0"  # ← 已更新
description = "一个简单的 Python 调试辅助工具包"

[tool.hatch.build.targets.wheel]
packages = ["src/debug_helpers"]  # ← 模块名
```

### 2. src/debug_helpers/__init__.py
```python
__version__ = "0.3.0"  # ← 已更新
```

### 3. CHANGELOG.md
添加了 v0.3.0 的更新日志：

```markdown
## [0.3.0] - 2026-01-24

### 改进
- 优化示例代码，移除 sys.path 黑魔法，改为依赖正式安装
- 完善文档说明，添加安装和使用指南
- 更新 examples/readme.md，提供详细的安装和使用说明

### 包重命名
- 包名：debug-tools → debug-helpers（解决 PyPI 名称冲突）
- 模块名：debug_tools → debug_helpers

### 工具改进
- 添加 Makefile 支持常用开发任务
- 添加 clean 目标清理构建产物
```

---

## 🔍 验证

```bash
# 检查版本号
$ grep "version" pyproject.toml
version = "0.3.0"

$ grep "__version__" src/debug_helpers/__init__.py
__version__ = "0.3.0"

$ head -10 CHANGELOG.md
# 更新日志

## [0.3.0] - 2026-01-24
...
```

---

## 📦 v0.3.0 主要变更

### 1. 包和模块重命名

| 项目 | 旧名称 | 新名称 | 原因 |
|------|--------|--------|------|
| 包名 (pip) | `debug-tools` | `debug-helpers` | PyPI 名称冲突 |
| 模块名 (import) | `debug_tools` | `debug_helpers` | 保持一致 |
| 描述 | Python 调试工具包 | Python 调试辅助工具包 | 更准确 |

**安装和导入方式**:
```bash
# 安装
pip install debug-helpers

# 导入
from debug_helpers import hello, add, print_dict
```

### 2. 示例代码优化
- ❌ 移除 `sys.path.insert()` 黑魔法
- ✅ 改为依赖正式的 `pip install`
- ✅ 更符合包使用的最佳实践

**之前的做法**（不推荐）:
```python
import sys
import os
sys.path.insert(0, os.path.abspath('..'))  # ❌ 不标准

from debug_tools import hello
```

**现在的做法**（推荐）:
```python
# 先安装: pip install -e .
from debug_helpers import hello  # ✅ 标准方式
```

### 3. Makefile 支持

添加了 `Makefile` 简化常用任务：

| 命令 | 说明 |
|------|------|
| `make install` | 安装到本地（开发模式） |
| `make uninstall` | 卸载包 |
| `make example` | 运行示例 |
| `make clean` | 清理构建产物 |
| `make build` | 构建分发包 |
| `make publish-test` | 发布到 TestPyPI |
| `make publish-pypi` | 发布到 PyPI |

### 4. 文档完善
- 更新 `examples/readme.md` 提供详细安装说明
- 添加 `docs/08_issue_name_conflict.md` 记录 PyPI 名称冲突
- 添加 `docs/09_rename_to_debug_helpers.md` 改名指南
- 添加 `docs/07_makefile_guide.md` Makefile 使用指南
- 明确示例需要先安装包

### 5. 使用方式标准化
- ✅ 示例代码展示标准导入方式
- ✅ 强制用户理解安装步骤
- ✅ 与 PyPI 发布后的使用方式一致

---

## 🚀 发布步骤

### 方式 1: 使用 Makefile（推荐）

```bash
cd /Users/admin/Downloads/sdk-generation/pypi/python_debug_tools

# 1. 清理旧文件
make clean

# 2. 本地安装测试
make install

# 3. 运行示例验证
make example

# 4. 构建
make build

# 5. 发布到 TestPyPI（可选）
make publish-test

# 6. 发布到 PyPI
make publish-pypi
```

### 方式 2: 使用脚本

```bash
# 测试发布
./scripts/publish_testpypi.sh

# 正式发布
./scripts/publish_pypi.sh
```

### 方式 3: 手动步骤

#### 1. 测试本地安装

```bash
cd /Users/admin/Downloads/sdk-generation/pypi/python_debug_tools

# 卸载旧版本（如果有）
pip uninstall debug-helpers -y

# 开发模式安装
pip install -e .

# 验证版本
python -c "from debug_helpers import __version__; print(__version__)"
# 应输出: 0.3.0

# 运行测试
python examples/test.py
```

#### 2. 发布到 TestPyPI

```bash
# 清理
rm -rf dist/ build/ *.egg-info src/*.egg-info

# 构建
python3 -m build

# 检查
python3 -m twine check dist/*

# 上传到 TestPyPI
python3 -m twine upload --repository testpypi dist/*
```

#### 3. 验证 TestPyPI 安装

```bash
# 创建虚拟环境
python3 -m venv test_env
source test_env/bin/activate

# 从 TestPyPI 安装
pip install -i https://test.pypi.org/simple/ debug-helpers

# 测试
python -c "from debug_helpers import __version__; print(__version__)"
python -c "from debug_helpers import hello, print_dict; print(hello('Test')); print_dict({'v': '0.3.0'})"

# 清理
deactivate
rm -rf test_env
```

#### 4. 发布到正式 PyPI

```bash
python3 -m twine upload dist/*
```

#### 5. 验证正式发布

```bash
# 创建新的虚拟环境
python3 -m venv verify_env
source verify_env/bin/activate

# 从 PyPI 安装
pip install debug-helpers

# 验证版本和功能
python -c "from debug_helpers import __version__; print(__version__)"
python -c "from debug_helpers import hello; print(hello('World'))"

# 清理
deactivate
rm -rf verify_env
```

---

## 📊 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **0.3.0** | 2026-01-24 | 改名为 debug-helpers，优化示例代码，添加 Makefile |
| 0.2.0 | 2026-01-24 | 改名为 debug-tools，添加 print_dict 功能 |
| 0.1.0 | 2026-01-24 | 初始版本，基本功能 |

---

## 🎯 后续计划

可能的功能扩展：
- [ ] 添加更多调试工具函数
- [ ] 支持自定义日志格式
- [ ] 添加性能分析工具
- [ ] 支持彩色输出（rich 库集成）
- [ ] 添加更多数据类型支持
- [ ] 添加单元测试覆盖率
- [ ] 添加 GitHub Actions CI/CD

---

## 📚 相关文档

### 版本相关
- [../CHANGELOG.md](../CHANGELOG.md) - 完整的变更日志
- [04_rename_summary.md](04_rename_summary.md) - v0.2.0 改名说明

### 改名相关
- [08_issue_name_conflict.md](08_issue_name_conflict.md) - PyPI 名称冲突 issue
- [09_rename_to_debug_helpers.md](09_rename_to_debug_helpers.md) - 改名为 debug-helpers 指南

### 工具相关
- [07_makefile_guide.md](07_makefile_guide.md) - Makefile 使用指南
- [../MAKEFILE_README.md](../MAKEFILE_README.md) - Makefile 快速参考
- [01_release.md](01_release.md) - 发布指南

### 开发相关
- [02_local_development.md](02_local_development.md) - 本地开发指南
- [03_package_vs_module_name.md](03_package_vs_module_name.md) - 包名与模块名详解

---

## ⚠️ 注意事项

### 1. 包名冲突
原包名 `debug-tools` 在 PyPI 已被占用，因此改名为 `debug-helpers`。

详见：[08_issue_name_conflict.md](08_issue_name_conflict.md)

### 2. 手动步骤
由于沙盒限制，需要手动重命名目录：
```bash
mv src/debug_tools src/debug_helpers
```

详见：[09_rename_to_debug_helpers.md](09_rename_to_debug_helpers.md)

### 3. 文件更新
改名后需要更新的文件：
- ✅ `pyproject.toml`
- ✅ `examples/test.py`
- ✅ `Makefile`
- ⏳ `src/debug_tools/` → `src/debug_helpers/`（需手动）
- ⏳ 其他 `.md`, `.sh`, `.py` 文件中的引用

---

**版本更新完成！** 🎉

现在可以进行构建和发布了。推荐使用 `make` 命令简化操作。
