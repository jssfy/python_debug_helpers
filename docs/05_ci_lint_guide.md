# CI Lint 静态检查操作手册

## 核心结论

- 项目使用 **3 个工具** 进行静态检查：Ruff（lint + 格式化）→ Pyright（类型检查）→ MyPy（类型检查）
- CI 中通过 `.github/workflows/lint.yml` 自动触发，与测试流水线并行运行
- 本地通过 `./scripts/lint` 和 `./scripts/format` 执行
- 所有配置集中在 `pyproject.toml` 中

---

## 一、工具介绍

### 1.1 Ruff — Linter + Formatter

**作用：** 用 Rust 编写的 Python **lint + 格式化** 二合一工具，替代了以前需要多个工具组合的场景：

| Ruff 功能 | 命令 | 替代的旧工具 |
|-----------|------|------------|
| 代码规则检查 | `ruff check` | flake8, pylint, isort |
| 代码格式化 | `ruff format` | black |

速度比 Python 原生工具快 10~100 倍。

**本项目启用的检查规则：**

| 规则代码 | 含义 | 示例 |
|---------|------|------|
| `E` | pycodestyle 错误 | 缩进错误、空格问题 |
| `F` | pyflakes | 未使用的导入、未定义变量 |
| `I` | isort | import 排序不正确 |
| `B` | bugbear | 常见 bug 模式（可变默认参数等） |
| `T201` | print 语句 | 生产代码中不应有 print() |

**配置位置：** `pyproject.toml` → `[tool.ruff]`

### 1.2 Pyright — 静态类型检查器

**作用：** 微软开发的 Python 类型检查器（VS Code Pylance 的内核），**不运行代码，仅通过静态分析就能发现类型相关的 bug**。

**检查模式：** `basic`（基础模式），适合本项目的动态类型风格。

**配置位置：** `pyproject.toml` → `[tool.pyright]`

**basic 模式能捕获的典型错误：**

**示例 1 — 参数类型错误：**

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"

greet(123)  # 传入 int，但函数要求 str
```

```
error: Argument of type "Literal[123]" cannot be assigned to parameter "name"
       of type "str" in function "greet" (reportArgumentType)
```

**示例 2 — 返回值类型错误：**

```python
def get_count() -> int:
    return "not a number"  # 返回 str，但声明返回 int
```

```
error: Type "Literal['not a number']" is not assignable to return type "int"
       (reportReturnType)
```

**示例 3 — 属性不存在：**

```python
text: str = "hello"
text.nonexistent_method()  # str 没有这个方法
```

```
error: Cannot access attribute "nonexistent_method" for class "Literal['hello']"
       (reportAttributeAccessIssue)
```

**示例 4 — None 安全问题（最实用）：**

```python
from typing import Optional

def find_user(user_id: int) -> Optional[str]:
    if user_id == 1:
        return "Alice"
    return None

user = find_user(2)
print(user.upper())  # user 可能是 None，直接调用 .upper() 不安全
```

```
error: "upper" is not a known attribute of "None" (reportOptionalMemberAccess)
```

正确写法应先判空：

```python
user = find_user(2)
if user is not None:
    print(user.upper())  # Pyright 知道这里 user 一定是 str
```

**示例 5 — 容器元素类型不匹配：**

```python
numbers: list[int] = [1, 2, 3]
numbers.append("four")  # 列表元素应该是 int
```

```
error: Argument of type "Literal['four']" cannot be assigned to parameter
       "object" of type "int" in function "append" (reportArgumentType)
