# Issue: PyPI 包名冲突

## 问题描述

**时间**: 2026-01-24  
**操作**: 尝试发布到 PyPI  
**错误**: HTTPError 403 Forbidden

### 错误信息

```
ERROR HTTPError: 403 Forbidden from https://upload.pypi.org/legacy/
The user 'yeanhua' isn't allowed to upload to project 'debug-tools'. 
See https://pypi.org/help/#project-name for more information.
```

### 原因分析

包名 `debug-tools` 已被其他用户占用，无法上传。

### 解决方案

**改名为 `debug-helpers`**

- 包名（pip install）: `debug-tools` → `debug-helpers`
- 模块名（import）: `debug_tools` → `debug_helpers`

### 改名清单

**配置文件**:
- [x] `pyproject.toml` - name, packages
- [ ] `src/debug_tools/` → `src/debug_helpers/`
- [ ] `src/debug_helpers/__init__.py` - 模块描述

**文档**:
- [ ] `README.md`
- [ ] `CHANGELOG.md`
- [ ] `docs/*.md`
- [ ] `examples/readme.md`

**示例和脚本**:
- [x] `examples/test.py` - import 语句
- [ ] `scripts/install_and_test.sh`
- [x] `Makefile`

**测试**:
- [ ] `tests/test_example.py` - import 语句

### 预防措施

下次发布前：
1. 先在 PyPI 搜索确认包名可用：https://pypi.org/search/?q=包名
2. 或在 TestPyPI 上先注册占位

### 相关链接

- PyPI 项目命名帮助: https://pypi.org/help/#project-name
- 已占用的包: https://pypi.org/project/debug-tools/
- 检查可用性: https://pypi.org/search/?q=debug-helpers
