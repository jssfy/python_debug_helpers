# Release Please GitHub Action 实操指南

## 核心结论

- Release Please GitHub Action 是免费的、零成本引入的自动化发版方案
- 它把「决定版本号 → 改版本文件 → 写 CHANGELOG → 打 tag → 创建 GitHub Release」全部自动化
- 开发者只需遵循 Conventional Commits 写 commit message，其余全部由工具完成
- 以 python_debug_helpers 为例，引入后：当前 5 步手动发版流程 → 1 步（合入 PR）

## 当前手动发版流程 vs Release Please

### 当前流程（5 步手动操作）

```bash
# 1. 手动改 pyproject.toml 版本号
version = "0.4.3"

# 2. 手动改 __init__.py 版本号
__version__ = "0.4.3"

# 3. 手动更新 CHANGELOG.md

# 4. 提交
git add pyproject.toml src/debug_helpers/__init__.py CHANGELOG.md
git commit -m "Bump version to 0.4.3"
git push origin main

# 5. 手动打 tag → 触发 publish.yml
git tag v0.4.3
git push origin v0.4.3
```

**痛点：** 版本号要改两处容易遗漏（当前 pyproject.toml 是 0.4.2 而 __init__.py 是 0.4.0，已经不一致）、CHANGELOG 手写费时、打 tag 是额外步骤。

### 引入 Release Please 后（1 步操作）

```bash
# 开发者只做这一件事：用 Conventional Commits 格式提交
git commit -m "feat: add pretty_print function"
git push origin main

# 以下全部自动发生：
# → Release Please 分析 commit，创建 Release PR
# → PR 内容：自动改好版本号 + 自动生成 CHANGELOG
# → 开发者审核后合入 PR
# → 自动创建 tag + GitHub Release
# → 触发 publish.yml → 发布到 PyPI
```

## 原理：Release Please 如何工作

### 状态机模型

Release Please 本质是一个**基于 commit 历史的状态机**：

```
状态 1: 等待变更
  main 上没有新的 feat/fix commit（距上次发版）
  → 不创建 PR，什么都不做

状态 2: 有待发布的变更
  main 上积累了 feat/fix commit
  → 创建 Release PR（或更新已有的）

状态 3: Release PR 被合入
  → 创建 tag + GitHub Release
  → 回到状态 1
```

### 核心算法

每次 push 到 main，Release Please Action 执行以下步骤：

```
1. 找到上次发版的 tag（如 v0.4.2）
2. 收集从该 tag 到 HEAD 的所有 commit
3. 解析每个 commit 的 Conventional Commits type
4. 决定版本 bump 级别：
   - 有 BREAKING CHANGE → major（0.4.2 → 1.0.0）
   - 有 feat            → minor（0.4.2 → 0.5.0）
   - 只有 fix           → patch（0.4.2 → 0.4.3）
   - 只有 chore/docs    → 不发版
5. 生成 CHANGELOG 条目（按 type 分组）
6. 修改版本文件（pyproject.toml、__init__.py 等）
7. 创建/更新 Release PR
```

### 版本文件怎么找到并修改

Release Please 通过 `release-type: python` 知道这是 Python 项目，会自动修改：

| 文件 | 修改方式 |
|------|---------|
| `pyproject.toml` | 找到 `version = "x.x.x"` 字段，替换版本号 |
| `CHANGELOG.md` | 在文件顶部插入新版本的变更记录 |

对于 `__init__.py` 等额外文件，通过 `extra-files` 配置 + 魔术注释标记：

```python
# src/debug_helpers/__init__.py
__version__ = "0.4.2"  # x-release-please-version
```

`# x-release-please-version` 告诉 Release Please "这行的版本号需要更新"。

### Release PR 长什么样

Release Please 自动创建的 PR：

