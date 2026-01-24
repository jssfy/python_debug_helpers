# 上传到 PyPI 的说明

## 当前状态

✅ 项目已创建并构建完成
✅ 分发包已生成在 `dist/` 目录：
- `example_package_demo-0.1.0-py3-none-any.whl` (2.9KB)
- `example_package_demo-0.1.0.tar.gz` (2.1KB)
✅ 分发包检查通过

## 下一步：上传到 PyPI

### ⚠️ 重要：TestPyPI 和正式 PyPI 需要使用不同的 Token

**关键区别**：
- **TestPyPI** (https://test.pypi.org) 和 **正式 PyPI** (https://pypi.org) 是**两个不同的平台**
- 需要**分别注册账号**（可以使用相同的用户名和密码，但需要分别注册）
- 需要**分别创建不同的 API token**
- **两个平台的 token 不能混用**

### 选项 1: 上传到 TestPyPI（强烈推荐先测试）

```bash
# 1. 在 https://test.pypi.org 注册账号（如果还没有）
#    注意：即使你在 pypi.org 有账号，也需要在 test.pypi.org 单独注册

# 2. 创建 TestPyPI API token: https://test.pypi.org/manage/account/token/
#    这个 token 只能用于 TestPyPI，不能用于正式 PyPI

# 3. 设置 TestPyPI token
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token

# 4. 上传到 TestPyPI
python3 -m twine upload --repository testpypi dist/*

# 5. 测试安装
pip install -i https://test.pypi.org/simple/ example-package-demo
```

### 选项 2: 上传到正式 PyPI

```bash
# 1. 在 https://pypi.org 注册账号（如果还没有）
#    注意：即使你在 test.pypi.org 有账号，也需要在 pypi.org 单独注册

# 2. 创建正式 PyPI API token: https://pypi.org/manage/account/token/
#    注意：包名 "example-package-demo" 可能已被占用，需要修改 pyproject.toml 中的 name
#    这个 token 只能用于正式 PyPI，不能用于 TestPyPI

# 3. 设置正式 PyPI token（注意：这是不同的 token！）
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token

# 4. 上传到正式 PyPI
python3 -m twine upload dist/*
```

## 重要提示

⚠️ **包名冲突**: `example-package-demo` 可能已被占用。如果要实际上传，需要：
1. 修改 `pyproject.toml` 中的 `name` 字段为一个唯一的名称
2. 重新构建: `python3 -m build`
3. 然后上传

⚠️ **Token 使用错误**: 
- ❌ 不要使用 TestPyPI token 上传到正式 PyPI
- ❌ 不要使用正式 PyPI token 上传到 TestPyPI
- ✅ 确保 token 和上传目标匹配

## 项目结构

```
example_package/
├── src/
│   └── example_package/
│       ├── __init__.py      # 包的主要代码
│       └── main.py          # 示例主模块
├── tests/
│   ├── __init__.py
│   └── test_example.py      # 测试文件
├── dist/                    # 构建输出目录
│   ├── example_package_demo-0.1.0-py3-none-any.whl
│   └── example_package_demo-0.1.0.tar.gz
├── pyproject.toml           # 项目配置
├── README.md                # 项目说明
├── LICENSE                  # MIT 许可证
└── UPLOAD_INSTRUCTIONS.md   # 本文件
```

## 验证安装

上传后，可以通过以下方式验证：

```bash
# 创建新的虚拟环境测试
python3 -m venv test_env
source test_env/bin/activate
pip install example-package-demo

# 测试导入
python -c "from example_package import hello, add; print(hello('World')); print(add(1, 2))"
```
