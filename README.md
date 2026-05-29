# ABC商户贷助手

一款帮助客户经理完成商户贷款资料收集、录入、整理工作的iOS应用程序。

## 功能特点

### 核心功能
- **客户管理**：创建、编辑、删除客户信息
- **资料导入**：支持从相册、文件管理器导入多种格式文件（图片、PDF、Excel、Word）
- **OCR识别**：自动识别身份证、营业执照等证件信息
- **数据校验**：验证身份证号码、电话号码等信息的正确性
- **PDF生成**：自动生成客户资料清单PDF文件
- **离线工作**：所有功能无需网络环境即可使用

### 支持的资料类型
1. 贷款资料封面
2. 资料清单目录
3. 个人客户身份识别和尽职调查信息表
4. 营业执照
5. 身份证-客户
6. 身份证-配偶
7. 结婚证/离婚证
8. 户口本
9. 房产证明
10. 租赁合同
11. 资产证明
12. 存货证明
13. 个人贷款"阳光办贷"告知函-客户
14. "清廉办贷"告知函-客户
15. 个人征信业务授权书-客户
16. 信息查询授权书-客户
17. 风险提示-客户
18. 个人贷款"阳光办贷"告知函-配偶
19. "清廉办贷"告知函-配偶
20. 个人征信业务授权书-配偶
21. 信息查询授权书-配偶
22. 风险提示-配偶
23. 征信报告-客户
24. 征信报告-配偶
25. 上门调查照片
26. 外部工商信息查询图片
27. 失信被执行人查询图片
28. 经营收入认定表
29. 收入流水总览截图
30. 流水PDF文件

## 安装方法

### 使用Sideloadly安装（推荐）

1. **下载Sideloadly**
   - 访问 [Sideloadly官网](https://sideloadly.io/) 下载并安装Sideloadly

2. **获取IPA文件**
   - 在本仓库的[Releases](https://github.com/yourusername/ABCMerchantLoanAssistant/releases)页面下载最新的IPA文件
   - 或者通过GitHub Actions自动构建获取

3. **连接设备**
   - 使用USB数据线连接你的iOS设备到电脑
   - 确保设备已解锁并信任此电脑

4. **安装应用**
   - 打开Sideloadly
   - 将下载的IPA文件拖入Sideloadly
   - 输入你的Apple ID和密码
   - 点击"Start"开始安装

5. **信任开发者**
   - 安装完成后，在iOS设备上打开"设置" > "通用" > "VPN与设备管理"
   - 找到你的Apple ID并点击"信任"

### 注意事项

- 免费Apple ID签名的应用程序有效期为7天，过期后需要重新签名安装
- 建议使用专用的Apple ID进行签名，不要使用重要账户
- 如果遇到安装失败，请检查设备是否已解锁并信任电脑

## 开发相关

### 环境要求
- Xcode 15.0或更高版本
- iOS 17.0或更高版本
- macOS（用于开发和构建）

### 构建项目
```bash
# 克隆仓库
git clone https://github.com/yourusername/ABCMerchantLoanAssistant.git

# 打开Xcode项目
open ABCMerchantLoanAssistant.xcodeproj

# 在Xcode中选择你的开发团队并构建
```

### GitHub Actions自动构建
本项目配置了GitHub Actions工作流，可以在每次推送到main分支时自动构建iOS应用。

## 技术架构

- **UI框架**: SwiftUI
- **数据存储**: UserDefaults + JSON
- **OCR识别**: VisionKit框架
- **PDF生成**: PDFKit框架
- **文件导入**: UniformTypeIdentifiers

## 许可证

本项目仅供内部使用，未经授权不得分发。

## 联系方式

如有问题或建议，请联系项目维护者。
