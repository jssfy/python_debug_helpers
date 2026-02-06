# GitHub Actions 配置说明

本项目使用 GitHub Actions 进行自动化测试和发布。

## 📋 工作流列表

### 1. 单元测试 (`test.yml`)

**触发条件**:
- 推送到 `main` 分支
- 向 `main` 分支提交 Pull Request

**测试矩阵**:
- Python 3.9, 3.10, 3.11, 3.12, 3.13
- Ubuntu Latest

**执行内容**:
1. 检出代码
2. 设置 Python 环境（多版本）
3. 安装项目和开发依赖
4. 运行单元测试（pytest + 覆盖率）
5. 上传覆盖率到 Codecov（仅 Python 3.11）

### 2. 构建验证 (`build.yml`)

**触发条件**:
- 推送到 `main` 分支
- 向 `main` 分支提交 Pull Request

**执行内容**:
1. 检出代码
2. 设置 Python 环境（3.12）
3. 安装构建工具（build、twine）
4. 构建分发包（wheel + sdist）
5. 检查分发包元数据（twine check）
6. 安装 wheel 并验证 import

**本地等效操作**: `make build`

### 3. 自动化发版 (`release-please.yml`)

**触发条件**:
- 推送到 `main` 分支

**执行内容**:
1. 分析 Conventional Commits 格式的 commit message
2. 自动决定版本号（feat → minor, fix → patch）
3. 创建/更新 Release PR（包含版本号变更 + CHANGELOG）
4. PR 合入后自动创建 tag + GitHub Release

**配置文件**:
- `release-please-config.json` — 行为配置（release-type、changelog-sections 等）
- `.release-please-manifest.json` — 当前版本状态

### 4. 发布到 PyPI (`publish.yml`)

**触发条件**:
- 推送 tag（格式：`v*.*.*`，由 Release Please 自动创建）

**执行内容**:
1. 检出代码
2. 设置 Python 环境
3. 构建分发包
4. 发布到 TestPyPI（测试）
5. 发布到 PyPI（正式）
6. 创建 GitHub Release

---

## 🔐 配置 Secrets

在 GitHub 仓库中配置以下 Secrets：

### 必需的 Secrets

1. **`PYPI_API_TOKEN`** - PyPI API Token
   - 获取地址: https://pypi.org/manage/account/token/
   - 用途: 发布到正式 PyPI

2. **`TESTPYPI_API_TOKEN`** - TestPyPI API Token
   - 获取地址: https://test.pypi.org/manage/account/token/
   - 用途: 发布到 TestPyPI 测试

### 可选的 Secrets

3. **`CODECOV_TOKEN`** - Codecov Token
   - 获取地址: https://codecov.io/
   - 用途: 上传测试覆盖率报告

### 配置步骤

1. 进入 GitHub 仓库
2. Settings → Secrets and variables → Actions
3. 点击 "New repository secret"
4. 添加上述 Secrets

---

## 🚀 使用方法

### 运行测试

推送代码到 `main` 分支即可自动触发测试：

```bash
git add .
git commit -m "Update code"
git push origin main
```

### 发布新版本（Release Please 自动化）

使用 Conventional Commits 格式提交，版本号、CHANGELOG、tag 全部自动处理：

1. **正常开发提交**（commit message 遵循 Conventional Commits）
   ```bash
   git commit -m "feat: add new helper function"
   git push origin main
   ```

2. **等待 Release PR**
   - Release Please 自动分析 commit，创建 Release PR
   - PR 内容：版本号变更 + 自动生成的 CHANGELOG

3. **审核并合入 Release PR**
   - 在 GitHub 上审核 PR 内容
   - 合入后自动创建 tag + GitHub Release
   - `publish.yml` 自动触发 → 发布到 PyPI

**Commit type 与版本号：**
- `feat:` → minor bump（0.4.2 → 0.5.0）
- `fix:` → patch bump（0.4.2 → 0.4.3）
- `feat!:` / `BREAKING CHANGE` → major bump（0.4.2 → 1.0.0）
- `chore:` / `docs:` / `ci:` → 不触发版本 bump

---

## 📊 查看结果

### 测试结果
- 访问: `https://github.com/<username>/<repo>/actions`
- 查看 "Python Unit Tests" 工作流

### 覆盖率报告
- 访问: `https://codecov.io/gh/<username>/<repo>`
- 查看详细覆盖率报告

### 发布状态
- 访问: `https://github.com/<username>/<repo>/actions`
- 查看 "Publish to PyPI" 工作流
- 查看 Releases 页面

---

## 🔧 本地测试 Actions

使用 [act](https://github.com/nektos/act) 在本地测试 GitHub Actions：

```bash
# 安装 act
brew install act  # macOS
# 或
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# 测试 test.yml
act push

# 测试 publish.yml
act push --eventpath .github/workflows/event.json
```

---

## 📝 注意事项

### 测试工作流
- ✅ 测试多个 Python 版本以确保兼容性
- ✅ 使用 `fail-fast: false` 确保所有版本都被测试
- ✅ 仅在 Python 3.11 上传覆盖率报告（避免重复）

### 发布工作流
- ⚠️ 发布是不可逆的操作
- ⚠️ 确保版本号在 `pyproject.toml` 和 `__init__.py` 中保持一致
- ⚠️ 相同版本号无法重新上传到 PyPI
- ✅ 先发布到 TestPyPI 可以预先测试
- ✅ 使用 `--skip-existing` 避免 TestPyPI 重复上传错误

### Token 安全
- 🔒 永远不要在代码中硬编码 Token
- 🔒 使用 GitHub Secrets 管理敏感信息
- 🔒 Token 应设置合适的权限范围

---

## 🎯 工作流状态徽章

在 README.md 中添加徽章：

```markdown
![Tests](https://github.com/<username>/<repo>/workflows/Python%20Unit%20Tests/badge.svg)
![PyPI](https://img.shields.io/pypi/v/debug-helpers.svg)
![Coverage](https://codecov.io/gh/<username>/<repo>/branch/main/graph/badge.svg)
```

---

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Python GitHub Actions](https://github.com/actions/setup-python)
- [PyPI Publishing with GitHub Actions](https://packaging.python.org/guides/publishing-package-distribution-releases-using-github-actions-ci-cd-workflows/)
- [Codecov](https://codecov.io/)
