# CI 构建验证 Job

## 核心结论

- **新增 `build.yml`** — 在 push/PR 时自动验证包能否成功构建，避免构建问题到发版时才暴露
- 验证链路：`python -m build` → `twine check` → 安装 wheel → import 验证
- 与现有 `publish.yml` 互补：build.yml 做早期验证，publish.yml 负责正式发版
- 本地等效操作：`make build`

## 为什么需要 Build Job

此前项目 CI 只有 lint（`lint.yml`）和 test（`test.yml`），构建验证仅在 `publish.yml`（tag 触发）中执行。这意味着：

1. `pyproject.toml` 配置错误（如 entry_points 写错）只有在打 tag 发版时才会被发现
2. 新增模块忘记导出，import 失败也只在发版流程才暴露
3. 修改包结构后构建产物是否正确，无法在 PR 阶段验证

添加独立的 build job 后，每次 push 和 PR 都会验证构建，做到**尽早发现、尽早修复**。

## 设计参考

参考了 evermemos-python 项目 `ci.yml` 中的 build job 模式，但做了以下调整以匹配本项目惯例：

| 项目 | evermemos-python | python_debug_helpers |
|------|-----------------|---------------------|
| 包管理工具 | uv | pip |
| 构建命令 | `uv run python -m build` | `python -m build` |
| import 验证 | 放在 lint job 中 | 合并到 build job |
| Python 版本 | 3.13 | 3.12（与 lint.yml 一致）|
| step 命名 | 中文 | 中文 |
| actions 版本 | checkout@v4, setup-python@v5 | 相同 |

## Workflow 完整解读

```yaml
name: Build
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

触发条件与 `lint.yml`、`test.yml` 一致：push 到 main 或向 main 提 PR。

### Steps 说明

| Step | 作用 | 输入/输出 |
|------|------|----------|
| 检出代码 | `actions/checkout@v4` | 输出：工作目录包含源码 |
| 设置 Python 环境 | `actions/setup-python@v5`，Python 3.12，pip 缓存 | 输出：可用的 Python 环境 |
| 安装构建工具 | `pip install build twine` | 输出：build 和 twine 可用 |
| 构建分发包 | `python -m build` | 输入：`pyproject.toml` + 源码；输出：`dist/*.whl` + `dist/*.tar.gz` |
| 检查分发包 | `twine check dist/*` | 输入：`dist/*`；验证包元数据（long_description、classifiers 等）|
| 验证安装 | 安装 wheel + `python -c "from debug_helpers import ..."` | 确认构建产物可正常安装和 import |

### 关键设计决策

1. **使用 `python -m build` 而非直接调用 `setup.py`** — 与 Makefile `build` target 和 `publish.yml` 保持一致，遵循 PEP 517 标准
2. **`twine check` 验证元数据** — 与 Makefile 和 `publish.yml` 一致，能提前发现 README 渲染问题等
3. **安装 wheel 而非 sdist** — wheel 是实际分发给用户的格式，验证它更有意义
4. **import 三个公开 API** — `hello`、`add`、`print_dict` 是 `__all__` 导出的全部内容，确保核心功能可用

## 与现有 Workflow 的关系

```
push/PR → lint.yml    (代码风格检查)
        → test.yml    (单元测试 × 多 Python 版本)
        → build.yml   (构建验证) ← 新增

tag push → publish.yml (构建 + 发布到 PyPI + 创建 Release)
```

- `build.yml` 和 `publish.yml` 的构建步骤相同（build + twine check）
- `build.yml` 额外做了安装验证（publish.yml 不需要，因为它直接上传）
- 两者独立运行，没有依赖关系

## 本地等效操作

```bash
# 完整构建验证（等效于 build.yml 的所有步骤）
make build

# 手动分步执行
python -m build
twine check dist/*
pip install dist/*.whl
python -c "from debug_helpers import hello, add, print_dict; print('import OK')"
```