```
标题: release: 0.5.0
分支: release-please--branches--main--changes--next → main

改动文件:
  pyproject.toml                    version = "0.4.2" → "0.5.0"
  src/debug_helpers/__init__.py     __version__ = "0.4.2" → "0.5.0"
  CHANGELOG.md                     追加新版本条目
  .release-please-manifest.json    "0.4.2" → "0.5.0"

PR 正文（自动生成）:
  ## 0.5.0

  ### Features
  * add pretty_print function (#25)
  * support nested dict formatting (#27)

  ### Bug Fixes
  * fix encoding issue in print_dict (#26)
```

### PR 的"活文档"特性

Release PR 创建后，**如果继续 push 新 commit 到 main**，Release Please 不会创建新 PR，而是**更新现有 PR**：

```
时间线:
  T1: feat: add func A          → 创建 PR "release: 0.5.0"
  T2: fix: fix bug B            → 更新 PR，CHANGELOG 追加 bug B
  T3: feat!: breaking change C  → 更新 PR，版本号改为 1.0.0
  T4: 开发者合入 PR              → 创建 tag v1.0.0 + Release
```

这意味着你可以积累多个变更再统一发版，不需要每个 commit 都发一次。

## 具体怎么做：以 python_debug_helpers 为例

### 第一步：创建配置文件

**`release-please-config.json`：**

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {}
  },
  "release-type": "python",
  "include-v-in-tag": true,
  "bump-minor-pre-major": true,
  "pull-request-title-pattern": "release: ${version}",
  "extra-files": [
    "src/debug_helpers/__init__.py"
  ],
  "changelog-sections": [
    { "type": "feat", "section": "Features" },
    { "type": "fix", "section": "Bug Fixes" },
    { "type": "perf", "section": "Performance Improvements" },
    { "type": "chore", "section": "Chores" },
    { "type": "docs", "section": "Documentation" },
    { "type": "refactor", "section": "Refactors" },
    { "type": "test", "section": "Tests", "hidden": true },
    { "type": "ci", "section": "CI", "hidden": true }
  ]
}
```

**`.release-please-manifest.json`：**

```json
{
  ".": "0.4.2"
}
```

### 第二步：给 `__init__.py` 加魔术注释

```python
__version__ = "0.4.2"  # x-release-please-version
```

### 第三步：创建 workflow

**`.github/workflows/release-please.yml`：**

```yaml
name: Release Please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

**只需要 `GITHUB_TOKEN`**，不需要额外的 secret。`permissions` 中的 `contents: write` 用于创建 tag 和 Release，`pull-requests: write` 用于创建/更新 PR。

### 第四步：修改 publish.yml 触发条件

当前 `publish.yml` 由 tag push 触发。引入 Release Please 后有两种选择：

**方案 A：保持 tag 触发（无需改 publish.yml）**

Release Please 合入 PR 后会自动创建 tag，自然触发现有的 `publish.yml`。**不需要改任何东西。**

**方案 B：改为 release 事件触发（更明确）**

```yaml
# publish.yml
on:
  release:
    types: [published]   # GitHub Release 创建时触发
```

方案 A 更简单（零改动），方案 B 语义更清晰。

### 完整流程图（引入后）

```
开发者: git commit -m "feat: add new function"
        git push origin main
              ↓
GitHub Actions: release-please.yml 触发
              ↓
Release Please Action:
  1. 读取 .release-please-manifest.json → 当前版本 0.4.2
  2. 找 tag v0.4.2 → 收集之后的 commit
  3. 发现 feat commit → 决定 minor bump → 0.5.0
  4. 修改 pyproject.toml、__init__.py、CHANGELOG.md
  5. 创建/更新 Release PR
              ↓
开发者: 审核 PR → 点击 Merge
              ↓
Release Please Action（再次触发，因为 merge 也是 push）:
  1. 检测到 Release PR 刚被合入
  2. 创建 tag v0.5.0
  3. 创建 GitHub Release（内容 = CHANGELOG 条目）
              ↓
publish.yml 触发（tag push 或 release published）:
  build → twine check → 发布到 TestPyPI → 发布到 PyPI
              ↓
          发版完成 ✅
```

## 达到的效果总结

