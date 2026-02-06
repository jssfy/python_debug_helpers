# Release Please 工作原理详解

## 核心结论

- **Release Please** 是 Google 开源的自动化发版工具，通过分析 Conventional Commits 自动创建/更新 Release PR
- Google 官方**没有提供**托管的 Release Please GitHub App，标准使用方式是 **GitHub Action**（免费，无需申请）
- evermemos-python 的 `stainless-app[bot]` 是 **Stainless 平台的私有 GitHub App**，不对外开放
- 核心流程：push 到 main → Release Please 分析 commit → 创建/更新 Release PR → 合入后自动创建 GitHub Release → 触发 publish

## Release Please 是什么

Release Please 解决的核心问题：**把"决定版本号 + 写 CHANGELOG + 改版本文件 + 打 tag + 创建 Release"这套手动流程全部自动化**。

它的依据是 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
feat(api): add user endpoint     → minor 版本 bump（0.3.x → 0.4.0）
fix(client): handle timeout      → patch 版本 bump（0.3.11 → 0.3.12）
feat!: redesign auth flow        → major 版本 bump（0.x → 1.0.0）
chore: update deps               → 不触发版本 bump（但会记入 CHANGELOG）
```

## 使用方式

### 标准方式：GitHub Action（免费，无需申请）

Google 官方提供的 `googleapis/release-please-action`，加一个 workflow 文件即可，不需要安装任何 App，不需要申请，不需要额外 token（用自带的 `GITHUB_TOKEN`）：

```yaml
# .github/workflows/release-please.yml
name: Release Please
on:
  push:
    branches: [main]

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: python
```

再加上两个配置文件（`release-please-config.json` + `.release-please-manifest.json`）就完成了。

### evermemos-python 用的方式：Stainless 私有 GitHub App

evermemos-python 的 commit 作者 `stainless-app[bot]` 是 **Stainless 平台的私有 GitHub App**，属于 Stainless SDK 生成服务的一部分，**不对外开放**。

它的行为与 GitHub Action 方式相同（监听 push → 分析 commit → 创建/更新 PR → 合入后创建 Release），但运行在 Stainless 自己的服务器上：

1. App 自动监听 push 到 main 的事件
2. 读取仓库中的 `release-please-config.json` 获取配置
3. 分析新增的 commits，自动创建/更新 Release PR
4. PR 合入后自动创建 GitHub Release + tag

**无需在仓库中创建任何 release-please 相关的 workflow 文件。**

### 为什么 Stainless 用 App 而不是 Action

Stainless 统一管理几百个自动生成的 SDK 仓库，用一个集中的 GitHub App 比让每个仓库各自配 Action 更高效。这是平台级的需求，普通项目用不到。

### 两种方式对比

| 维度 | GitHub Action（标准方式） | Stainless App（evermemos 用的） |
|------|--------------------------|-------------------------------|
| 提供方 | Google 开源 | Stainless 平台 |
| 是否公开 | 公开免费 | 不公开，需要是 Stainless 客户 |
| 运行位置 | 仓库的 Actions runner | Stainless 托管服务器 |
| CI 分钟消耗 | 消耗 Actions 分钟数 | **不消耗** |
| 配置方式 | 仓库内放 workflow + config.json | 仓库内只放 config.json |
| commit 作者 | `github-actions[bot]` | `stainless-app[bot]` |
| 定制能力 | 完全自定义 | 受限于 App 提供的配置项 |
| 适用场景 | 开源项目、个人项目 | 企业平台统一管理 |

## evermemos-python 的配置文件解读

### `release-please-config.json` — 行为配置

```json
{
  "packages": { ".": {} },              // 根目录是一个包
  "release-type": "python",             // Python 项目（知道改 pyproject.toml）
  "include-v-in-tag": true,             // tag 格式: v0.3.11（而非 0.3.11）
  "versioning": "prerelease",           // 预发布版本策略
  "prerelease": true,                   // 标记为预发布
  "bump-minor-pre-major": true,         // 1.0 之前 feat → bump minor（0.3→0.4）
  "bump-patch-for-minor-pre-major": false,
  "pull-request-title-pattern": "release: ${version}",
  "extra-files": [
    "src/evermemos/_version.py"          // 额外需要更新版本号的文件
  ],
  "changelog-sections": [               // CHANGELOG 分组规则
    { "type": "feat", "section": "Features" },
    { "type": "fix",  "section": "Bug Fixes" },
    { "type": "test", "section": "Tests", "hidden": true },   // 不显示在 CHANGELOG
    { "type": "ci",   "section": "CI",    "hidden": true }    // 不显示在 CHANGELOG
  ]
}
```

### `.release-please-manifest.json` — 版本状态

```json
{
  ".": "0.3.11"
}
```

记录当前版本号，Release Please 每次发版后自动更新此文件。

### `_version.py` 中的版本标记

```python
__version__ = "0.3.11"  # x-release-please-version
```

`# x-release-please-version` 注释是**魔术标记**，告诉 Release Please "这一行需要更新版本号"。用于 `extra-files` 中声明的文件。