```

这些错误如果不用 Pyright，只有在**运行时**才会发现（甚至可能不报错而是产生隐蔽 bug）。Pyright 在 CI 阶段就能提前拦截。

### 1.3 MyPy — 静态类型检查器

**作用：** Python 官方社区推荐的类型检查器（由 Guido van Rossum 发起）。

**检查范围：** 仅检查 `src/` 目录，排除 tests/examples/scripts。

**配置位置：** `pyproject.toml` → `[tool.mypy]`

### 1.4 为什么同时使用 Pyright 和 MyPy

两者都是类型检查器，但**实现不同、侧重不同、能捕获的问题存在互补盲区**：

| 维度 | Pyright | MyPy |
|------|---------|------|
| 开发方 | 微软（VS Code / Pylance 内核） | Python 官方社区（Guido 发起） |
| 实现语言 | TypeScript（速度快） | Python（速度较慢） |
| 类型推断 | 更激进，能推断更多未标注的类型 | 更保守，依赖显式标注 |
| 侧重点 | 类型流分析（narrowing）、泛型推断 | 协议检查、插件生态（Django/SQLAlchemy 等） |
| 编辑器集成 | VS Code 实时提示（Pylance） | 主要用于 CI |

**互补场景举例：**

| 场景 | Pyright | MyPy |
|------|---------|------|
| 未标注函数中的类型不匹配 | 能推断并报错 | 可能跳过（推断能力弱） |
| 复杂泛型 + `isinstance` 窄化 | 精确推断 | 部分场景不够精确 |
| `# type: ignore` 注释滥用 | 不检查 | `warn_unused_ignores` 能发现 |
| Django/SQLAlchemy 模型类型 | 无插件支持 | 有专用插件（mypy-django 等） |

**本项目中两者的作用范围：**

| 检查器 | 检查范围 | 模式 | 配置项 |
|--------|---------|------|--------|
| Pyright | `src/` 目录 | `basic`（基础） | `include = ["src"]` |
| MyPy | `src/` 目录 | 基础严格 | `files = ["src/"]`，排除 tests/examples/scripts |

两者都**只检查 `src/`**，不检查 tests/examples/scripts。

**成本：** 多加一个工具仅增加几秒 CI 时间。FastAPI、Pydantic、httpx 等主流项目也采用双检查器策略。

**如果想精简：** 可以只保留一个，优先保留 Pyright（推断能力更强、速度更快）。

---

## 二、本地使用

### 2.1 安装依赖

```bash
pip install -e '.[dev]'
```

这条命令由两部分组成：

| 部分 | 含义 |
|------|------|
| `-e .` | **可编辑安装**（editable install）— 把当前目录的包以"链接"方式安装到 Python 环境，修改源码后立即生效，无需重新 install |
| `[dev]` | 同时安装 `pyproject.toml` 中 `[project.optional-dependencies]` 下 `dev` 组的额外依赖 |

实际效果：
1. 把 `debug_helpers` 包以可编辑模式安装（`import debug_helpers` 直接指向 `src/debug_helpers/`）
2. 安装 dev 组的全部工具：pytest、pytest-cov、ruff、pyright、mypy

**对比不加 `-e`：** `pip install '.[dev]'` 会把源码**复制**到 site-packages，改了源码需要重新 install 才能生效。加 `-e` 开发时更方便。

### 2.2 运行静态检查

```bash
# 运行全部检查（ruff + pyright + mypy + import 验证）
./scripts/lint

# 自动修复可修复的问题
./scripts/lint --fix
```

**执行顺序和输出示例：**

```
==> Running ruff
All checks passed!
==> Running pyright
0 errors, 0 warnings, 0 informations
==> Running mypy
Success: no issues found in 3 source files
==> Making sure it imports
```

任意一步失败都会立即终止（`set -e`），返回非零退出码。

### 2.3 代码格式化

```bash
./scripts/format
```

**执行流程（三步，顺序不可变）：**

```
第 1 步: ruff format            ← 格式化所有 .py 文件
第 2 步: ruff check --fix .     ← 自动修复 lint 问题（删除未使用 import、重排 import 等）
第 3 步: ruff format            ← 再次格式化
```

**为什么要执行两次 `ruff format`？**

关键在第 2 步 `ruff check --fix`。它会**修改代码内容**（删除 import、重新排序 import 等），而这些修改可能**破坏第 1 步已经做好的格式**：

```python
# ── 第 1 步 ruff format 后（格式正确）──
import os
import sys
import json
from typing import Any, Optional

# ── 第 2 步 ruff check --fix 后（删除了未使用的 os、sys、Optional）──
import json
from typing import Any
                          # ← 可能多出空行，行间距不符合格式规范
```