| 维度 | 手动发版（当前） | Release Please |
|------|:--------------:|:--------------:|
| 决定版本号 | 手动判断 | 自动（基于 commit type） |
| 改 pyproject.toml 版本 | 手动改 | 自动改 |
| 改 __init__.py 版本 | 手动改（容易遗漏） | 自动改 |
| 写 CHANGELOG | 手动写 | 自动生成 |
| 版本号一致性 | 靠人保证（当前已不一致） | 工具保证（不可能不一致） |
| 打 tag | 手动 `git tag` + `git push` | 自动创建 |
| 创建 GitHub Release | publish.yml 中用 action | 自动创建 |
| 发版前审核 | 无（打 tag 就发了） | 有（Release PR 可以审核） |
| 回滚 | 困难（tag 已推送） | 关闭 PR 即可取消 |

## 为什么需要额外的 Release PR

代码已经 push 到 main 了，为什么还要多一个 PR？

**关键理解：Release PR 里不包含功能代码。** 功能代码已经在 main 上。Release PR 只包含版本号变更 + CHANGELOG，它是一个**发版开关**。

### 没有 Release PR（每次 push 直接发版）

```
T1: feat: add func A    → 立刻发 0.5.0
T2: fix: fix bug in A   → 立刻发 0.5.1
T3: feat: add func B    → 立刻发 0.6.0
```

三个 commit 触发三次发版，用户一天收到三个版本。

### 有 Release PR（积累后统一发版）

```
T1: feat: add func A    → Release PR 创建："release: 0.5.0"
T2: fix: fix bug in A   → Release PR 更新：CHANGELOG 追加 bug fix
T3: feat: add func B    → Release PR 更新：CHANGELOG 追加 func B
T4: 你觉得可以发了       → 合入 PR → 发一次 0.5.0（包含以上全部）
```

### Release PR 的价值

| 价值 | 说明 |
|------|------|
| **积累变更** | 不急着发，等功能做完再发 |
| **审核 CHANGELOG** | 自动生成的内容可能需要润色 |
| **选择时机** | 周五下午不想发版？不合入就行 |
| **可取消** | 关闭 PR 就取消本次发版，已 push 的代码不受影响 |
| **可见性** | PR 页面清晰展示本次发版包含哪些变更 |

如果确实想要"每次 push 自动发版"（不需要人工门），那不需要 Release Please，直接在 CI 里自动 bump + tag 就行。但大多数项目需要控制发版节奏，这就是 Release PR 存在的意义。

## 首次引入必需的仓库设置

Release Please Action 需要创建 PR 的权限，GitHub 仓库默认不允许 Actions 创建 PR，**必须手动开启**。

### 错误现象

首次运行时，Release Please 能成功创建分支和 commit，但在创建 PR 时报错：

```
Error: release-please failed: GitHub Actions is not permitted to create or
approve pull requests.
```

### 解决步骤

到 GitHub 仓库设置中开启权限：

```
Settings → Actions → General → Workflow permissions
```

需要勾选两项：

| 设置项 | 说明 |
|--------|------|
| **Read and write permissions** | 允许 Actions 写入仓库（创建分支、commit、tag） |
| **Allow GitHub Actions to create and approve pull requests** | 允许 Actions 创建 PR ← **这个是关键** |

保存后，手动重跑 release-please workflow 即可：`Actions → Release Please → Run workflow`，或等下次 push 到 main 自动触发。

### 为什么默认不开启

这是 GitHub 的安全策略。允许 Actions 创建 PR 意味着自动化流程可以提交代码变更，对于不了解的用户可能带来风险。Release Please 只创建版本号 + CHANGELOG 的变更 PR，风险可控。

### 开启后会不会导致 PR 被自动 approve

**不会。** "Allow GitHub Actions to create and approve pull requests" 是指允许 Actions **有能力**创建和 approve PR，不是自动 approve 所有 PR。

Release Please Action 的代码里只调用了 create PR API，没有调用 approve API：

```
开启权限后 Release Please 做的事：
  ✅ 创建分支
  ✅ 创建 commit（改版本号 + CHANGELOG）
  ✅ 创建 PR
  ❌ 不会 approve PR
  ❌ 不会 merge PR
  ❌ 不会影响其他 PR
```

