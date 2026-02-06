# Release Doctor 原理分析

## 核心结论

- **Release Doctor** 是发版 PR 合入前的"环境健康检查"，在发布前拦截配置问题
- evermemos-python 中的实现（`release-doctor.yml` + `bin/check-release-environment`）**当前是空壳框架**，没有实际检查项
- 它是 Stainless SDK 模板的预留结构，完整形态应检查 secrets、版本号一致性、CHANGELOG 等
- python_debug_helpers 当前手动打 tag 发版，不需要此机制；若未来迁移到 release-please 可考虑引入

## Workflow 结构

来源文件：`evermemos-python/.github/workflows/release-doctor.yml`

```yaml
name: Release Doctor
on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  release_doctor:
    name: release doctor
    runs-on: ubuntu-latest
    if: github.repository == 'evermemos/evermemos-python'
        && (github.event_name == 'push'
         || github.event_name == 'workflow_dispatch'
         || startsWith(github.head_ref, 'release-please')
         || github.head_ref == 'next')
    steps:
      - uses: actions/checkout@v6
      - name: Check release environment
        run: bash ./bin/check-release-environment
```

### 触发条件解读

| 条件 | 含义 |
|------|------|
| `github.repository == 'evermemos/evermemos-python'` | 只在主仓库跑，fork 不跑 |
| `startsWith(github.head_ref, 'release-please')` | PR 来自 release-please 自动创建的分支 |
| `github.head_ref == 'next'` | PR 来自 `next` 分支 |
| `workflow_dispatch` | 手动触发（用于排查发布环境问题） |

**实际效果：只在发版相关的 PR 上运行**，普通功能 PR 不触发。

## 核心脚本分析

来源文件：`evermemos-python/bin/check-release-environment`

```bash
#!/usr/bin/env bash
errors=()                    # 错误收集数组（当前为空，无检查项）

lenErrors=${#errors[@]}

if [[ lenErrors -gt 0 ]]; then
  echo -e "Found the following errors in the release environment:\n"
  for error in "${errors[@]}"; do
    echo -e "- $error\n"
  done
  exit 1                     # 非零退出 → CI 失败，阻止 PR 合入
fi

echo "The environment is ready to push releases!"
```

### 设计模式

采用"错误收集 → 统一报告"模式：

```
检查项 1 → 失败？→ 追加到 errors[]
检查项 2 → 失败？→ 追加到 errors[]
检查项 N → 失败？→ 追加到 errors[]
         ↓
errors 非空 → 打印所有错误 → exit 1
errors 为空 → "ready to push releases!" → exit 0
```

优点：一次运行能暴露**所有**问题，而非逐个失败逐个修。

## 完整形态应该检查什么

当前脚本是空壳，典型的 release doctor 会添加以下检查：

```bash
errors=()

# 1. 检查 PyPI token 是否配置（通过环境变量间接验证）
if [ -z "$PYPI_TOKEN" ]; then
  errors+=("PYPI_TOKEN secret is not set")
fi

# 2. 检查版本号一致性
pyproject_ver=$(grep 'version' pyproject.toml | head -1 | cut -d'"' -f2)
init_ver=$(grep '__version__' src/pkg/__init__.py | cut -d'"' -f2)
if [ "$pyproject_ver" != "$init_ver" ]; then
  errors+=("Version mismatch: pyproject.toml=$pyproject_ver, __init__.py=$init_ver")
fi

# 3. 检查 CHANGELOG 是否更新
if ! git diff main -- CHANGELOG.md | grep -q '+'; then
  errors+=("CHANGELOG.md has not been updated")
fi

# 4. 检查构建工具是否可用
if ! command -v uv &> /dev/null; then
  errors+=("uv is not installed")
fi
```

## 在发布流程中的位置

```
release-please 创建发版 PR（分支名 release-please--*）
        ↓
  release-doctor.yml → 检查发布环境是否就绪    ← 合入前拦截
  ci.yml             → lint + build + test     ← 代码质量把关
        ↓
  PR 合入 main → release-please 自动创建 GitHub Release
        ↓
  publish-pypi.yml → 触发条件：release published → 发布到 PyPI
```

Release Doctor 与 CI 并行运行，卡在"合入前"关口。确保一旦 merge 触发正式发布，环境不会出问题。

## 对 python_debug_helpers 的适用性

| 维度 | evermemos-python | python_debug_helpers |
|------|-----------------|---------------------|
| 发版方式 | release-please 自动创建 PR | 手动打 tag（`git tag v*`） |
| 发版触发 | PR 合入 → release → publish | tag push → publish.yml |
| 是否需要 release-doctor | 是（拦截发版 PR） | **当前不需要** |

### 未来引入条件

当 python_debug_helpers 满足以下条件时，可考虑引入：

1. 迁移到 release-please 自动化发版
2. 发版流程涉及多个需要预检的配置项（多个 secrets、多平台发布等）
3. 多人协作，需要在发版 PR 中自动化检查清单

### 当前替代方案

python_debug_helpers 的 `publish.yml` 已包含 `twine check dist/*` 验证包元数据，`build.yml` 在每次 push/PR 时验证构建。这两者组合起来已覆盖了大部分发布前检查需求。