第 3 步 `ruff format` 就是把第 2 步造成的格式不一致修正回来，**确保最终输出既通过 lint 检查，又符合格式规范**。

如果只执行一次 format，后续 CI 中运行 `ruff format --check` 可能会报 diff。

**建议工作流：** 提交代码前先运行 `./scripts/format`，再运行 `./scripts/lint` 确认。

### 2.5 各命令是否修改文件

> **关键区别：** `lint` 默认只读不改文件，`format` 会直接改文件。

| 命令 | 是否修改文件 | 修改范围 | 用途 |
|------|:-----------:|---------|------|
| `./scripts/lint` | **否** | — | CI 中检查，有问题报错退出，不动代码 |
| `./scripts/lint --fix` | **是** | 仅 ruff 可自动修复的项（如 import 排序） | 快速修复 lint 问题 |
| `./scripts/format` | **是** | 项目中所有 `.py` 文件（`src/`、`tests/`、`examples/`） | 提交前统一代码风格 |

**详细说明：**

**`./scripts/lint`（无参数）— 纯只读检查，不改任何文件：**

```
ruff check .           → 只报告问题，不修改
pyright                → 只报告问题，不修改
mypy src/              → 只报告问题，不修改
python -c 'import ...' → 只验证，不修改
```

**`./scripts/lint --fix` — 仅 ruff 会修改文件：**

```
ruff check . --fix     → 自动修复可修复的问题（如 import 排序、未使用的 import）
pyright                → 只读，不修改
mypy src/              → 只读，不修改
```

Pyright 和 MyPy **始终只读**，无论是否加 `--fix`。

**`./scripts/format` — 修改所有 .py 文件：**

```
ruff format            → 格式化（缩进、引号风格、空行、尾逗号等）
ruff check --fix .     → 修复 lint 问题（import 排序等）
ruff format            → 再次格式化（确保一致性）
```

会触及项目中每个 `.py` 文件，但只有实际需要变更的文件会被写入。

### 2.4 单独运行某个工具

```bash
# 仅运行 ruff
ruff check .
ruff check . --fix    # 自动修复
ruff format           # 格式化

# 仅运行 pyright
pyright

# 仅运行 mypy
mypy src/
```

---

## 三、CI 自动触发

### 3.1 触发条件

| 事件 | 分支 |
|------|------|
| `push` | `main` |
| `pull_request` | → `main` |

与测试工作流 (`test.yml`) 的触发条件完全一致。

### 3.2 checkout 的分支

`actions/checkout@v4` 会根据触发事件自动选择 checkout 的内容：

| 触发事件 | checkout 的内容 | 对应 Git ref |
|---------|----------------|-------------|
| `push` to main | **main 分支**上刚推送的那个 commit | `refs/heads/main` |
| `pull_request` to main | GitHub 自动创建的**临时合并 commit** | `refs/pull/{number}/merge` |

`pull_request` 场景的重点：checkout 的**不是 PR 分支本身**，而是 GitHub 在后台模拟的「如果把 PR 合并到 main 后会是什么样」。这样 lint 检查的是合并后的代码状态，能提前发现合并冲突导致的问题。

### 3.3 CI 执行流程

```
┌─────────────────────────────┐
│ 触发: push/PR to main       │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────────────────┐
│ actions/checkout@v4                      │
│   push → checkout main 最新 commit      │
│   PR   → checkout 模拟合并后的 commit    │
├─────────────────────────────────────────┤
│ actions/setup-python@v5                  │
│   Python 3.12 + pip cache               │
└──────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────┐
│ pip install -e '.[dev]'     │
│  安装 ruff + pyright + mypy  │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────────────┐
│ ./scripts/lint                       │
│  1. ruff check .     → lint 检查    │
│  2. pyright          → 类型检查     │
│  3. mypy src/        → 类型检查     │
│  4. python -c '...'  → 导入验证     │
└─────────────────────────────────────┘
```

### 3.4 涉及的文件