创建的 PR 仍然需要人手动点 Merge。

**如果担心风险，可以加 branch protection rule 做双重保障：**

```
Settings → Branches → Add rule → main
  ✅ Require a pull request before merging
  ✅ Require approvals: 1
  ❌ 不勾选 "Allow specified actors to bypass required pull requests"
```

这样即使某个 Action 意外调用了 approve，仍然需要**真人** approve 才能合入。

## 常见问题

### PR 标题版本号与代码不一致

**现象：** 手动修改了 Release PR 标题（如改为 `release: 0.4.3`），但 PR 内的代码变更仍然是 `0.5.0`。

**原因：** PR 标题只是显示用的，实际版本由 PR 中 4 个文件的内容决定：

```
.release-please-manifest.json  → 0.5.0
pyproject.toml                 → 0.5.0
src/debug_helpers/__init__.py  → 0.5.0
CHANGELOG.md                   → ## [0.5.0]
```

只改标题不会改代码内容。

**Release Please 如何决定版本号：**

```
上次发版 v0.4.2 以来的 commit:
  feat: add xxx   ← feat 类型 → minor bump
  ci: add yyy     ← ci 类型 → 不影响版本

结果: 0.4.2 + feat → 0.5.0（minor bump）
如果只有 fix → 0.4.3（patch bump）
```

**解决方式：**

| 目标 | 操作 |
|------|------|
| 接受 0.5.0（推荐） | 把 PR 标题改回 `release: 0.5.0`，直接合入 |
| 强制使用 0.4.3 | 关闭当前 PR，用 `Release-As` 指令覆盖（见下方） |

**`Release-As` 指令用法 — 强制指定版本号：**

```bash
# 关闭当前 Release PR 后，推送一个带 Release-As footer 的 commit
# 方式一：引号内真实换行（subject 和 footer 之间必须有空行）
git commit --allow-empty -m "chore: prepare release

Release-As: 0.4.3"

# 方式二（推荐）：用多个 -m 参数（git 自动在两个 -m 之间插入空行）
git commit --allow-empty -m "chore: prepare release" -m "Release-As: 0.4.3"
```

然后推送：

```bash
git push origin main
```

Release Please 读取 commit footer 中的 `Release-As: 0.4.3`，强制使用该版本号创建新的 Release PR，不再根据 commit type 自动计算。

**`Release-As` 必须放在 footer 位置（与 subject 之间有空行）。** 这是 git commit message 的标准格式：

```
第 1 行: subject（主题）
                          ← 空行（必须）
第 3 行起: body / footer
```

| 写法 | Release Please 能否识别 | 原因 |
|------|:----------------------:|------|
| `-m "chore: release" -m "Release-As: 0.4.3"` | **能** | 两个 `-m` 自动插入空行，footer 正确 |
| `"chore: release\n\nRelease-As: 0.4.3"` | **能** | 空行分隔，footer 正确 |
| `"chore: release\nRelease-As: 0.4.3"` | **不能** | 无空行，被当作 body 文本 |
| `"chore: release Release-As: 0.4.3"` | **不能** | 全在 subject 行，无 footer |

**注意：** `Release-As` 是一次性指令，只影响下一次 Release PR。后续发版恢复自动计算。

## 注意事项

1. **仓库权限设置** — 首次引入必须开启 Actions 创建 PR 的权限（见上方）
2. **commit message 必须遵循规范** — 不规范的 commit 不会被识别，不会触发版本 bump
3. **首次引入需要对齐版本** — `.release-please-manifest.json` 中的版本号必须与 `pyproject.toml` 一致
4. **CHANGELOG 格式会改变** — Release Please 生成的格式与当前手写的不同，首次引入后历史 CHANGELOG 保持原样，新版本用新格式
5. **不要再手动打 tag** — 引入后由 Release Please 管理 tag，手动打 tag 会导致版本状态混乱
6. **不要只改 PR 标题来换版本号** — 标题是显示用的，要改版本号用 `Release-As` 指令
