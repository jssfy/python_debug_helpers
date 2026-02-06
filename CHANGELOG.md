# 更新日志

## [0.4.3](https://github.com/jssfy/python_debug_helpers/compare/v0.4.2...v0.4.3) (2026-02-06)


### Features

* add linting and formatting tools ([7fe322c](https://github.com/jssfy/python_debug_helpers/commit/7fe322c51bb6c7a690ceb55ffd37a5c102693bc0))
* adds CI build job and updates documentation ([81c640f](https://github.com/jssfy/python_debug_helpers/commit/81c640f05e591b654f972c1d7c12827142724e4c))
* adds release_please support ([f89fa25](https://github.com/jssfy/python_debug_helpers/commit/f89fa25aef192772b721abbb74b77f554ff38e9e))


### Chores

* prepare release ([03b18d2](https://github.com/jssfy/python_debug_helpers/commit/03b18d2cad8da931c915649cb28aa3bf9928fbc1))


### Documentation

* adds explanations for github actions ([b5380ce](https://github.com/jssfy/python_debug_helpers/commit/b5380cef485c2cfcc7f2fdec903e64f7829c7e62))
* explains how tag triggers publish workflow ([aff38b9](https://github.com/jssfy/python_debug_helpers/commit/aff38b99cd97a1ef53b35176f8b902004ffdd872))
* explans why no main commits are shown in pr ([b650e88](https://github.com/jssfy/python_debug_helpers/commit/b650e885913e56d89eb956a5a0c6550f060cce98))
* how stainless works ([da3a84b](https://github.com/jssfy/python_debug_helpers/commit/da3a84b346f8c47f722b8235036dee8b366bc223))

## [0.4.0] - 2026-01-24

### 重大变更
- 包名从 `debug-tools` 改为 `debug-helpers`（解决 PyPI 包名冲突）
- 保持模块名为 `debug_helpers`

### 新增
- 🛠️ 添加 `Makefile` 支持，提供便捷的开发和发布命令
  - `make install-local` - 开发模式安装
  - `make install-test` - 从 TestPyPI 安装
  - `make install` - 从 PyPI 安装
  - `make uninstall` - 卸载包
  - `make test` - 运行单元测试
  - `make example` - 运行示例
  - `make clean` - 清理构建文件
  - `make build` - 构建分发包
  - `make publish-test` - 发布到 TestPyPI
  - `make publish-pypi` - 发布到 PyPI
- 🚀 添加 GitHub Actions CI/CD 支持
  - `test.yml` - 多版本 Python 自动测试（3.9-3.13）
  - `publish.yml` - 自动发布到 PyPI
- 📦 添加可选开发依赖 `[dev]`
  - `pytest>=7.0.0`
  - `pytest-cov>=4.0.0`
- 📚 添加详细文档
  - GitHub Actions 工作原理说明
  - PR 触发机制详解
  - PyPI Token 配置指南

### 改进
- ✅ 测试文件改为 `unittest.TestCase` 格式
  - 同时支持 `pytest` 和 `unittest` 运行
  - 更好的兼容性
- 📖 重写 README.md，添加徽章和完整使用指南
- 📝 完善所有文档，统一格式和风格
- 🔧 优化 `make test` 命令
  - 自动检测 pytest 可用性
  - 优雅降级到 unittest

### 修复
- 🐛 修复 `examples/test.py` 中的 import 错误
  - 从 `debug-helpers` 改为 `debug_helpers`
- 🐛 修复测试文件中的 import 语句
  - 从 `example_package` 改为 `debug_helpers`

### 问题记录
- ⚠️ 记录 PyPI 包名冲突问题（`debug-tools` 已被占用）
- 📄 创建 Issue 文档和改名指南

## [0.3.0] - 2026-01-24

### 重大变更
- 包名从 `yeannhua-example-package-demo` 改为 `debug-tools`
- 模块名从 `example_package` 改为 `debug_tools`

### 新增
- 添加 `print_dict()` 函数的日志分级支持 (debug/info/warning/error/critical)
- 在 `__init__.py` 中导出 `print_dict` 函数
- 添加 `__all__` 列表明确导出的 API

### 改进
- 优化示例代码，移除 sys.path 黑魔法，改为依赖正式安装
- 完善文档说明，添加安装和使用指南
- 更新 examples/readme.md，提供详细的安装和使用说明
- 降低 Python 版本要求到 3.9（将 match-case 改回 if-elif 以兼容）

### 修复
- 修复 examples/test.py，现在需要先安装包才能运行
- 确保示例代码展示标准的包使用方式

## [0.2.0] - 2026-01-24

### 新增
- 添加 `print_dict()` 函数，支持递归格式化和打印字典
- 支持处理各种数据类型：dict, list, dataclass, enum, datetime, ObjectId 等
- 添加 JSON 字符串自动解析和格式化功能

## [0.1.0] - 2026-01-24

### 新增
- 初始版本
- `hello()` 函数：返回问候语
- `add()` 函数：两数相加
- 基本的项目结构和配置
