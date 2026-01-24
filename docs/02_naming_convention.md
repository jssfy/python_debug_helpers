# 文件命名规范说明

## 命名规则

本项目遵循以下文件命名规范：

### 1. 一般文件 - 使用小写字母和下划线
```
readme.md
project_structure.md
summary.md
upload_instructions.md
release.md
```

**规则**：
- 全部使用小写字母
- 单词之间用下划线 `_` 分隔
- 文件扩展名小写

### 2. 惯例文件 - 保留大写
```
LICENSE
README.md
CHANGELOG.md
```

**说明**：
- `LICENSE` - 开源许可证文件的标准命名
- `README.md` - 项目说明文件的标准命名，GitHub等平台自动识别
- `CHANGELOG.md` - 版本变更日志的标准命名
- 这些是业界通用的惯例，保持大写便于识别

### 3. 配置文件 - 保持原格式
```
pyproject.toml
.gitignore
```

**说明**：
- 工具配置文件使用其标准命名格式
- 不做修改

## 当前项目结构

```
example_package/
├── src/                          # 源代码
│   └── example_package/
│       ├── __init__.py
│       ├── main.py
│       └── print.py
│
├── tests/                        # 测试
│   ├── __init__.py
│   └── test_example.py
│
├── scripts/                      # 脚本
│   ├── README.md                ⭐ 惯例保留大写
│   ├── publish_testpypi.sh
│   └── publish_pypi.sh
│
├── docs/                         # 文档
│   ├── README.md                ⭐ 惯例保留大写
│   ├── release.md               ✅ 小写
│   ├── upload_instructions.md   ✅ 小写
│   ├── project_structure.md     ✅ 小写
│   ├── naming_convention.md     ✅ 小写（本文件）
│   └── summary.md               ✅ 小写
│
├── CHANGELOG.md                 ⭐ 惯例保留大写（根目录）
├── README.md                    ⭐ 惯例保留大写（根目录）
├── LICENSE                      ⭐ 惯例保留大写
└── pyproject.toml               # 配置文件
```

## 检查命令

检查是否有不符合规范的文件名（排除惯例文件）：

```bash
# 查找包含大写字母的文件（排除 LICENSE、README.md 和 CHANGELOG.md）
find . -type f -not -path '*/\.*' -not -path '*/dist/*' \
  -not -name 'LICENSE' -not -name 'README.md' -not -name 'CHANGELOG.md' \
  | grep -E '[A-Z]'
```

如果命令无输出，说明所有文件命名都符合规范。

## 为什么这样命名？

### 优点
1. **一致性**：大部分文件使用统一的小写+下划线格式
2. **可读性**：下划线分隔清晰易读
3. **兼容性**：避免不同操作系统对大小写的处理差异
4. **符合Python社区习惯**：Python包普遍使用小写命名

### 惯例文件保留大写的原因
1. **LICENSE**：GitHub、GitLab等平台会自动识别大写的LICENSE文件
2. **README.md**：GitHub等平台优先显示大写的README.md作为项目首页
3. **CHANGELOG.md**：遵循[Keep a Changelog](https://keepachangelog.com/)规范
4. **业界标准**：开发者习惯在项目中快速定位这些文件

## 命名示例

### ✅ 正确
- `project_structure.md`
- `upload_instructions.md`
- `test_example.py`
- `publish_testpypi.sh`

### ❌ 错误（一般文件不应使用大写）
- `ProjectStructure.md` → 应该是 `project_structure.md`
- `uploadInstructions.md` → 应该是 `upload_instructions.md`
- `TestExample.py` → 应该是 `test_example.py`

### ⭐ 特殊（惯例保留大写）
- `LICENSE` ✅
- `README.md` ✅
- `CHANGELOG.md` ✅

## 参考资源

- [PEP 8 - Python代码风格指南](https://pep8.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Python打包用户指南](https://packaging.python.org/)
