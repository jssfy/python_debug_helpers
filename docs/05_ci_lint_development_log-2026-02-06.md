# CI Lint 功能开发记录

## 核心结论

- 参考 evermemos-python 的 lint Job 模式，为 python_debug_helpers 添加了 **Ruff + Pyright + MyPy** 三工具 lint 流水线
- 适配了项目差异：pip（非 uv）、basic 类型检查（非 strict）、保持与现有 CI 风格一致
- 修复了 6 处源代码 lint 问题，所有现有测试保持通过

---

## 一、背景与目标

### 1.1 现状分析

**python_debug_helpers 项目**（`/Users/admin/temp/python_debug_helpers`）已有的 CI/CD：

| 已有 | 缺失 |
|------|------|
| `.github/workflows/test.yml` — pytest 多版本矩阵测试 | 无 Linter（ruff/flake8） |
| `.github/workflows/publish.yml` — PyPI 自动发布 | 无类型检查（pyright/mypy） |
| `Makefile` — 本地自动化 | 无格式化工具（black/ruff format） |
| `scripts/` — 发布脚本 | 无 `scripts/lint` 或 `scripts/format` |

**参考项目 evermemos-python 的 lint Job 模式：**

```
ci.yml → lint job → scripts/lint → ruff check → pyright → mypy → import 验证
```

### 1.2 目标

为 python_debug_helpers 添加：
1. CI lint 工作流（`.github/workflows/lint.yml`）
2. 本地 lint/format 脚本（`scripts/lint`、`scripts/format`）
3. 工具配置（`pyproject.toml` 中的 ruff/pyright/mypy 配置）
4. 操作手册文档

---

## 二、方案设计

### 2.1 与参考项目的差异适配

| 维度 | evermemos-python | python_debug_helpers | 适配决策 |
|------|-----------------|---------------------|---------|
| 包管理器 | uv | pip | 脚本中直接调用 `ruff`/`pyright`/`mypy`，不加 `uv run` 前缀 |
| CI runner | `depot-ubuntu-24.04` / `ubuntu-latest` | `ubuntu-latest` | 统一用 `ubuntu-latest` |
| Pyright 模式 | `strict` | — | 选择 `basic`，因为源码大量使用 `Any` + `hasattr` 动态模式 |
| MyPy 严格度 | 全部 `disallow_*` 开启 | — | 仅开启 `check_untyped_defs`，不强制类型标注 |
| Ruff 规则 | 含 `ARG`、`FA102`、`TC004` 等 | — | 选择 `E`+`F`+`I`+`B`+`T201` 基础规则集 |
| CI 触发条件 | push（排除 codegen 分支）+ fork PR | push/PR to main | 与现有 `test.yml` 保持一致 |
| Python 版本 | 多版本 + Pydantic 矩阵 | 单版本 3.12 | lint 不需要多版本矩阵 |

### 2.2 Pyright 模式选择理由

`print.py` 中大量使用动态类型模式：

```python
def _format_dict_recursive(data: Any, indent: int = 0) -> str:
    ...
    if hasattr(data, '__class__') and data.__class__.__name__ == 'ObjectId':
        ...
    elif hasattr(data, 'model_dump') and callable(data.model_dump):
        ...
```

`strict` 模式会对 `Any` 类型的属性访问、`hasattr` 后的属性调用产生大量报错。`basic` 模式允许这些动态模式，同时仍能捕获明显的类型错误。

---

## 三、实施过程

### 3.1 Step 1 — 修改 `pyproject.toml`

**添加 dev 依赖：**

```toml
# 变更前
[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
]

# 变更后
[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "ruff>=0.8.0",
    "pyright>=1.1.390",
    "mypy>=1.13",
]
```

**添加工具配置节：**

- `[tool.ruff]` — line-length=120, target-version="py39", 选择 E+F+I+B+T201 规则
- `[tool.ruff.lint.per-file-ignores]` — 允许 tests/examples/scripts/main.py 中使用 print
- `[tool.pyright]` — basic 模式, pythonVersion="3.9", 仅检查 src/
- `[tool.mypy]` — python_version="3.9", 仅检查 src/, 开启基本类型检查

### 3.2 Step 2 — 创建脚本

**`scripts/lint`** — 参考 evermemos-python 的 `scripts/lint`，适配为 pip 生态：

```bash
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

if [ "$1" = "--fix" ]; then
  echo "==> Running ruff with --fix"
  ruff check . --fix
else
  echo "==> Running ruff"
  ruff check .
fi

echo "==> Running pyright"
pyright

echo "==> Running mypy"
mypy src/

echo "==> Making sure it imports"
python -c 'import debug_helpers'
```

关键差异：evermemos 用 `uv run ruff check .`，本项目直接用 `ruff check .`（pip install 后命令已在 PATH 中）。

**`scripts/format`** — 与 evermemos 模式一致，三步执行：

```bash
ruff format → ruff check --fix → ruff format
```

第二次 `ruff format` 的原因：`ruff check --fix` 可能修改 import 排序，导致格式不一致。

两个脚本均设置了 `chmod +x`。

### 3.3 Step 3 — 创建 CI Workflow

**`.github/workflows/lint.yml`：**

```yaml
name: Lint
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with:
        python-version: '3.12'
        cache: 'pip'
    - run: pip install -e '.[dev]'
    - run: ./scripts/lint
```