| 文件 | 作用 |
|------|------|
| `.github/workflows/lint.yml` | CI Workflow 定义 |
| `scripts/lint` | lint 执行脚本 |
| `pyproject.toml` | 工具配置 + 依赖声明 |
| `src/**/*.py` | 被检查的源代码 |

### 3.5 与其他 Workflow 的关系

```
push/PR to main
    ├── lint.yml   → 静态检查（ruff + pyright + mypy）
    └── test.yml   → 单元测试（pytest，多 Python 版本矩阵）
```

两个 Workflow **并行运行**，互不依赖。

---

## 四、常见问题排查

### 4.1 Ruff 报错：import 排序不正确 (I001)

```
src/debug_helpers/__init__.py:
  3:1 I001 [*] Import block is un-sorted or un-formatted
```

**解决：** 运行 `./scripts/format` 自动修复，或 `ruff check . --fix`。

### 4.2 Ruff 报错：print 语句 (T201)

```
src/debug_helpers/some_file.py:
  10:5 T201 `print` found
```

**解决方式取决于场景：**

- **生产代码：** 使用 `logging` 替代 `print`
- **调试代码/示例/测试：** 已在 `pyproject.toml` 中通过 `per-file-ignores` 豁免 `tests/`、`examples/`、`scripts/` 目录
- **临时忽略某行：** 在行尾添加 `# noqa: T201`

### 4.3 Ruff 报错：模块级 import 不在文件顶部 (E402)

```
src/debug_helpers/__init__.py:
  14:1 E402 Module level import not at top of file
```

**解决：** 将 import 语句移到文件顶部（`__version__` 和函数定义之前）。

### 4.4 Pyright 报错：类型不匹配

```
error: Expression of type "str | None" is not assignable to type "str"
```

**解决方式：**

```python
# 方式一：添加类型断言
assert value is not None
use_value(value)

# 方式二：添加默认值
value = get_value() or "default"

# 方式三：添加类型忽略注释（不推荐）
use_value(value)  # type: ignore[arg-type]
```

### 4.5 MyPy 报错：缺少类型标注

```
error: Function is missing a return type annotation  [no-untyped-def]
```

**当前配置不会报此错**（未开启 `disallow_untyped_defs`）。如果将来想加强类型要求，可在 `pyproject.toml` 中开启：

```toml
[tool.mypy]
disallow_untyped_defs = true
```

### 4.6 想要跳过某条规则

**Ruff — 行级忽略：**
```python
x = eval("1+1")  # noqa: S307
```

**Ruff — 文件级忽略：**
在 `pyproject.toml` 的 `[tool.ruff.lint.per-file-ignores]` 中添加：
```toml
"src/some_file.py" = ["T201"]
```

**Pyright — 行级忽略：**
```python
result = dynamic_call()  # type: ignore[reportGeneralIssue]
```

**MyPy — 行级忽略：**
```python
result = dynamic_call()  # type: ignore[misc]
```

---

## 五、配置速查

所有配置均在 `pyproject.toml` 中：

```toml
# ── 开发依赖 ──
[project.optional-dependencies]
dev = [
    "ruff>=0.8.0",
    "pyright>=1.1.390",
    "mypy>=1.13",
    ...
]

# ── Ruff ──
[tool.ruff]
line-length = 120
target-version = "py39"

# ── Pyright ──
[tool.pyright]
typeCheckingMode = "basic"
pythonVersion = "3.9"

# ── MyPy ──
[tool.mypy]
python_version = "3.9"
files = ["src/"]
```

如需调整规则严格程度，修改以下关键字段：

| 调整目标 | 配置项 | 当前值 | 更严格 |
|---------|--------|--------|--------|
| Ruff 检查规则 | `[tool.ruff.lint] select` | E, F, I, B, T201 | 添加 `"UP"`, `"SIM"`, `"ARG"` |
| Pyright 严格程度 | `typeCheckingMode` | `"basic"` | `"standard"` → `"strict"` |
| MyPy 要求类型标注 | `disallow_untyped_defs` | 未开启 | `true` |
