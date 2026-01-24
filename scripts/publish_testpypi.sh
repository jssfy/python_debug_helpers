#!/bin/bash

# 发布到 TestPyPI 的脚本

set -e  # 遇到错误立即退出

echo "==================================="
echo "发布到 TestPyPI"
echo "==================================="

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "脚本目录: $SCRIPT_DIR"
echo "项目目录: $PROJECT_DIR"
echo ""

cd "$PROJECT_DIR"

# 1. 清理旧的构建文件
echo ""
echo "步骤 1: 清理旧的构建文件..."
rm -rf dist/ build/ *.egg-info src/*.egg-info

# 2. 检查版本号
echo ""
echo "步骤 2: 检查版本号..."
VERSION=$(grep "version = " pyproject.toml | head -1 | cut -d'"' -f2)
echo "当前版本: $VERSION"

# 3. 构建分发包
echo ""
echo "步骤 3: 构建分发包..."
python3 -m build

# 4. 检查分发包
echo ""
echo "步骤 4: 检查分发包..."
python3 -m twine check dist/*

# 5. 显示生成的文件
echo ""
echo "步骤 5: 生成的文件:"
ls -lh dist/

# 6. 确认上传
echo ""
echo "==================================="
echo "准备上传到 TestPyPI"
echo "包名: $(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2)"
echo "版本: $VERSION"
echo "==================================="
echo ""
read -p "是否继续上传到 TestPyPI? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 7. 上传到 TestPyPI
    echo ""
    echo "步骤 6: 上传到 TestPyPI..."
    echo "请输入 TestPyPI 的认证信息:"
    echo "Username: __token__"
    echo "Password: (你的 TestPyPI token)"
    echo ""
    
    python3 -m twine upload --repository testpypi dist/*
    
    # 8. 显示结果
    PACKAGE_NAME=$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2)
    echo ""
    echo "==================================="
    echo "✅ 上传成功！"
    echo "==================================="
    echo ""
    echo "查看包: https://test.pypi.org/project/$PACKAGE_NAME/"
    echo ""
    echo "测试安装:"
    echo "  pip install -i https://test.pypi.org/simple/ $PACKAGE_NAME"
    echo ""
else
    echo ""
    echo "❌ 取消上传"
    exit 1
fi