设计决策：
- 使用 Python 3.12 单版本（lint 检查不需要多版本矩阵，与 test.yml 的多版本互补）
- `cache: 'pip'` 加速依赖安装
- `timeout-minutes: 10` 与 evermemos 一致

### 3.4 Step 4 — 首次运行 lint，发现并修复问题

**安装依赖：**

```bash
$ pip install -e '.[dev]'
# 安装了 ruff-0.15.0, pyright-1.1.408, mypy-1.19.1
```

**首次 ruff 运行结果（7 个错误）：**

```
examples/test.py:     12:1  I001  Import block is un-sorted or un-formatted
src/.../init__.py:    14:1  E402  Module level import not at top of file
src/.../main.py:       3:1  I001  Import block is un-sorted or un-formatted
src/.../print.py:      3:1  I001  Import block is un-sorted or un-formatted
src/.../print.py:     77:55 B009  Do not call getattr with a constant attribute value
src/.../print.py:     83:49 B009  Do not call getattr with a constant attribute value
tests/test_example.py: 3:1  I001  Import block is un-sorted or un-formatted
```

**修复过程：**

| 问题 | 数量 | 修复方式 |
|------|------|---------|
| I001 (import 排序) | 4 处 | `ruff check . --fix` 自动修复 |
| B009 (getattr 常量属性) | 2 处 | `ruff check . --fix` 自动修复，`getattr(data, 'model_dump')` → `data.model_dump` |
| E402 (import 不在顶部) | 1 处 | 手动修复 — 重构 `__init__.py`，将 `from .print import print_dict` 移到文件顶部 |

**`__init__.py` 重构详情：**

```python
# 变更前 — import 在函数定义之后（E402）
"""Python 调试工具包"""
__version__ = "0.4.0"

def hello(name: str) -> str: ...
def add(a: int, b: int) -> int: ...

from .print import print_dict  # ← E402: 不在顶部
__all__ = ['hello', 'add', 'print_dict']

# 变更后 — import 在文件顶部
"""Python 调试工具包"""
from .print import print_dict  # ← 移到顶部

__version__ = "0.4.0"

def hello(name: str) -> str: ...
def add(a: int, b: int) -> int: ...

__all__ = ["hello", "add", "print_dict"]
```

**运行 `./scripts/format` 后的额外变更：**

ruff format 对 4 个文件进行了格式化（空行、引号风格等）。

### 3.5 Step 5 — 最终验证

**lint 全部通过：**

```
$ ./scripts/lint
==> Running ruff
All checks passed!
==> Running pyright
0 errors, 0 warnings, 0 informations
==> Running mypy
Success: no issues found in 3 source files
==> Making sure it imports
```

**现有测试未受影响：**

```
$ pytest tests/ -v
tests/test_example.py::TestDebugHelpers::test_add PASSED
tests/test_example.py::TestDebugHelpers::test_hello PASSED
tests/test_example.py::TestDebugHelpers::test_print_dict PASSED
3 passed in 0.05s
```

---

## 四、变更文件清单

### 新增文件（4 个）

| 文件 | 作用 |
|------|------|
| `.github/workflows/lint.yml` | CI lint 工作流，push/PR to main 时自动触发 |
| `scripts/lint` | lint 执行脚本（ruff → pyright → mypy → import 验证） |
| `scripts/format` | 代码格式化脚本（ruff format + check fix） |
| `docs/05_ci_lint_guide.md` | lint 操作手册 |

### 修改文件（6 个）

| 文件 | 变更内容 |
|------|---------|
| `pyproject.toml` | +62 行：添加 ruff/pyright/mypy 依赖和工具配置 |
| `src/debug_helpers/__init__.py` | 重构 import 顺序（E402 修复），格式化引号 |
| `src/debug_helpers/main.py` | ruff 自动格式化（空行） |
| `src/debug_helpers/print.py` | B009 修复（getattr → 属性访问）+ import 排序 + 格式化 |
| `examples/test.py` | import 排序 + 格式化 |
| `tests/test_example.py` | import 排序 + 格式化 |

---

## 五、CI 流水线最终形态

```
push / PR to main
    │
    ├── lint.yml (新增)
    │   └── lint job (Python 3.12)
    │       ├── ruff check .          → 代码风格 + import 排序
    │       ├── pyright               → 类型检查 (basic)
    │       ├── mypy src/             → 类型检查
    │       └── python -c 'import ..' → 导入验证
    │
    ├── test.yml (已有)
    │   └── test job (Python 3.9~3.13 矩阵)
    │       └── pytest + coverage
    │
    └── publish.yml (已有, 仅 tag 触发)
        └── build → twine check → TestPyPI → PyPI → GitHub Release
```

---

## 六、后续可优化方向

| 方向 | 说明 | 优先级 |
|------|------|--------|
| 提升 Pyright 到 `standard` 模式 | 逐步加强类型检查，需要为动态代码添加类型标注 | 低 |
| 开启 MyPy `disallow_untyped_defs` | 强制所有函数添加类型标注 | 低 |
| 添加 Ruff `UP` 规则 | 自动升级到新语法（如 `dict` 替代 `Dict`） | 中 |
| 添加 pre-commit hooks | 提交前自动运行 lint + format | 中 |
| 将 lint 和 test 合并为一个 ci.yml | 参考 evermemos 模式，多 job 并行 | 低 |
