# GitHub Actions Token 配置指南

## 🔐 Token 设置完整流程

在 `publish.yml` 中使用的 token 需要在**两个地方**配置：

1. **PyPI/TestPyPI 网站** - 获取 API Token
2. **GitHub 仓库** - 配置 Secrets

---

## 📝 步骤 1: 获取 PyPI API Token

### 1.1 获取 TestPyPI Token

1. **访问 TestPyPI**
   ```
   https://test.pypi.org/manage/account/
   ```

2. **登录账号**
   - 如果没有账号，先注册：https://test.pypi.org/account/register/

3. **生成 API Token**
   - 滚动到页面底部的 "API tokens" 部分
   - 点击 "Add API token"
   
4. **填写信息**
   ```
   Token name: GitHub Actions - debug-helpers
   Scope: 
     ⚪ Entire account (所有项目)
     🔘 Project: debug-helpers (推荐，仅限此项目)
   ```

5. **保存 Token**
   ```
   ⚠️ 重要: 复制显示的 token
   格式: pypi-AgEIcHlwaS5vcmcC...很长的字符串
   
   ⚠️ 这个 token 只显示一次！
   立即保存到安全的地方
   ```

### 1.2 获取正式 PyPI Token

1. **访问 PyPI**
   ```
   https://pypi.org/manage/account/
   ```

2. **登录账号**
   - 如果没有账号，先注册：https://pypi.org/account/register/

3. **生成 API Token**（步骤与 TestPyPI 相同）
   - 滚动到 "API tokens" 部分
   - 点击 "Add API token"
   
4. **填写信息**
   ```
   Token name: GitHub Actions - debug-helpers
   Scope: 
     ⚪ Entire account
     🔘 Project: debug-helpers (推荐)
   ```

5. **保存 Token**
   ```
   ⚠️ 立即复制并保存 token
   格式: pypi-AgEIcHlwaS5vcmcC...
   ```

---

## 🔧 步骤 2: 在 GitHub 配置 Secrets

### 2.1 进入仓库设置

1. **打开你的 GitHub 仓库**
   ```
   https://github.com/你的用户名/python_debug_helpers
   ```

2. **进入 Settings**
   ```
   仓库页面 → Settings 标签（⚙️ 齿轮图标）
   ```

3. **进入 Secrets 设置**
   ```
   左侧菜单：
   Security → Secrets and variables → Actions
   ```

### 2.2 添加 TestPyPI Token

1. **点击 "New repository secret"** 按钮

2. **填写第一个 Secret**
   ```
   Name: TESTPYPI_API_TOKEN
   
   Secret: 
   粘贴从 test.pypi.org 获取的 token
   例如: pypi-AgEIcHlwaS5vcmcCJDM4...
   ```

3. **点击 "Add secret"** 保存

### 2.3 添加 PyPI Token

1. **再次点击 "New repository secret"** 按钮

2. **填写第二个 Secret**
   ```
   Name: PYPI_API_TOKEN
   
   Secret: 
   粘贴从 pypi.org 获取的 token
   例如: pypi-AgEIcHlwaS5vcmcCJDg5...
   ```

3. **点击 "Add secret"** 保存

### 2.4 验证配置

配置完成后，你应该看到：

```
Repository secrets
┌────────────────────────────────────────┐
│ PYPI_API_TOKEN                Updated │
│ TESTPYPI_API_TOKEN            Updated │
└────────────────────────────────────────┘

Environment secrets
(empty)
```

---

## 🎯 详细配置路径

### PyPI/TestPyPI Token 获取路径

```
TestPyPI Token:
https://test.pypi.org/
  └─ Account settings (右上角头像)
      └─ API tokens
          └─ Add API token
              └─ 填写 token name 和 scope
                  └─ [Generate token]
                      └─ 📋 复制 token

PyPI Token:
https://pypi.org/
  └─ Account settings (右上角头像)
      └─ API tokens
          └─ Add API token
              └─ 填写 token name 和 scope
                  └─ [Generate token]
                      └─ 📋 复制 token
```

### GitHub Secrets 配置路径

```
GitHub 仓库:
https://github.com/你的用户名/python_debug_helpers
  └─ Settings
      └─ Secrets and variables
          └─ Actions
              └─ New repository secret
                  ├─ Name: TESTPYPI_API_TOKEN
                  │   Value: pypi-AgEI...
                  │   [Add secret]
                  │
                  └─ Name: PYPI_API_TOKEN
                      Value: pypi-AgEI...
                      [Add secret]
```

---

## 🔒 安全最佳实践

### 1. Token 权限范围

```
推荐（最安全）:
Scope: Project - debug-helpers
✅ 仅能上传此项目
❌ 不能上传其他项目

不推荐:
Scope: Entire account
✅ 可以上传所有项目
⚠️ 如果 token 泄露，风险更大
```

### 2. Token 命名

```
推荐的命名格式:
- GitHub Actions - <项目名>
- CI/CD - debug-helpers
- Auto Publish - debug-helpers

好处:
✅ 清楚知道 token 用途
✅ 方便管理多个 token
✅ 出问题时容易定位
```

