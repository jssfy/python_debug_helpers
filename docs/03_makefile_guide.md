# Makefile 使用指南

## 📋 可用命令

### 基础命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `make help` | 显示帮助信息 | `make help` |
| `make install` | 开发模式安装到本地 | `make install` |
| `make uninstall` | 卸载包 | `make uninstall` |
| `make test` | 运行单元测试 | `make test` |
| `make example` | 运行示例代码 | `make example` |
| `make clean` | 清理构建文件 | `make clean` |
| `make build` | 构建分发包 | `make build` |
| `make info` | 查看包信息 | `make info` |

### 发布命令

| 命令 | 说明 | 注意事项 |
|------|------|---------|
| `make publish-test` | 发布到 TestPyPI | 用于测试 |
| `make publish-pypi` | 发布到正式 PyPI | ⚠️ 需双重确认 |

### 组合命令

| 命令 | 说明 | 等同于 |
|------|------|--------|
| `make test-local` | 完整本地测试流程 | `uninstall` + `install` + `example` |

---

## 🚀 使用示例

### 1. 本地开发

```bash
# 安装
make install

# 运行示例
make example

# 测试
make test
```

### 2. 完整测试流程

```bash
# 一键测试（卸载、安装、运行示例）
make test-local
```

### 3. 发布流程

```bash
# 清理和构建
make build

# 先发布到 TestPyPI 测试
make publish-test

# 验证 TestPyPI 安装
pip install -i https://test.pypi.org/simple/ debug-tools
python -c "from debug_tools import hello; print(hello('Test'))"

# 确认无误后发布到正式 PyPI
make publish-pypi
```

---

## 📖 详细说明

### make install
开发模式安装，代码修改后立即生效

**执行内容**:
```bash
pip install -e .
```

**输出**:
```
==> 开发模式安装...
Successfully installed debug-tools
✅ 安装完成！
验证: pip show debug-tools
```

---

### make uninstall
卸载已安装的包

**执行内容**:
```bash
pip uninstall -y debug-tools
```

**输出**:
```
==> 卸载 debug-tools...
Successfully uninstalled debug-tools-0.3.0
✅ 卸载完成！
```

---

### make test
运行单元测试

**执行内容**:
```bash
pytest tests/ -v
```

**输出**:
```
==> 运行单元测试...
tests/test_example.py::test_hello PASSED
tests/test_example.py::test_add PASSED
tests/test_example.py::test_print_dict PASSED
```

---

### make example
运行示例代码

**执行内容**:
```bash
python3 examples/test.py
```

**输出**:
```
==> 运行示例代码...

==================================================
测试 debug_tools v0.3.0
==================================================

1. 测试 hello 函数
------------------------------
Hello, World!
...
```

---

### make clean
清理构建产生的临时文件

**执行内容**:
```bash
rm -rf dist/ build/ *.egg-info src/*.egg-info
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete
```

**清理内容**:
- `dist/` - 分发包目录
- `build/` - 构建临时目录
- `*.egg-info` - 包元数据
- `__pycache__/` - Python 缓存
- `*.pyc` - 编译的 Python 文件

---

### make build
构建分发包并检查

**执行内容**:
1. 清理旧文件 (`make clean`)
2. 构建包 (`python3 -m build`)
3. 检查包 (`python3 -m twine check dist/*`)

**输出**:
```
==> 清理构建文件...
✅ 清理完成！

==> 构建分发包...
Successfully built debug_tools-0.3.0.tar.gz and debug_tools-0.3.0-py3-none-any.whl

==> 检查分发包...
Checking dist/debug_tools-0.3.0-py3-none-any.whl: PASSED
Checking dist/debug_tools-0.3.0.tar.gz: PASSED

✅ 构建完成！
生成的文件：
-rw-r--r--  1 admin  staff   8.5K debug_tools-0.3.0-py3-none-any.whl
-rw-r--r--  1 admin  staff   7.2K debug_tools-0.3.0.tar.gz
```

---

### make publish-test
发布到 TestPyPI

**执行内容**:
1. 构建包 (`make build`)
2. 显示包信息和版本
3. 交互式确认
4. 上传到 TestPyPI

