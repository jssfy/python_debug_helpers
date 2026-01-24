# 更新日志

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
