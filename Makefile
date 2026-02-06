.PHONY: help install-local install-test install uninstall test example clean build publish-test publish-pypi release-as

# 默认目标：显示帮助信息
help:
	@echo "============================================"
	@echo "  debug-helpers Makefile"
	@echo "============================================"
	@echo ""
	@echo "安装命令："
	@echo "  make install-local  - 开发模式安装到本地 (pip install -e .)"
	@echo "  make install-test   - 从 TestPyPI 安装"
	@echo "  make install        - 从正式 PyPI 安装"
	@echo "  make uninstall      - 卸载包"
	@echo ""
	@echo "开发命令："
	@echo "  make test           - 运行单元测试"
	@echo "  make example        - 运行示例代码"
	@echo "  make clean          - 清理构建文件"
	@echo "  make build          - 构建分发包"
	@echo ""
	@echo "发布命令："
	@echo "  make release-as V=x.y.z - 强制指定版本号发版（Release Please）"
	@echo "  make publish-test       - 发布到 TestPyPI"
	@echo "  make publish-pypi       - 发布到正式 PyPI"
	@echo ""
	@echo "常用工作流："
	@echo "  开发阶段："
	@echo "    1. make install-local  - 本地安装"
	@echo "    2. make example        - 测试功能"
	@echo "  发布阶段："
	@echo "    3. make publish-test   - 发布到 TestPyPI"
	@echo "    4. make install-test   - 验证 TestPyPI 安装"
	@echo "    5. make publish-pypi   - 发布到正式 PyPI"
	@echo "    6. make install        - 验证正式安装"
	@echo ""

# 开发模式安装到本地
install-local:
	@echo "==> 开发模式安装到本地..."
	@echo "使用: pip install -e ."
	@echo ""
	pip install -e .
	@echo ""
	@echo "✅ 本地安装完成！"
	@echo ""
	@echo "验证:"
	@echo "  pip show debug-helpers"
	@echo "  python -c 'from debug_helpers import __version__; print(__version__)'"

# 从 TestPyPI 安装
install-test: uninstall
	@echo "==> 从 TestPyPI 安装..."
	@echo ""
	@VERSION=$$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2); \
	PACKAGE=$$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2); \
	echo "包名: $$PACKAGE"; \
	echo "版本: $$VERSION"; \
	echo ""; \
	pip install -i https://test.pypi.org/simple/ $$PACKAGE
	@echo ""
	@echo "✅ TestPyPI 安装完成！"
	@echo ""
	@echo "验证:"
	@echo "  pip show debug-helpers"
	@echo "  python -c 'from debug_helpers import hello; print(hello(\"TestPyPI\"))'"

# 从正式 PyPI 安装
install: uninstall
	@echo "==> 从正式 PyPI 安装..."
	@echo ""
	@VERSION=$$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2); \
	PACKAGE=$$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2); \
	echo "包名: $$PACKAGE"; \
	echo "版本: $$VERSION"; \
	echo ""; \
	pip install -i https://pypi.org/simple/ $$PACKAGE
	@echo ""
	@echo "✅ PyPI 安装完成！"
	@echo ""
	@echo "验证:"
	@echo "  pip show debug-helpers"
	@echo "  python -c 'from debug_helpers import hello; print(hello(\"PyPI\"))'"

# 卸载包
uninstall:
	@echo "==> 卸载 debug-helpers..."
	pip uninstall -y debug-helpers || echo "包未安装"
	@echo "✅ 卸载完成！"

# 运行单元测试
test:
	@echo "==> 运行单元测试..."
	@echo ""
	@if command -v pytest >/dev/null 2>&1; then \
		echo "使用 pytest 运行测试..."; \
		pytest tests/ -v; \
	else \
		echo "使用 unittest 运行测试..."; \
		python -m unittest discover -s tests -v; \
	fi
	@echo ""
	@echo "💡 提示: 安装 pytest 可以获得更好的测试体验"
	@echo "   pip install -e '.[dev]'"

# 运行示例代码
example:
	@echo "==> 运行示例代码..."
	@echo ""
	python3 examples/test.py

