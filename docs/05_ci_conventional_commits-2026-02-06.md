# Conventional Commits 规范

## 核心结论

- Conventional Commits 是 **commit message 的格式规范**，让 commit 信息既能被人读懂，也能被工具自动解析
- Release Please 依据 commit 的 `type` 自动决定版本号和生成 CHANGELOG
- `feat` → minor bump，`fix` → patch bump，`!` 或 `BREAKING CHANGE` → major bump
- `chore` / `docs` / `ci` / `test` 等不触发版本 bump

## 格式

```
<type>(<scope>): <description>

[可选的正文]

[可选的脚注]
```

| 部分 | 必选 | 说明 | 示例 |
|------|:----:|------|------|
| `type` | 是 | 变更类型 | `feat`、`fix`、`chore` |
| `scope` | 否 | 影响范围（括号内） | `(api)`、`(client)`、`(auth)` |
| `description` | 是 | 简短描述，小写开头，不加句号 | `add user endpoint` |
| 正文 | 否 | 详细说明，空一行后开始 | 多行文本 |
| 脚注 | 否 | 元数据，如 `BREAKING CHANGE: xxx` | 破坏性变更说明 |

## type 与版本号的关系

| type | 含义 | 版本影响 | 示例 |
|------|------|---------|------|
| `feat` | 新功能 | **minor** bump（0.3.0 → 0.4.0） | `feat: add search api` |
| `fix` | 修 bug | **patch** bump（0.3.0 → 0.3.1） | `fix: null pointer error` |
| `feat!` / `fix!` | 破坏性变更 | **major** bump（0.3.0 → 1.0.0） | `feat!: remove v1 api` |
| 脚注含 `BREAKING CHANGE` | 破坏性变更 | **major** bump | 见下方示例 |
| `chore` | 杂务（依赖更新、配置等） | 不 bump | `chore: update deps` |
| `docs` | 文档 | 不 bump | `docs: update readme` |
| `ci` | CI 配置 | 不 bump | `ci: add build job` |
| `test` | 测试 | 不 bump | `test: add unit tests` |
| `refactor` | 重构（不改功能） | 不 bump | `refactor: extract helper` |
| `style` | 代码风格（格式化等） | 不 bump | `style: fix indentation` |
| `perf` | 性能优化 | 不 bump | `perf: cache query results` |
| `build` | 构建系统 | 不 bump | `build: update pyproject.toml` |
| `revert` | 回滚 | 不 bump | `revert: undo feat xxx` |

Release Please 扫描上次发版以来的所有 commit，**取最高级别**决定版本号：

```
fix + fix + fix       → patch bump
fix + feat            → minor bump（feat 优先）
fix + feat + feat!    → major bump（破坏性变更优先）
chore + docs + ci     → 不发版（无 feat/fix）
```

## evermemos-python 实际 commit 示例

```
feat(api): api update              → 新功能，scope 是 api → minor bump
fix(client): handle timeout        → 修 bug，scope 是 client → patch bump
chore(internal): version bump      → 杂务，不触发 bump
feat!: redesign auth flow          → 破坏性变更（! 标记）→ major bump
```

## 破坏性变更的两种标记方式

### 方式一：`!` 后缀

```
feat!: remove deprecated endpoints
```

### 方式二：脚注 `BREAKING CHANGE`

```
feat: redesign authentication

BREAKING CHANGE: token format changed from JWT to opaque,
all existing tokens will be invalidated.
```

两种方式效果相同，都触发 major bump。方式二可以附带详细说明。

## 与 Release Please 的配合

evermemos-python 的 `release-please-config.json` 中定义了 type → CHANGELOG 分组的映射：

```
feat     → "Features"               （显示在 CHANGELOG）
fix      → "Bug Fixes"              （显示在 CHANGELOG）
perf     → "Performance Improvements"（显示在 CHANGELOG）
chore    → "Chores"                  （显示在 CHANGELOG）
docs     → "Documentation"           （显示在 CHANGELOG）
refactor → "Refactors"              （显示在 CHANGELOG）
test     → "Tests"                   （hidden: true，不显示）
ci       → "Continuous Integration"  （hidden: true，不显示）
```

`hidden: true` 的 type 会被 Release Please 识别但不写入 CHANGELOG，因为用户通常不关心测试和 CI 的变更。

## 不用规范 vs 用规范

**不用规范：**

```
update stuff
fix bug
wip
asdf
```

工具无法解析，需要手动决定版本号、手动写 CHANGELOG。

**用规范：**

```
feat(auth): add OAuth2 login
fix(db): connection pool leak on timeout
docs: add API usage examples
```

工具能自动：
1. **算版本号** — 有 `feat` → minor bump，只有 `fix` → patch bump
2. **生成 CHANGELOG** — 按 type 分组
3. **过滤噪音** — `test` / `ci` 不出现在 CHANGELOG

## 对 python_debug_helpers 的适用性

当前项目不强制 Conventional Commits，手动管理版本号。如果未来引入 Release Please，需要：

1. 所有 commit message 遵循 `<type>(<scope>): <description>` 格式
2. 可选：添加 [commitlint](https://commitlint.js.org/) 或 pre-commit hook 强制检查格式
3. 可选：使用 [Commitizen](https://commitizen-tools.github.io/commitizen/) 交互式生成规范 commit message

**参考链接：** https://www.conventionalcommits.org/
