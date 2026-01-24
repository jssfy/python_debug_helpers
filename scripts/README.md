# 脚本说明

本目录包含项目的开发和发布脚本。

## 脚本列表

### install_and_test.sh
本地安装和测试脚本

**用途**：
- 自动安装包到本地环境
- 运行测试验证安装
- 适合开发环境快速测试

**使用方法**：
```bash
# 在 scripts 目录内运行
./scripts/install_and_test.sh

# 或在项目根目录运行
cd /Users/admin/Downloads/sdk-generation/pypi/example_package
./scripts/install_and_test.sh
```

**功能**：
1. 检查 Python 版本
2. 检查并卸载已安装的旧版本
3. 以开发模式（-e）安装包
4. 验证安装
5. 运行示例测试

**特点**：
- 开发模式安装，代码修改后立即生效
- 自动清理旧版本
- 完整的验证流程

### publish_testpypi.sh
发布包到 TestPyPI（测试环境）

**用途**：
- 在正式发布前测试包的构建和上传流程
- 验证包的安装和功能

**使用方法**：
```bash
./scripts/publish_testpypi.sh
```

**功能**：
1. 清理旧的构建文件
2. 检查当前版本号
3. 构建分发包（.whl 和 .tar.gz）
4. 检查分发包完整性
5. 显示生成的文件
6. 交互式确认上传
7. 上传到 TestPyPI
8. 显示安装命令

**要求**：
- TestPyPI 账号和 API token
- 已安装 build 和 twine

### publish_pypi.sh
发布包到正式 PyPI（生产环境）

**用途**：
- 将包正式发布到 PyPI
- 供全球用户安装使用

**使用方法**：
```bash
./scripts/publish_pypi.sh
```

**功能**：
1. 清理旧的构建文件
2. 检查当前版本号
3. 构建分发包
4. 检查分发包完整性
5. 显示生成的文件
6. **双重交互式确认**（防止误操作）
7. 上传到正式 PyPI
8. 显示安装命令

**要求**：
- PyPI 账号和 API token
- 已在 TestPyPI 测试通过
- 已安装 build 和 twine

## 典型工作流

### 1. 开发测试流程

```bash
# 1. 本地开发
vim src/example_package/print.py

# 2. 安装和测试
./scripts/install_and_test.sh

# 3. 运行单元测试
pytest tests/

# 4. 运行示例
python3 examples/test.py
```

### 2. 发布流程

```bash
# 1. 更新版本号
# - 编辑 pyproject.toml 中的 version
# - 编辑 src/example_package/__init__.py 中的 __version__

# 2. 更新 CHANGELOG.md
vim CHANGELOG.md

# 3. 运行完整测试
pytest tests/ -v

# 4. 发布到 TestPyPI 测试
./scripts/publish_testpypi.sh

# 5. 验证 TestPyPI 安装
pip install -i https://test.pypi.org/simple/ yeannhua-example-package-demo
python3 -c "from example_package import print_dict; print_dict({'test': 'ok'})"

# 6. 发布到正式 PyPI
./scripts/publish_pypi.sh
```

## 脚本权限

如果遇到权限问题，添加执行权限：

```bash
chmod +x scripts/*.sh
```

## 环境变量

发布脚本支持通过环境变量提供认证信息：

### TestPyPI
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
./scripts/publish_testpypi.sh
```

### 正式 PyPI
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的正式pypi-token
./scripts/publish_pypi.sh
```

## 故障排除

### 安装失败
```bash
# 检查 Python 版本
python3 --version

# 确保在项目根目录
cd /Users/admin/Downloads/sdk-generation/pypi/example_package

# 手动安装
pip install -e .
```

### 发布失败
- 检查版本号是否已存在
- 确认 token 正确且未过期
- TestPyPI 和正式 PyPI 的 token 不能混用

## 更多信息

详细的发布流程请参考：
- [../docs/02_local_development.md](../docs/02_local_development.md) - 完整开发指南
- [../docs/01_upload_instructions.md](../docs/01_upload_instructions.md) - 上传说明
