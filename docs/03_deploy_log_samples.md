# TestPyPI

admin ➜ ./scripts/publish_testpypi.sh
===================================
发布到 TestPyPI
===================================
脚本目录: /Users/admin/Downloads/sdk-generation/pypi/example_package/scripts
项目目录: /Users/admin/Downloads/sdk-generation/pypi/example_package


步骤 1: 清理旧的构建文件...

步骤 2: 检查版本号...
当前版本: 0.2.0

步骤 3: 构建分发包...
* Creating isolated environment: venv+pip...
* Installing packages in isolated environment:
  - hatchling
* Getting build dependencies for sdist...
* Building sdist...
* Building wheel from sdist
* Creating isolated environment: venv+pip...
* Installing packages in isolated environment:
  - hatchling
* Getting build dependencies for wheel...
* Building wheel...
Successfully built yeannhua_example_package_demo-0.2.0.tar.gz and yeannhua_example_package_demo-0.2.0-py3-none-any.whl

步骤 4: 检查分发包...
Checking dist/yeannhua_example_package_demo-0.2.0-py3-none-any.whl: PASSED
Checking dist/yeannhua_example_package_demo-0.2.0.tar.gz: PASSED

步骤 5: 生成的文件:
total 64
-rw-r--r--@ 1 admin  staff   5.8K 24 Jan 20:38 yeannhua_example_package_demo-0.2.0-py3-none-any.whl
-rw-r--r--@ 1 admin  staff    24K 24 Jan 20:38 yeannhua_example_package_demo-0.2.0.tar.gz

===================================
准备上传到 TestPyPI
包名: yeannhua-example-package-demo
版本: 0.2.0
===================================

是否继续上传到 TestPyPI? (y/n) y

步骤 6: 上传到 TestPyPI...
请输入 TestPyPI 的认证信息:
Username: __token__
Password: (你的 TestPyPI token)

Uploading distributions to https://test.pypi.org/legacy/
Uploading yeannhua_example_package_demo-0.2.0-py3-none-any.whl
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 11.1/11.1 kB • 00:00 • ?
Uploading yeannhua_example_package_demo-0.2.0.tar.gz
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 29.5/29.5 kB • 00:00 • 87.9 MB/s

View at:
https://test.pypi.org/project/yeannhua-example-package-demo/0.2.0/

===================================
✅ 上传成功！
===================================

查看包: https://test.pypi.org/project/yeannhua-example-package-demo/

测试安装:
  pip install -i https://test.pypi.org/simple/ yeannhua-example-package-demo

# PyPI


admin ➜ ./scripts/publish_pypi.sh
===================================
发布到正式 PyPI
===================================
脚本目录: /Users/admin/Downloads/sdk-generation/pypi/example_package/scripts
项目目录: /Users/admin/Downloads/sdk-generation/pypi/example_package


步骤 1: 清理旧的构建文件...

步骤 2: 检查版本号...
当前版本: 0.2.0

步骤 3: 检查版本是否已存在...
包名: yeannhua-example-package-demo

步骤 4: 构建分发包...
* Creating isolated environment: venv+pip...
* Installing packages in isolated environment:
  - hatchling
* Getting build dependencies for sdist...
* Building sdist...
* Building wheel from sdist
* Creating isolated environment: venv+pip...
* Installing packages in isolated environment:
  - hatchling
* Getting build dependencies for wheel...
* Building wheel...
Successfully built yeannhua_example_package_demo-0.2.0.tar.gz and yeannhua_example_package_demo-0.2.0-py3-none-any.whl

步骤 5: 检查分发包...
Checking dist/yeannhua_example_package_demo-0.2.0-py3-none-any.whl: PASSED
Checking dist/yeannhua_example_package_demo-0.2.0.tar.gz: PASSED

步骤 6: 生成的文件:
total 64
-rw-r--r--@ 1 admin  staff   5.8K 24 Jan 20:45 yeannhua_example_package_demo-0.2.0-py3-none-any.whl
-rw-r--r--@ 1 admin  staff    24K 24 Jan 20:45 yeannhua_example_package_demo-0.2.0.tar.gz

===================================
⚠️  警告：准备上传到正式 PyPI
===================================
包名: yeannhua-example-package-demo
版本: 0.2.0

⚠️  注意：
  - 上传后无法删除或撤销
  - 相同版本号无法重新上传
  - 请确保已在 TestPyPI 测试通过

确定要上传到正式 PyPI 吗? (y/n) y

再次确认：真的要上传到正式 PyPI 吗? (y/n) y

步骤 7: 上传到正式 PyPI...
请输入正式 PyPI 的认证信息:
Username: __token__
Password: (你的正式 PyPI token)

Uploading distributions to https://upload.pypi.org/legacy/
Uploading yeannhua_example_package_demo-0.2.0-py3-none-any.whl
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 11.1/11.1 kB • 00:00 • ?
Uploading yeannhua_example_package_demo-0.2.0.tar.gz
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 29.4/29.4 kB • 00:00 • 68.4 MB/s

View at:
https://pypi.org/project/yeannhua-example-package-demo/0.2.0/

===================================
✅ 上传成功！
===================================

查看包: https://pypi.org/project/yeannhua-example-package-demo/

安装:
  pip install yeannhua-example-package-demo