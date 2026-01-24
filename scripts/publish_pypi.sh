#!/bin/bash

# 发布到正式 PyPI 的脚本

set -e  # 遇到错误立即退出

echo "==================================="
echo "发布到正式 PyPI"
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

# 3. 检查是否在 PyPI 上已存在该版本
echo ""
echo "步骤 3: 检查版本是否已存在..."
PACKAGE_NAME=$(grep "name = " pyproject.toml | head -1 | cut -d'"' -f2)
echo "包名: $PACKAGE_NAME"

# 4. 构建分发包
echo ""
echo "步骤 4: 构建分发包..."
python3 -m build

# 5. 检查分发包
echo ""
echo "步骤 5: 检查分发包..."
python3 -m twine check dist/*

# 6. 显示生成的文件
echo ""
echo "步骤 6: 生成的文件:"
ls -lh dist/

# 7. 确认上传（双重确认）
echo ""
echo "==================================="
echo "⚠️  警告：准备上传到正式 PyPI"
echo "==================================="
echo "包名: $PACKAGE_NAME"
echo "版本: $VERSION"
echo ""
echo "⚠️  注意："
echo "  - 上传后无法删除或撤销"
echo "  - 相同版本号无法重新上传"
echo "  - 请确保已在 TestPyPI 测试通过"
echo ""
read -p "确定要上传到正式 PyPI 吗? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "❌ 取消上传"
    exit 1
fi

# 第二次确认
echo ""
read -p "再次确认：真的要上传到正式 PyPI 吗? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 8. 上传到正式 PyPI
    echo ""
    echo "步骤 7: 上传到正式 PyPI..."
    echo "请输入正式 PyPI 的认证信息:"
    echo "Username: __token__"
    echo "Password: (你的正式 PyPI token)"
    echo ""
    
    python3 -m twine upload dist/*
    
    # 9. 显示结果
    echo ""
    echo "==================================="
    echo "✅ 上传成功！"
    echo "==================================="
    echo ""
    echo "查看包: https://pypi.org/project/$PACKAGE_NAME/"
    echo ""
    echo "安装:"
    echo "  pip install $PACKAGE_NAME"
    echo ""
else
    echo ""
    echo "❌ 取消上传"
    exit 1
fi
