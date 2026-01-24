# Issue: GitHub Actions 创建 Release 权限错误

## 问题描述

**时间**: 2026-01-24  
**版本**: v0.4.0  
**工作流**: `publish.yml`  
**错误**: Resource not accessible by integration

### 错误信息

```
Annotations
1 error

❌ publish
   Resource not accessible by integration
```

### 完整错误日志

```
Run softprops/action-gh-release@v1
  with:
    files: dist/*
    generate_release_notes: true
    
Error: Resource not accessible by integration
```

---

## 原因分析

### 问题根源

GitHub Actions 中的 `GITHUB_TOKEN` 默认具有**只读权限**。当工作流尝试创建 GitHub Release 时，需要 `contents: write` 权限。

### 相关代码

**原始 `publish.yml`**（缺少权限声明）:
```yaml
name: Publish to PyPI

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
    # ... 其他步骤 ...
    
    - name: 创建 GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: dist/*
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**问题**: 没有明确授予 `contents: write` 权限。

---

## 解决方案

### 修复方法

在工作流文件顶部添加 `permissions` 字段：

```yaml
name: Publish to PyPI

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write  # ← 添加这一行！允许创建 Release

jobs:
  publish:
    runs-on: ubuntu-latest
    # ... 其余不变 ...
```

### 修复后的完整配置

```yaml
# 发布到 PyPI - 创建新 tag 时自动触发
name: Publish to PyPI

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write  # 允许创建 Release

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
    - name: 检出代码
      uses: actions/checkout@v4
    
    - name: 设置 Python 环境
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    
    - name: 安装构建工具
      run: |
        python -m pip install --upgrade pip
        pip install build twine
    
    - name: 构建分发包
      run: |
        python -m build
    
    - name: 检查分发包
      run: |
        twine check dist/*
    
    - name: 发布到 TestPyPI
      env:
        TWINE_USERNAME: __token__
        TWINE_PASSWORD: ${{ secrets.TESTPYPI_API_TOKEN }}
      run: |
        twine upload --repository testpypi dist/* --skip-existing
    
    - name: 发布到 PyPI
      env:
        TWINE_USERNAME: __token__
        TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
      run: |
        twine upload dist/*
    
    - name: 创建 GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: dist/*
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 重新运行步骤

### 方法 1: 重新创建 tag

```bash
# 1. 提交修复
git add .github/workflows/publish.yml
git commit -m "Fix: Add contents:write permission for GitHub Release"
git push origin main

# 2. 删除失败的 tag
git tag -d v0.4.0                    # 删除本地 tag
git push origin :refs/tags/v0.4.0    # 删除远程 tag

# 3. 重新创建并推送 tag
git tag v0.4.0
git push origin v0.4.0

# 4. GitHub Actions 会自动触发，这次应该成功
```

### 方法 2: 在 GitHub 页面重新运行

1. 先提交修复到 main 分支
2. 进入 Actions 页面
3. 点击失败的工作流
4. 点击 "Re-run jobs" 按钮

**注意**: 方法 2 会使用旧的工作流配置，建议使用方法 1。

---

## 权限说明

### GitHub Actions 权限类型

GitHub Actions 工作流可以请求以下权限：

| 权限 | 说明 | 用途 |
|------|------|------|
| `actions` | Actions 工作流 | 管理工作流 |
| `checks` | 检查 | 创建检查运行 |
| `contents` | 仓库内容 | 读写文件、创建 Release |
| `deployments` | 部署 | 创建部署 |
| `issues` | Issues | 创建、编辑 issue |
| `packages` | 包 | 发布包到 GitHub Packages |
| `pages` | GitHub Pages | 部署页面 |
| `pull-requests` | PR | 创建、编辑 PR |
| `repository-projects` | 项目 | 管理项目 |
| `statuses` | 状态 | 创建状态 |

### 权限级别

每个权限可以设置为：
- `read` - 只读（默认）
- `write` - 读写
- `none` - 无权限

### 最小权限原则

```yaml
# 推荐：明确指定需要的权限
permissions:
  contents: write  # 只授予必要的权限

# 不推荐：授予所有权限
permissions: write-all  # 安全风险！
```

---

## 相关文档

### 官方文档
- [GitHub Actions 权限](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [工作流语法 - permissions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#permissions)
- [创建 Release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)

### 相关 Actions
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [actions/create-release](https://github.com/actions/create-release) (已弃用)

---

## 其他注意事项

### 1. 仓库设置中的 Actions 权限

确保仓库允许 GitHub Actions 创建 Release：

**路径**: Settings → Actions → General → Workflow permissions

```
选项:
○ Read repository contents permission (默认，不够)
● Read and write permissions (需要这个)
  └─ ✅ Allow GitHub Actions to create and approve pull requests
```

### 2. 组织级别的限制

如果仓库属于组织，组织管理员可能限制了权限。需要联系管理员开启。

### 3. 私有仓库

私有仓库可能有额外的权限限制，需要确认仓库设置。

---

## 预防措施

### 1. 在配置文件中明确声明权限

```yaml
# 总是明确指定需要的权限
permissions:
  contents: write
  # 其他需要的权限...
```

### 2. 本地测试

使用 [act](https://github.com/nektos/act) 在本地测试工作流：

```bash
# 安装 act
brew install act

# 测试工作流
act push --eventpath .github/workflows/event.json
```

### 3. 分阶段发布

```yaml
# 可以将 Release 创建作为单独的工作流
# 这样即使 Release 失败，PyPI 发布仍然成功
```

---

## 总结

### 问题
- GitHub Actions 默认 `GITHUB_TOKEN` 只有只读权限
- 创建 Release 需要 `contents: write` 权限

### 解决
- 在工作流中添加 `permissions: contents: write`

### 影响
- v0.4.0 首次发布失败
- 修复后重新推送 tag 成功

### 经验教训
- ✅ 总是明确声明所需权限
- ✅ 先在 TestPyPI 测试完整流程
- ✅ 阅读 GitHub Actions 文档
- ✅ 查看类似项目的配置

---

**修复状态**: ✅ 已修复  
**修复版本**: v0.4.0（重新发布）  
**修复提交**: 添加 `permissions: contents: write` 到 `publish.yml`
