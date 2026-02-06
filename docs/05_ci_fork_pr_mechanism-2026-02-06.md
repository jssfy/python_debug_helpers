# Fork PR 在 CI 中的运行机制

## 核心结论

- Fork PR 的 CI **跑在 GitHub 自动创建的临时合并 commit 上**（`refs/pull/{number}/merge`），不是 fork 分支，也不是 main
- Fork PR **无法访问主仓库的 secrets**，`GITHUB_TOKEN` 权限为只读
- evermemos-python 用 `if: github.event_name == 'push' || github.event.pull_request.head.repo.fork` 避免主仓库内部 PR 重复跑 CI

## Fork PR checkout 的是什么

```
fork 仓库                        主仓库

feature-branch                   main
    │                              │
    commit A                       commit X (main HEAD)
    commit B (fork HEAD)           │
    │                              │
    └──── 发起 PR ────────────────►│
                                   │
                          GitHub 在后台自动创建:
                          refs/pull/123/merge ← 模拟合并后的结果
                                   │
                          CI 就跑在这个 ref 上
```

`actions/checkout` 实际执行的是：

```bash
git fetch origin refs/pull/123/merge
git checkout FETCH_HEAD
```

### 为什么这样设计

| 方案 | checkout 的内容 | 问题 |
|------|----------------|------|
| checkout fork 分支 | fork 的最新代码 | 不知道合并到 main 后会不会冲突或破坏 |
| checkout main | 主仓库的 main | 根本没包含 PR 的代码 |
| **checkout 合并 commit** | main + fork 变更合并后的状态 | 测试的就是"如果合入会怎样"，最有意义 |

这与主仓库内部 PR 的行为一致 — 都是 checkout 模拟合并后的状态。

## Fork PR 的安全限制

| 来源 | `secrets.*` 可用 | `GITHUB_TOKEN` 权限 | 原因 |
|------|:----------------:|:-------------------:|------|
| push 到主仓库 | 可用 | read/write | 可信代码 |
| 主仓库内部 PR | 可用 | read/write | 可信代码 |
| **fork PR** | **不可用** | **只读** | 不可信代码，防止泄露 secrets |

**为什么 fork PR 不给 secrets？** 因为任何人都可以 fork 仓库并提 PR，如果 fork PR 能访问 secrets，攻击者可以在 PR 中添加 `echo $PYPI_TOKEN` 来窃取凭证。

## evermemos-python 的去重策略

`ci.yml` 中的 `if` 条件：

```yaml
if: github.event_name == 'push' || github.event.pull_request.head.repo.fork
```

| 场景 | push 事件 | pull_request 事件 | 实际跑 CI 的事件 |
|------|:---------:|:-----------------:|:---------------:|
| 直接 push 到 main | 触发 | — | push |
| 主仓库内部 PR | push 已触发 | 也会触发 | **只跑 push**（PR 被 `if` 过滤掉） |
| fork PR | 无 push | 触发 | **pull_request** |

**目的：避免主仓库内部 PR 重复跑两次 CI**（push + pull_request 各跑一次）。

### 判断逻辑拆解

```
github.event_name == 'push'
  → 是 push 事件？直接跑

github.event.pull_request.head.repo.fork
  → 是 PR 事件？检查是否来自 fork
    → 来自 fork → 跑（因为 fork 不会有 push 事件）
    → 来自主仓库 → 跳过（push 事件已经跑过了）
```

## 对 python_debug_helpers 的影响

python_debug_helpers 当前的 workflow 没有这个 `if` 条件：

```yaml
# lint.yml / test.yml / build.yml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

**影响：** 如果从主仓库内部创建分支并提 PR 到 main，push 和 pull_request 都会触发，CI 会跑两次。

**是否需要加 `if` 去重？** 取决于使用场景：

| 场景 | 建议 |
|------|------|
| 个人项目，直接 push 到 main | 不需要，不会有 PR 事件 |
| 个人项目，偶尔用分支 + PR | 跑两次影响不大，可以不加 |
| 多人协作，频繁内部 PR | 建议加，避免浪费 CI 额度 |
| 开源项目，接受外部 fork PR | 建议加，同时减少内部重复 |

如需添加，在每个 workflow 的 job 级别加一行：

```yaml
jobs:
  lint:
    if: github.event_name == 'push' || github.event.pull_request.head.repo.fork
```
