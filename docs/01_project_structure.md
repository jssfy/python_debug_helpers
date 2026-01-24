# Example Package 项目结构

```
example_package/
├── src/                          # 源代码目录
│   └── example_package/
│       ├── __init__.py          # 包初始化文件，导出公共API
│       ├── main.py              # 示例主模块
│       └── print.py             # 字典打印工具模块
│
├── tests/                        # 测试目录
│   ├── __init__.py
│   └── test_example.py          # 测试文件
│
├── scripts/                      # 脚本目录
│   ├── publish_testpypi.sh      # 发布到 TestPyPI 的脚本
│   └── publish_pypi.sh          # 发布到正式 PyPI 的脚本
│
├── docs/                         # 文档目录
│   ├── CHANGELOG.md             # 更新日志
│   ├── RELEASE.md               # 发布指南
│   └── UPLOAD_INSTRUCTIONS.md   # 上传说明
│
├── dist/                         # 构建输出目录（自动生成）
│
├── pyproject.toml               # 项目配置文件
├── README.md                    # 项目说明
├── LICENSE                      # 许可证
└── PROJECT_STRUCTURE.md         # 本文件
```

## 目录说明

### src/
存放源代码的目录，使用 `src` 布局可以确保测试和构建的正确性。

### tests/
存放测试文件，使用 pytest 运行测试。

### scripts/
存放发布和构建相关的脚本：
- `publish_testpypi.sh` - 自动化发布到 TestPyPI
- `publish_pypi.sh` - 自动化发布到正式 PyPI

### docs/
存放项目文档：
- `CHANGELOG.md` - 记录每个版本的变更
- `RELEASE.md` - 发布新版本的详细步骤
- `UPLOAD_INSTRUCTIONS.md` - 上传到 PyPI 的快速指南

## 快速开始

### 安装开发依赖
```bash
pip install --user build twine pytest
```

### 运行测试
```bash
pytest tests/
```

### 发布到 TestPyPI
```bash
./scripts/publish_testpypi.sh
```

### 发布到正式 PyPI
```bash
./scripts/publish_pypi.sh
```

## 文档链接

- [README.md](README.md) - 项目介绍和使用说明
- [docs/CHANGELOG.md](docs/CHANGELOG.md) - 版本更新历史
- [docs/RELEASE.md](docs/RELEASE.md) - 发布流程指南
- [docs/UPLOAD_INSTRUCTIONS.md](docs/UPLOAD_INSTRUCTIONS.md) - 上传说明
- [LICENSE](LICENSE) - MIT 许可证

## 相关资源

- 主教程文档: [../../how_to_publish_to_pypi.md](../../how_to_publish_to_pypi.md)
- TestPyPI: https://test.pypi.org/
- PyPI: https://pypi.org/