# 清理构建文件
clean:
	@echo "==> 清理构建文件..."
	@echo "删除 dist/ build/ *.egg-info"
	rm -rf dist/ build/ *.egg-info src/*.egg-info
	@echo "删除 __pycache__ 和 .pyc 文件"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	@echo "删除 pytest 缓存"
	rm -rf .pytest_cache
	@echo "删除覆盖率文件"
	rm -rf .coverage htmlcov/
	@echo "删除 mypy 缓存"
	rm -rf .mypy_cache
	@echo ""
	@echo "✅ 清理完成！"
	@echo ""
	@echo "已清理的内容："
	@echo "  - dist/           (分发包)"
	@echo "  - build/          (构建临时文件)"
	@echo "  - *.egg-info      (包元数据)"
	@echo "  - __pycache__/    (Python 缓存)"
	@echo "  - *.pyc/*.pyo     (编译文件)"
	@echo "  - .pytest_cache   (pytest 缓存)"
	@echo "  - .coverage       (覆盖率数据)"
	@echo "  - .mypy_cache     (类型检查缓存)"

# 构建分发包
build: clean
	@echo "==> 构建分发包..."
	python3 -m build
	@echo ""
	@echo "==> 检查分发包..."
	python3 -m twine check dist/*
	@echo ""
	@echo "✅ 构建完成！"
	@echo "生成的文件："
	@ls -lh dist/

# 强制指定版本号发版（通过 Release Please 的 Release-As 指令）
# 用法: make release-as V=0.4.3
release-as:
ifndef V
	@echo "❌ 请指定版本号，用法: make release-as V=x.y.z"
	@echo "   示例: make release-as V=0.4.3"
	@exit 1
endif
	@CURRENT=$$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2); \
	echo ""; \
	echo "=========================================="; \
	echo "  Release Please: 强制指定版本号"; \
	echo "=========================================="; \
	echo ""; \
	echo "当前版本: $$CURRENT"; \
	echo "目标版本: $(V)"; \
	echo ""; \
	read -p "确认发版到 $(V)? (y/n) " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		echo "==> 创建 Release-As commit..."; \
		git commit --allow-empty -m "chore: prepare release $(V)" -m "Release-As: $(V)"; \
		echo ""; \
		echo "==> 推送到 main..."; \
		git push origin main; \
		echo ""; \
		echo "✅ 已推送！Release Please 将创建 release: $(V) 的 PR"; \
		echo ""; \
		echo "后续步骤:"; \
		echo "  1. 等待 Release Please 创建/更新 Release PR"; \
		echo "  2. 在 GitHub 上审核并合入 PR"; \
		echo "  3. publish.yml 自动触发 → 发布到 PyPI"; \
	else \
		echo "❌ 取消"; \
		exit 1; \
	fi

# 发布到 TestPyPI
publish-test: build
	@echo ""
	@echo "=========================================="
	@echo "  准备发布到 TestPyPI"
	@echo "=========================================="
	@echo ""
	@VERSION=$$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2); \
	PACKAGE=$$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2); \
	echo "包名: $$PACKAGE"; \
	echo "版本: $$VERSION"; \
	echo ""; \
	read -p "确认上传到 TestPyPI? (y/n) " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		echo "==> 上传到 TestPyPI..."; \
		python3 -m twine upload --repository testpypi dist/*; \
		echo ""; \
		echo "✅ 上传成功！"; \
		echo ""; \
		echo "查看: https://test.pypi.org/project/$$PACKAGE/"; \
		echo "安装: pip install -i https://test.pypi.org/simple/ $$PACKAGE"; \
	else \
		echo "❌ 取消上传"; \
		exit 1; \
	fi

# 发布到正式 PyPI
publish-pypi: build
	@echo ""
	@echo "=========================================="
	@echo "  ⚠️  准备发布到正式 PyPI"
	@echo "=========================================="
	@echo ""
	@VERSION=$$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2); \
	PACKAGE=$$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2); \
	echo "包名: $$PACKAGE"; \
	echo "版本: $$VERSION"; \
	echo ""; \
	echo "⚠️  注意:"; \
	echo "  - 上传后无法删除或撤销"; \
	echo "  - 相同版本号无法重新上传"; \
	echo "  - 请确保已在 TestPyPI 测试通过"; \
	echo ""; \
	read -p "确定要上传到正式 PyPI 吗? (y/n) " -n 1 -r; \
	echo ""; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "❌ 取消上传"; \
		exit 1; \
	fi; \
	echo ""; \
	read -p "再次确认：真的要上传到正式 PyPI 吗? (y/n) " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		echo "==> 上传到正式 PyPI..."; \
		python3 -m twine upload dist/*; \
		echo ""; \
		echo "✅ 上传成功！"; \
		echo ""; \
		echo "查看: https://pypi.org/project/$$PACKAGE/"; \
		echo "安装: pip install $$PACKAGE"; \
	else \
		echo "❌ 取消上传"; \
		exit 1; \
	fi

# 完整的本地测试流程
test-local: uninstall install-local example
	@echo ""
	@echo "✅ 本地测试完成！"

# 检查包信息
info:
	@echo "==> 包信息"
	@pip show debug-helpers || echo "包未安装"
	@echo ""
	@echo "==> 当前版本"
	@grep "version = " pyproject.toml | head -1