### 3. Token 管理

```
定期检查:
- 删除不再使用的 token
- 检查 token 的最后使用时间
- 如果怀疑泄露，立即删除并重新生成
```

### 4. 安全提示

```
⚠️ 永远不要：
❌ 在代码中硬编码 token
❌ 将 token 提交到 Git
❌ 在聊天、邮件中发送 token
❌ 截图时包含完整 token

✅ 应该：
✅ 只保存在 GitHub Secrets 中
✅ 使用 Project scope 限制权限
✅ 定期轮换 token
✅ 使用描述性的名称
```

---

## 🧪 验证 Token 配置

### 方法 1: 通过 GitHub Actions 验证

1. **创建测试 tag**
   ```bash
   git tag v0.3.0-test
   git push origin v0.3.0-test
   ```

2. **查看 Actions 运行**
   - 进入 "Actions" 标签
   - 查看 "Publish to PyPI" 工作流
   - 如果配置正确，应该成功运行

3. **清理测试 tag**
   ```bash
   git tag -d v0.3.0-test
   git push origin :refs/tags/v0.3.0-test
   ```

### 方法 2: 本地验证 Token

使用 `twine` 手动测试：

```bash
# 测试 TestPyPI token
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=你的testpypi_token

twine upload --repository testpypi dist/*

# 如果成功，说明 token 有效
```

---

## ❓ 常见问题

### Q1: 找不到 "Add API token" 按钮？

**答**: 
1. 确保已经登录
2. 确保访问的是账号设置页面：
   - TestPyPI: https://test.pypi.org/manage/account/
   - PyPI: https://pypi.org/manage/account/
3. 滚动到页面底部

### Q2: 第一次发布时，Scope 选什么？

**答**:
```
首次发布时，项目还不存在，应该选择:
- Scope: Entire account

发布成功后，重新生成 token:
- Scope: Project: debug-helpers (更安全)
```

### Q3: Token 丢失了怎么办？

**答**:
```
Token 只显示一次，丢失后无法找回。

解决方法:
1. 在 PyPI/TestPyPI 上删除旧 token
2. 生成新的 token
3. 在 GitHub Secrets 中更新
```

### Q4: 多个项目可以用同一个 token 吗？

**答**:
```
技术上可以（使用 Entire account scope），但不推荐。

推荐做法:
- 每个项目使用独立的 token
- 使用 Project scope 限制权限
- 便于管理和追踪
```

### Q5: 怎么知道 token 是否有效？

**答**:
```
方法 1: 查看 PyPI/TestPyPI 账号设置
- 显示 "Last used: X days ago"

方法 2: 触发一次 GitHub Actions
- 如果上传成功，token 有效

方法 3: 本地测试
- 使用 twine 手动上传测试
```

### Q6: GitHub Secrets 可以被别人看到吗？

**答**:
```
❌ 不能！GitHub Secrets 是加密的。

- 仓库管理员也无法查看 secret 的值
- 只能看到 secret 的名称
- 只能删除或更新，不能查看
- Actions 运行日志中会自动隐藏 secret

安全性很高！✅
```

---

## 📋 配置检查清单

完成配置后，请检查：

```
TestPyPI Token:
☐ 已在 test.pypi.org 生成 token
☐ 已复制并保存 token
☐ 已在 GitHub 添加 secret: TESTPYPI_API_TOKEN
☐ Token scope 设置为项目级别（推荐）

PyPI Token:
☐ 已在 pypi.org 生成 token
☐ 已复制并保存 token
☐ 已在 GitHub 添加 secret: PYPI_API_TOKEN
☐ Token scope 设置为项目级别（推荐）

GitHub Secrets:
☐ Secret 名称完全匹配（大小写敏感）
☐ 可以在 Settings → Secrets and variables → Actions 中看到
☐ 显示为 "Updated X minutes ago"

测试:
☐ 创建测试 tag 验证（可选）
☐ 查看 Actions 运行日志（可选）
```

---

## 🎯 快速参考

### Token 获取地址

| 平台 | Token 管理页面 |
|------|---------------|
| **TestPyPI** | https://test.pypi.org/manage/account/ |
| **PyPI** | https://pypi.org/manage/account/ |

### GitHub Secrets 路径

```
仓库 → Settings → Secrets and variables → Actions → New repository secret
```

### Secret 名称（必须完全匹配）

| 名称 | 用途 |
|------|------|
| `TESTPYPI_API_TOKEN` | TestPyPI 上传 |
| `PYPI_API_TOKEN` | PyPI 上传 |

### Token 格式

```
pypi-AgEIcHlwaS5vcmcCJDM4ZjkyMTg...（很长的字符串）
```

---

## 📚 相关文档

- [PyPI API Token 文档](https://pypi.org/help/#apitoken)
- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Twine 文档](https://twine.readthedocs.io/)

配置完成后，你的 GitHub Actions 就可以自动发布到 PyPI 了！🚀
