# 发布指南

本指南说明如何发布 `yeannhua-example-package-demo` 包的新版本。

## 前置要求

1. 已安装 `build` 和 `twine`
   ```bash
   pip install --user build twine
   ```

2. 已在 TestPyPI 和正式 PyPI 注册账号
   - TestPyPI: https://test.pypi.org/account/register/
   - 正式 PyPI: https://pypi.org/account/register/

3. 已创建 API Token
   - TestPyPI token: https://test.pypi.org/manage/account/token/
   - 正式 PyPI token: https://pypi.org/manage/account/token/

## 发布流程

### 步骤 1: 更新版本号

在以下文件中更新版本号：

1. `pyproject.toml` - 修改 `version` 字段
2. `src/example_package/__init__.py` - 修改 `__version__` 变量

版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：
- MAJOR.MINOR.PATCH (例如: 0.2.0)
- MAJOR: 不兼容的 API 修改
- MINOR: 向下兼容的功能性新增
- PATCH: 向下兼容的问题修正

### 步骤 2: 更新 CHANGELOG

在根目录的 `CHANGELOG.md` 中添加新版本的更新说明：

```markdown
## [版本号] - 日期

### 新增
- 新功能描述

### 改进
- 改进内容

### 修复
- 修复的问题
```

### 步骤 3: 测试

运行测试确保一切正常：

```bash
pytest tests/
```

### 步骤 4: 发布到 TestPyPI（推荐先测试）

使用发布脚本：

```bash
./scripts/publish_testpypi.sh
```

或手动执行：

```bash
# 清理旧文件
rm -rf dist/ build/ *.egg-info

# 构建
python3 -m build

# 检查
python3 -m twine check dist/*

# 上传到 TestPyPI
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
python3 -m twine upload --repository testpypi dist/*
```

### 步骤 5: 验证 TestPyPI 安装

```bash
# 创建虚拟环境测试
python3 -m venv test_env
source test_env/bin/activate

# 从 TestPyPI 安装
pip install -i https://test.pypi.org/simple/ yeannhua-example-package-demo

# 测试功能
python -c "from example_package import hello, add, print_dict; print(hello('Test')); print(add(1,2)); print_dict({'test': 'ok'})"

# 退出虚拟环境
deactivate
rm -rf test_env
```

### 步骤 6: 发布到正式 PyPI

确认 TestPyPI 测试通过后，使用发布脚本：

```bash
./scripts/publish_pypi.sh
```

或手动执行：

```bash
# 清理旧文件
rm -rf dist/ build/ *.egg-info

# 构建
python3 -m build

# 检查
python3 -m twine check dist/*

# 上传到正式 PyPI
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token
python3 -m twine upload dist/*
```

### 步骤 7: 验证正式发布

```bash
# 安装
pip install yeannhua-example-package-demo

# 测试
python -c "from example_package import hello, add, print_dict; print(hello('Production')); print(add(10,20)); print_dict({'status': 'published'})"
```

### 步骤 8: 创建 Git Tag（可选）

```bash
git add .
git commit -m "Release version 0.2.0"
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin main --tags
```

## 发布脚本说明

### publish_testpypi.sh

- 自动清理、构建、检查、上传到 TestPyPI
- 包含交互式确认
- 上传前显示版本信息

### publish_pypi.sh

- 自动清理、构建、检查、上传到正式 PyPI
- 包含**双重确认**（防止误操作）
- 上传前显示警告信息

## 常见问题

### 1. 版本号已存在

如果上传时提示版本号已存在：
- PyPI 不允许重新上传相同版本号
- 需要更新版本号后重新构建上传

### 2. Token 认证失败

- 确保使用 `__token__` 作为用户名
- 确保 token 正确且未过期
- 确保使用对应平台的 token（TestPyPI vs 正式 PyPI）

### 3. 构建失败

- 检查 `pyproject.toml` 配置是否正确
- 确保所有依赖都已安装
- 查看错误信息并修复

## 快速参考

```bash
# 完整发布流程（推荐）
./scripts/publish_testpypi.sh  # 先测试
# 验证 TestPyPI 安装
./scripts/publish_pypi.sh      # 正式发布
```

## 相关链接

- TestPyPI: https://test.pypi.org/
- 正式 PyPI: https://pypi.org/
- 包地址: https://pypi.org/project/yeannhua-example-package-demo/
- 文档: [how_to_publish_to_pypi.md](../../how_to_publish_to_pypi.md)
