# CI Test 改进分析 & Prism / Pydantic 双版本适用场景

## 核心结论

- `test.yml` 已补齐 `timeout-minutes: 10`，合并冗余步骤，与 lint.yml / build.yml 风格对齐
- **Prism mock server** — 当项目变成「调用外部 API 的客户端库」时才需要引入
- **Pydantic 双版本测试** — 当项目的公开 API 接受/返回 Pydantic model 时才需要引入
- 当前 debug_helpers 是纯工具库，无外部 API 依赖、无 Pydantic 依赖，**两者都不需要**

## test.yml 本次改动

| 改动 | 原因 |
|------|------|
| 添加 `timeout-minutes: 10` | 与 lint.yml / build.yml 一致，防止测试卡住消耗 6 小时 CI 额度 |
| 合并"显示 Python 版本"+"升级 pip"+"安装依赖"为一个 step | 减少噪音，与 lint.yml 的安装步骤风格一致 |
| 移除"显示已安装的包" | `pip install` 输出已包含安装信息，单独 `pip list` 冗余 |

改动前 8 个 step → 改动后 5 个 step，逻辑不变。

---

## Prism Mock Server：什么时候需要？

### 它是什么

[Prism](https://github.com/stoplightio/prism) 是一个基于 OpenAPI spec 自动生成 mock HTTP server 的工具。evermemos-python 的 `scripts/test` 在跑 pytest 前会自动启动 Prism：

```bash
# 启动 mock server（监听 localhost:4010）
./scripts/mock --daemon
# 测试结束后自动 kill
trap 'kill_server_on_port 4010' EXIT
```

测试代码发出的 HTTP 请求打到 Prism 而非真实 API，Prism 根据 OpenAPI spec 返回符合 schema 的假数据。

### 适用场景判断

| 场景 | 是否需要 Prism | 说明 |
|------|:-------------:|------|
| 纯工具库（当前 debug_helpers） | **否** | 没有 HTTP 调用，没有外部依赖 |
| 封装第三方 API 的 SDK | **是** | 如 evermemos-python 封装 EverMemOS API |
| 有 HTTP client 调用外部服务的库 | **看情况** | 简单场景用 `responses`/`respx` mock 即可；接口多且有 OpenAPI spec 时用 Prism 更高效 |
| Web 应用（FastAPI/Django） | **通常否** | 用 TestClient / pytest-django 测试自己的 API，不需要 mock 自己 |

### 引入 Prism 的信号

当以下条件**同时满足**时，考虑引入 Prism：

1. 项目是某个 REST API 的客户端 SDK
2. 该 API 有 OpenAPI / Swagger spec 文件
3. API 端点数量多（>10 个），手写 mock 维护成本高
4. 需要验证请求/响应格式是否符合 spec

### 不用 Prism 的替代方案

对于简单的 HTTP mock 需求（几个端点），Python 生态有更轻量的方案：

| 工具 | 适用场景 | 侵入性 |
|------|---------|--------|
| `unittest.mock.patch` | mock 任意函数/方法 | 低 |
| [`responses`](https://github.com/getsentry/responses) | mock `requests` 库的 HTTP 调用 | 低 |
| [`respx`](https://github.com/lundberg/respx) | mock `httpx` 库的 HTTP 调用 | 低 |
| [`pytest-httpserver`](https://github.com/csernazs/pytest-httpserver) | 启动真实 HTTP server | 中 |
| **Prism** | 基于 OpenAPI spec 的全自动 mock | 高（需要 Node.js + spec 文件） |

**决策规则：** 端点少 → responses/respx；端点多 + 有 spec → Prism。

---

## Pydantic 双版本测试：什么时候需要？

### evermemos-python 为什么要测 v1 + v2

evermemos-python 的 API 响应会被反序列化为 Pydantic model。Pydantic v1 → v2 是破坏性升级（API 完全重写），SDK 需要同时支持两个版本的用户：

```python
# Pydantic v2 写法
class User(BaseModel):
    model_config = ConfigDict(...)     # v2 API

# Pydantic v1 写法
class User(BaseModel):
    class Config:                       # v1 API
        ...
```

所以 evermemos 的 `scripts/test` 跑两轮：

```bash
# 第一轮：默认依赖（Pydantic v2）
uv run --isolated --all-extras pytest

# 第二轮：切换到 Pydantic v1 依赖组
uv run --isolated --all-extras --group=pydantic-v1 pytest
```

### 适用场景判断

| 场景 | 是否需要双版本测试 | 说明 |
|------|:-----------------:|------|
| 不依赖 Pydantic（当前 debug_helpers） | **否** | 根本没用 Pydantic |
| 内部项目，Pydantic 版本可控 | **否** | 锁定一个版本即可 |
| 公开库，公开 API 暴露 Pydantic model | **是** | 用户可能用 v1 或 v2 |
| 公开库，内部用 Pydantic 但不暴露 | **看情况** | 可以锁定版本，但如果与用户的 Pydantic 版本冲突则需要兼容 |

### 引入双版本测试的信号

当以下条件**同时满足**时，考虑引入：

1. `pyproject.toml` 的 `dependencies` 中包含 `pydantic`
2. 项目的公开 API（函数参数、返回值）使用了 Pydantic BaseModel
3. 项目面向公开发布（PyPI），用户群可能混用 v1/v2
4. 依赖声明是 `pydantic>=1.0` 这样的宽范围，而非锁定 `pydantic>=2.0`

### 如果未来 debug_helpers 需要引入

假设未来 debug_helpers 添加了一个 `print_model(obj: BaseModel)` 函数，需要兼容 Pydantic v1/v2，实现方式：

**1. 在 `pyproject.toml` 中添加依赖组：**

```toml
[project.optional-dependencies]
pydantic-v1 = ["pydantic>=1.10,<2.0"]

[project]
dependencies = ["pydantic>=1.10"]  # 宽范围兼容
```

**2. 在 test.yml 中添加 matrix 维度：**

```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11', '3.12', '3.13']
    pydantic-version: ['v1', 'v2']
    exclude:
      - python-version: '3.13'
        pydantic-version: 'v1'  # Pydantic v1 不支持 3.13
```

**3. 在安装步骤中按 matrix 切换：**

```yaml
- name: 安装项目和开发依赖
  run: |
    python -m pip install --upgrade pip
    pip install -e '.[dev]'
    if [ "${{ matrix.pydantic-version }}" = "v1" ]; then
      pip install 'pydantic>=1.10,<2.0'
    fi
```

这样 matrix 会从 5 个 job 扩展到 9 个（5×2 - 1 个 exclude）。

---

## 总结：debug_helpers 当前不需要这两项

```
debug_helpers 现状：
  ├── 纯 Python 工具函数（hello, add, print_dict）
  ├── 无 HTTP 调用 → 不需要 Prism
  ├── 无 Pydantic 依赖 → 不需要双版本测试
  └── CI 已覆盖：lint + build + test(5 版本) + publish

未来触发条件：
  ├── 添加 HTTP client 功能 → 评估 responses/respx 或 Prism
  └── 添加 Pydantic model    → 评估是否需要 v1/v2 兼容
```