**交互示例**:
```
==========================================
  准备发布到 TestPyPI
==========================================

包名: debug-tools
版本: 0.3.0

确认上传到 TestPyPI? (y/n) y

==> 上传到 TestPyPI...
Uploading debug_tools-0.3.0-py3-none-any.whl
Uploading debug_tools-0.3.0.tar.gz

✅ 上传成功！

查看: https://test.pypi.org/project/debug-tools/
安装: pip install -i https://test.pypi.org/simple/ debug-tools
```

**环境变量**（可选）:
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
make publish-test  # 不需要手动输入认证信息
```

---

### make publish-pypi
发布到正式 PyPI

**执行内容**:
1. 构建包 (`make build`)
2. 显示警告信息
3. **双重确认**（防止误操作）
4. 上传到正式 PyPI

**交互示例**:
```
==========================================
  ⚠️  准备发布到正式 PyPI
==========================================

包名: debug-tools
版本: 0.3.0

⚠️  注意:
  - 上传后无法删除或撤销
  - 相同版本号无法重新上传
  - 请确保已在 TestPyPI 测试通过

确定要上传到正式 PyPI 吗? (y/n) y

再次确认：真的要上传到正式 PyPI 吗? (y/n) y

==> 上传到正式 PyPI...
Uploading debug_tools-0.3.0-py3-none-any.whl
Uploading debug_tools-0.3.0.tar.gz

✅ 上传成功！

查看: https://pypi.org/project/debug-tools/
安装: pip install debug-tools
```

---

### make test-local
完整的本地测试流程

**执行内容**:
```bash
make uninstall  # 卸载旧版本
make install    # 安装当前版本
make example    # 运行示例
```

**用途**: 快速验证本地代码是否正常工作

---

### make info
查看包信息

**执行内容**:
```bash
pip show debug-tools
grep "version = " pyproject.toml
```

**输出**:
```
==> 包信息
Name: debug-tools
Version: 0.3.0
Location: /path/to/src/debug_tools
Requires: 
Required-by: 

==> 当前版本
version = "0.3.0"
```

---

## 🔧 常见工作流

### 开发工作流

```bash
# 1. 安装
make install

# 2. 修改代码
vim src/debug_tools/print.py

# 3. 测试（代码修改立即生效）
make example

# 4. 运行单元测试
make test
```

### 发布工作流

```bash
# 1. 更新版本号
vim pyproject.toml  # 修改 version
vim src/debug_tools/__init__.py  # 修改 __version__
vim CHANGELOG.md  # 添加更新日志

# 2. 本地测试
make test-local

# 3. 发布到 TestPyPI 测试
make publish-test

# 4. 验证 TestPyPI 安装
pip install -i https://test.pypi.org/simple/ debug-tools
python -c "from debug_tools import hello; print(hello('Test'))"

# 5. 发布到正式 PyPI
make publish-pypi
```

### 清理和重建

```bash
# 清理所有构建文件
make clean

# 重新构建
make build

# 查看生成的文件
ls -lh dist/
```

---

## ⚠️ 注意事项

### 发布前检查清单

- [ ] 更新版本号（`pyproject.toml` 和 `__init__.py`）
- [ ] 更新 `CHANGELOG.md`
- [ ] 运行 `make test` 确保测试通过
- [ ] 运行 `make test-local` 确保本地安装正常
- [ ] 先发布到 TestPyPI 测试
- [ ] 验证 TestPyPI 安装和功能
- [ ] 确认无误后再发布到正式 PyPI

### PyPI 认证

**方式一：交互式输入**
```bash
make publish-test
# 根据提示输入用户名和密码
Username: __token__
Password: pypi-你的token
```

**方式二：环境变量**（推荐）
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-你的testpypi-token
make publish-test  # 自动使用环境变量
```

**方式三：.pypirc 文件**
创建 `~/.pypirc`:
```ini
[testpypi]
username = __token__
password = pypi-你的testpypi-token

[pypi]
username = __token__
password = pypi-你的正式pypi-token
```

---

## 📚 相关资源

- **Makefile**: 项目根目录
- **发布脚本**: `scripts/publish_*.sh`
- **文档**: `docs/01_release.md`
- **示例**: `examples/test.py`

---

## 💡 提示

1. **首次使用**: 运行 `make help` 查看所有可用命令
2. **本地测试**: 使用 `make test-local` 快速验证
3. **安全发布**: 始终先发布到 TestPyPI 测试
4. **版本管理**: 遵循语义化版本规范（MAJOR.MINOR.PATCH）