## 完整流程（以 evermemos-python 实际 git 历史为例）

### 第一阶段：积累 commits

```
main:
  ddfdd8c feat(api): api update       ← feat commit，需要 bump minor
  ...（可能还有其他 commit）
```

### 第二阶段：Release Please 创建/更新 PR

Release Please App 检测到 main 有新的 feat/fix commit，自动：

1. 创建分支 `release-please--branches--main--changes--next`
2. 根据 commit 类型决定版本号（feat → 0.3.x → 0.4.0）
3. 在该分支上生成一个 commit，修改 4 个文件：

```
  .release-please-manifest.json    "0.3.10" → "0.4.0"
  CHANGELOG.md                     追加新版本的变更记录
  pyproject.toml                   version = "0.3.10" → "0.4.0"
  src/evermemos/_version.py        __version__ = "0.3.10" → "0.4.0"
```

4. 创建 PR：标题 `release: 0.4.0`，内容包含自动生成的 CHANGELOG

```
PR #17: release: 0.4.0
  分支: release-please--branches--main--changes--next → main
  改动: 4 个文件（版本号 + CHANGELOG）
```

**如果在 PR 合入前又有新 commit push 到 main，Release Please 会自动更新这个 PR**（重新计算版本号和 CHANGELOG），而不是创建新 PR。

### 第三阶段：PR 合入 + 自动发版

```
git log:
  b20de91 Merge pull request #19 from evermemos/release-please--branches--main--changes--next
  045e009 release: 0.3.11              ← Release Please 生成的 commit
  151b7ca chore(internal): version bump ← Stainless 内部版本同步
```

PR 合入后，Release Please App 自动：

1. 在 main 上创建 tag `v0.3.11`
2. 创建 GitHub Release（标题 `v0.3.11`，内容为 CHANGELOG）
3. Release 的 `published` 事件触发 `publish-pypi.yml` → 发布到 PyPI

### 全流程图

```
开发者 push feat/fix commit 到 main
        ↓
Release Please App 检测到新 commit
        ↓
    ┌─ 已有 Release PR？──── 是 → 更新现有 PR（重算版本 + CHANGELOG）
    │                                    ↓
    └──── 否 → 创建新 Release PR ────────┘
                                         ↓
                              CI 跑在 Release PR 上:
                                ci.yml (lint + build + test)
                                release-doctor.yml (环境检查)
                                         ↓
                              PR 合入 main
                                         ↓
                              Release Please App 自动:
                                创建 tag v0.x.x
                                创建 GitHub Release
                                         ↓
                              publish-pypi.yml 触发:
                                on: release: [published]
                                         ↓
                              发布到 PyPI ✅
```

## GitHub App vs GitHub Action 的区别

| 维度 | GitHub App（evermemos 用的） | GitHub Action |
|------|---------------------------|---------------|
| 运行位置 | GitHub 托管服务器 | 仓库的 Actions runner |
| 配置方式 | 安装 App + 仓库内放 config.json | 自建 workflow YAML |
| 触发方式 | App 自动监听 push | workflow `on: push` |
| commit 作者 | `stainless-app[bot]` | `github-actions[bot]` |
| CI 分钟消耗 | **不消耗**（App 在自己的服务器跑） | 消耗 Actions 分钟数 |
| 定制能力 | 受限于 App 提供的配置项 | 完全自定义 |
| 适用场景 | 企业/平台统一管理 | 开源项目自行管理 |

## 对 python_debug_helpers 的参考

python_debug_helpers 当前是手动发版：

```bash
# 手动改版本号 → 手动打 tag → publish.yml 触发
git tag v0.4.1
git push origin v0.4.1
```

如果想引入 Release Please，使用 **GitHub Action 方式**（免费、无需申请），需要：

1. 添加 `release-please-config.json` 和 `.release-please-manifest.json`
2. 创建 `.github/workflows/release-please.yml`（见上方模板）
3. commit message 遵循 Conventional Commits 规范（参见 `05_ci_conventional_commits-2026-02-06.md`）
4. 去掉手动打 tag 的步骤，改为合入 Release PR 触发

**引入条件：** 发版频率高 + 需要自动 CHANGELOG + 多人协作时才有明显收益。当前项目手动发版足够。
