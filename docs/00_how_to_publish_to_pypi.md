# 如何创建简单项目并上传到 PyPI

本指南将帮助你创建一个简单的 Python 项目并将其发布到 PyPI。

## 前置要求

1. Python 3.9 或更高版本
2. 已安装 `uv` 包管理器（推荐）或 `pip`
3. PyPI 账号（如果没有，请在 [pypi.org](https://pypi.org) 注册）
   1. https://test.pypi.org/
   2. https://pypi.org/

## 步骤 1: 创建项目结构

创建一个新的项目目录，并设置基本的项目结构：

```bash
# 创建项目目录
mkdir my_package
cd my_package

# 使用 uv 初始化项目（推荐）
uv init

# 或者手动创建目录结构
mkdir -p src/my_package tests
```

项目结构示例：
```
my_package/
├── src/
│   └── my_package/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── __init__.py
├── pyproject.toml
├── README.md
└── LICENSE
```

## 步骤 2: 创建源代码

在 `src/my_package/__init__.py` 中添加你的包代码：

```python
"""一个简单的 Python 包示例"""

__version__ = "0.1.0"

def hello(name: str) -> str:
    """返回问候语"""
    return f"Hello, {name}!"
```

## 步骤 3: 配置 pyproject.toml

### 3.1 选择包名

在配置 `pyproject.toml` 之前，你需要选择一个合适的包名。包名选择非常重要，因为：
- PyPI 上的包名必须是唯一的
- 包名一旦上传就无法更改
- 好的包名有助于用户发现和使用你的包

**包名选择原则**：

1. **使用描述性名称**：包名应该清楚地表达包的用途
   - ✅ `image-processor` - 清楚表达功能
   - ❌ `tool` - 太通用，没有描述性

2. **使用小写字母和连字符**：遵循 Python 包命名规范
   - ✅ `my-awesome-package`
   - ❌ `MyAwesomePackage`（包含大写字母）

3. **添加用户名前缀（可选）**：如果担心重名，可以使用 `username-package-name` 格式
   - ✅ `yeannhua-example-package`
   - ✅ `yourname-my-tool`

4. **检查可用性**：上传前务必检查包名是否已被占用
   ```bash
   # 在浏览器中访问
   https://pypi.org/project/你的包名/
   ```

5. **关于示例项目中的 `example-package-demo`**：
   - 这个名字仅用于演示和教程目的
   - `example` 表示这是一个示例项目
   - `package-demo` 表示这是一个包演示
   - **实际上传时，这个名字很可能已被占用，需要修改为唯一的名称**

### 3.2 创建 pyproject.toml

创建 `pyproject.toml` 文件，这是现代 Python 项目的标准配置文件：

```toml
[project]
name = "my-package"
version = "0.1.0"
description = "一个简单的 Python 包示例"
readme = "README.md"
requires-python = ">=3.9"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

[project.urls]
Homepage = "https://github.com/yourusername/my-package"
Repository = "https://github.com/yourusername/my-package"
Issues = "https://github.com/yourusername/my-package/issues"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]
```

重要字段说明：
- `name`: 包名（必须是唯一的，只能包含小写字母、数字、连字符和下划线）
  - **包名选择原则**：
    - 应该简洁、描述性强
    - 建议使用小写字母和连字符（如 `my-package`）
    - 如果担心重名，可以加上用户名前缀（如 `username-my-package`）
    - 示例项目使用 `example-package-demo` 仅用于演示，实际上传时需要改为唯一名称
- `version`: 版本号（遵循语义化版本规范）
- `description`: 包的简短描述
- `requires-python`: 支持的 Python 版本
- `authors`: 作者信息

## 步骤 4: 创建 README.md

创建 `README.md` 文件，描述你的项目：

```markdown
# My Package

一个简单的 Python 包示例。

## 安装

```bash
pip install my-package
```

## 使用方法

```python
from my_package import hello

print(hello("World"))
```

## 许可证

MIT License
```

## 步骤 5: 安装构建工具

安装构建和上传所需的工具：

```bash
# 使用 uv（推荐）
uv pip install build twine

# 或使用 pip（全局安装）
pip install build twine

# 或使用 pip（用户目录安装，推荐）
pip install --user build twine
```

**注意**：如果使用 `--user` 安装，工具会安装到用户目录。如果命令行找不到 `build` 或 `twine`，可以使用模块方式运行：
- `python3 -m build` 代替 `build`
- `python3 -m twine` 代替 `twine`

## 步骤 6: 构建分发包

构建源代码分发包（sdist）和轮子文件（wheel）：

```bash
# 使用 uv
uv build

# 或使用标准工具
python3 -m build
# 或
python -m build
```

**构建过程说明**：
- 构建工具会自动创建隔离环境并安装 `hatchling`
- 会生成两个文件：源代码分发包（.tar.gz）和轮子文件（.whl）
- 构建成功后会在 `dist/` 目录下生成文件

这会在 `dist/` 目录下生成两个文件：
- `my-package-0.1.0.tar.gz` (源代码分发包)
- `my_package-0.1.0-py3-none-any.whl` (轮子文件)

**验证构建结果**：
```bash
# 查看生成的文件
ls -lh dist/

# 应该看到类似输出：
# example-package-0.1.0-py3-none-any.whl
# example-package-0.1.0.tar.gz
```

## 步骤 7: 检查分发包

在上传之前，检查分发包是否正确：

```bash
# 检查分发包（如果 twine 在 PATH 中）
twine check dist/*

# 或使用模块方式
python3 -m twine check dist/*
```

**检查内容**：
- 验证包的元数据是否正确
- 检查 README 格式是否正确
- 验证分发包的完整性

**预期输出**：
```
Checking dist/my-package-0.1.0-py3-none-any.whl: PASSED
Checking dist/my-package-0.1.0.tar.gz: PASSED
```

如果检查失败，请根据错误信息修复问题后重新构建。

## 步骤 8: 上传到 PyPI

### 8.1 重要说明：TestPyPI 和正式 PyPI 是不同的平台

**关键区别**：
- **TestPyPI** (https://test.pypi.org) - 测试平台，用于测试上传流程
- **正式 PyPI** (https://pypi.org) - 正式平台，包会被全球用户使用

**重要**：
- TestPyPI 和正式 PyPI **需要分别注册账号**（可以使用相同的用户名和密码，但需要分别注册）
- TestPyPI 和正式 PyPI **需要使用不同的 API token**
- 两个平台的 token **不能混用**

### 8.2 创建 API Token

#### 为 TestPyPI 创建 Token（推荐先测试）

1. 访问 [test.pypi.org](https://test.pypi.org) 并注册账号（如果还没有）
2. 登录后，进入 Account settings → API tokens
3. 创建新的 API token（选择 "Entire account" 或特定项目）
4. 复制生成的 token（格式：`pypi-...`，但来自 TestPyPI）

#### 为正式 PyPI 创建 Token

1. 访问 [pypi.org](https://pypi.org) 并注册账号（如果还没有）
2. 登录后，进入 Account settings → API tokens
3. 创建新的 API token（选择 "Entire account" 或特定项目）
4. 复制生成的 token（格式：`pypi-...`，来自正式 PyPI）

### 8.3 配置认证

#### 方式 1: 使用环境变量（推荐）

**上传到 TestPyPI：**
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
```

**上传到正式 PyPI：**
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token
```

#### 方式 2: 使用配置文件 `~/.pypirc`

创建或编辑 `~/.pypirc` 文件：

```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-你的正式pypi-token

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-你的testpypi-token
```

#### 方式 3: 交互式输入（最安全）

不设置环境变量，直接运行命令，twine 会提示输入用户名和密码。

### 8.4 上传到 PyPI

**步骤 1: 测试上传到 TestPyPI（强烈推荐先测试）**

```bash
# 设置 TestPyPI token
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token

# 上传到 TestPyPI
python3 -m twine upload --repository testpypi dist/*

# 上传成功后，可以在以下地址查看你的包：
# https://test.pypi.org/project/你的包名/

# 从 TestPyPI 安装测试
pip install -i https://test.pypi.org/simple/ 你的包名
```

**关于包名 `example-package-demo` 的说明**：
- 这是示例项目中使用的演示包名
- `example` 表示这是一个示例/演示项目
- `package-demo` 表示这是一个包演示
- **重要**：这个名字仅用于演示目的，实际上传到 PyPI 时：
  - 这个名字很可能已被占用
  - 需要修改为唯一的包名（如 `yourname-example-package` 或 `your-project-name`）
  - 包名一旦上传就无法更改，请谨慎选择

```

**步骤 2: 上传到正式 PyPI**

```bash
# 设置正式 PyPI token（注意：这是不同的 token！）
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token

# 上传到正式 PyPI
python3 -m twine upload dist/*
# 或
python3 -m twine upload --repository pypi dist/*

# 上传成功后，可以在以下地址查看你的包：
# https://pypi.org/project/你的包名/版本号/
# 例如：https://pypi.org/project/your-package-name/0.1.0/

```

**重要提示**：
- 上传前确保包名是唯一的（PyPI 不允许重复的包名）
- 如果包名已被占用，需要修改 `pyproject.toml` 中的 `name` 字段
- 上传后包名无法更改，请谨慎选择
- 建议先上传到 TestPyPI 测试

上传成功后，你的包就可以通过 `pip install my-package` 安装了！

**验证上传**：
```bash
# 等待几分钟后，尝试安装
pip install my-package

# 或从 PyPI 网站查看
# https://pypi.org/project/my-package/
```

## 步骤 9: 更新版本

当你需要发布新版本时：

1. 更新 `pyproject.toml` 中的 `version` 字段
2. 更新 `src/my_package/__init__.py` 中的 `__version__`
3. 重新构建和上传：

```bash
uv build
twine upload dist/*
```

## 常见问题

### 1. 包名已被占用

如果包名已被占用，你需要：
- 选择一个不同的包名（推荐）
- 或者联系当前包的所有者（如果包已不再维护）

**如何检查包名是否可用**：
```bash
# 在浏览器中访问
https://pypi.org/project/你的包名/

# 如果显示 404 或 "This project does not exist"，说明包名可用
# 如果显示包的信息，说明已被占用
```

**包名选择建议**：
1. **使用描述性名称**：`my-awesome-tool` 比 `tool` 更好
2. **添加用户名前缀**：如果担心重名，使用 `username-package-name` 格式
   - 例如：`yeannhua-example-package`（如示例项目中的修改）
3. **检查可用性**：上传前务必检查包名是否可用
4. **保持一致性**：包名应该与项目目录名、GitHub 仓库名等相关

**修改包名步骤**：
1. 修改 `pyproject.toml` 中的 `name` 字段
2. 重新构建：`python3 -m build`
3. 清理旧的构建文件：`rm -rf dist/ build/ *.egg-info`
4. 重新构建并上传

### 2. 上传失败：认证错误

确保：
- API token 正确
- 使用 `__token__` 作为用户名
- token 有正确的权限

### 3. 版本号格式错误

版本号必须遵循 [PEP 440](https://peps.python.org/pep-0440/) 规范，例如：
- `0.1.0` ✅
- `1.0.0` ✅
- `1.0.0-alpha.1` ✅
- `v1.0.0` ❌（不要加 v 前缀）

### 4. 依赖管理

如果项目有依赖，在 `pyproject.toml` 中添加：

```toml
[project]
dependencies = [
    "requests>=2.28.0",
    "click>=8.0.0",
]
```

### 5. 命令找不到：build 或 twine

如果系统提示找不到 `build` 或 `twine` 命令：

**解决方案**：
```bash
# 使用模块方式运行（推荐）
python3 -m build
python3 -m twine check dist/*
python3 -m twine upload dist/*

# 或添加到 PATH（如果使用 --user 安装）
# macOS/Linux: 添加到 ~/.zshrc 或 ~/.bashrc
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
```

### 6. 构建失败：找不到 hatchling

如果构建时提示找不到 `hatchling`：

**解决方案**：
```bash
# 确保 pyproject.toml 中配置了正确的构建系统
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# 构建工具会自动安装 hatchling，无需手动安装
```

### 7. 上传失败：HTTP 403 或 401 错误

**可能原因**：
- API token 错误或已过期
- 使用了错误的用户名（应使用 `__token__`）
- token 权限不足
- **使用了错误的 token（TestPyPI token 用于正式 PyPI，或反之）**

**解决方案**：
```bash
# 1. 检查环境变量
echo $TWINE_USERNAME  # 应该是 __token__
echo $TWINE_PASSWORD  # 应该是 pypi-开头的token

# 2. 确认使用的是正确的 token
# - 上传到 TestPyPI：使用 test.pypi.org 的 token
# - 上传到正式 PyPI：使用 pypi.org 的 token

# 3. 重新创建 API token
# TestPyPI: https://test.pypi.org/manage/account/token/
# 正式 PyPI: https://pypi.org/manage/account/token/

# 4. 使用交互式输入（更安全）
python3 -m twine upload dist/*
# 然后按提示输入用户名和密码
```

**常见错误**：
- ❌ 使用 TestPyPI token 上传到正式 PyPI → 会失败
- ❌ 使用正式 PyPI token 上传到 TestPyPI → 会失败
- ✅ 确保 token 和上传目标匹配

### 8. 包名格式错误

包名必须遵循以下规则：
- 只能包含小写字母、数字、连字符（-）和下划线（_）
- 不能以连字符或下划线开头或结尾
- 不能包含连续的点（.）

**正确示例**：
- `my-package` ✅
- `my_package` ✅
- `my-package-123` ✅

**错误示例**：
- `My-Package` ❌（包含大写字母）
- `-my-package` ❌（以连字符开头）
- `my..package` ❌（连续的点）

## 使用 uv 的完整工作流

如果你使用 `uv` 管理项目，完整的工作流如下：

```bash
# 1. 初始化项目
uv init my_package
cd my_package

# 2. 添加依赖（如果需要）
uv add requests

# 3. 配置 pyproject.toml（手动编辑）

# 4. 构建
uv build

# 5. 检查分发包
python3 -m twine check dist/*

# 6. 上传
python3 -m twine upload dist/*
```

## 实际示例项目

在 `pypi/example_package/` 目录下有一个完整的示例项目，展示了所有步骤的实际执行结果：

```
example_package/
├── src/
│   └── example_package/
│       ├── __init__.py      # 包含 hello() 和 add() 函数
│       └── main.py          # 示例主模块
├── tests/
│   ├── __init__.py
│   └── test_example.py      # 单元测试
├── dist/                    # 构建输出目录
│   ├── example_package_demo-0.1.0-py3-none-any.whl
│   └── example_package_demo-0.1.0.tar.gz
├── pyproject.toml           # 项目配置
├── README.md                # 项目说明
├── LICENSE                  # MIT 许可证
└── UPLOAD_INSTRUCTIONS.md   # 上传说明
```

你可以参考这个示例项目来了解实际的项目结构和配置。

## 参考资源

- [PyPI 官方文档](https://packaging.python.org/)
- [PEP 517 - 构建系统](https://peps.python.org/pep-0517/)
- [PEP 621 - 项目元数据](https://peps.python.org/pep-0621/)
- [uv 文档](https://github.com/astral-sh/uv)

## 快速参考命令

完整的命令序列（假设使用标准 Python 工具）：

```bash
# 1. 创建项目结构
mkdir my_package && cd my_package
mkdir -p src/my_package tests

# 2. 创建源代码文件
# ... 编辑 src/my_package/__init__.py ...

# 3. 创建配置文件
# ... 创建 pyproject.toml, README.md, LICENSE ...

# 4. 安装构建工具
pip install --user build twine

# 5. 构建分发包
python3 -m build

# 6. 检查分发包
python3 -m twine check dist/*

# 7. 设置认证（使用环境变量）
# 注意：TestPyPI 和正式 PyPI 需要使用不同的 token！

# 7a. 上传到 TestPyPI（推荐先测试）
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
python3 -m twine upload --repository testpypi dist/*

# 7b. 上传到正式 PyPI（使用不同的 token）
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token
python3 -m twine upload dist/*
```

## 总结

发布 Python 包到 PyPI 的基本步骤：

1. ✅ 创建项目结构和代码
2. ✅ 配置 `pyproject.toml`
3. ✅ 创建 `README.md` 和 `LICENSE`
4. ✅ 安装构建工具（`build`, `twine`）
5. ✅ 构建分发包（`uv build` 或 `python3 -m build`）
6. ✅ 检查分发包（`python3 -m twine check dist/*`）
7. ✅ 获取 PyPI API token
8. ✅ 上传到 TestPyPI 测试（推荐）
9. ✅ 上传到正式 PyPI（`python3 -m twine upload dist/*`）

完成这些步骤后，你的包就可以被全世界的 Python 开发者使用了！

**提示**：如果遇到问题，请参考 `pypi/example_package/` 目录下的示例项目，或查看 `UPLOAD_INSTRUCTIONS.md` 获取更多帮助。
