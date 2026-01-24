#!/bin/bash

# 本地安装和测试脚本

set -e  # 遇到错误立即退出

echo "=================================="
echo "本地安装和测试 debug_tools"
echo "=================================="
echo ""

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "步骤 1: 检查 Python 版本"
python3 --version
echo ""

echo "步骤 2: 检查是否已安装"
if pip show debug-tools > /dev/null 2>&1; then
    echo "包已安装，先卸载..."
    pip uninstall -y debug-tools
fi
echo ""

echo "步骤 3: 开发模式安装（-e）"
echo "这样修改代码后会立即生效"
pip install -e .
echo ""

echo "步骤 4: 验证安装"
pip show debug-tools
echo ""

echo "步骤 5: 运行示例测试"
python3 examples/test.py
echo ""

echo "=================================="
echo "✅ 安装和测试完成！"
echo "=================================="
echo ""
echo "提示："
echo "  - 包已以开发模式安装"
echo "  - 修改代码后会立即生效"
echo "  - 卸载: pip uninstall debug-tools"
echo "  - 运行示例: python3 examples/test.py"
echo "  - 运行单元测试: pytest tests/"
