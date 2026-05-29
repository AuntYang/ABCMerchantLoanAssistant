import Foundation

struct Customer: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String
    var spousePhone: String
    var address: String
    var idNumber: String
    var spouseIdNumber: String
    var businessLicenseType: String
    var gender: String
    var spouseGender: String
    var idExpiryDate: Date?
    var spouseIdExpiryDate: Date?
    var documents: [Document]
    
    init(name: String, phone: String, spousePhone: String, address: String) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.spousePhone = spousePhone
        self.address = address
        self.idNumber = ""
        self.spouseIdNumber = ""
        self.businessLicenseType = ""
        self.gender = ""
        self.spouseGender = ""
        self.documents = []
    }
    
    func hasDocument(type: DocumentType) -> Bool {
        documents.contains { $0.type == type }
    }
    
    func getDocument(type: DocumentType) -> Document? {
        documents.first { $0.type == type }
    }
}

enum DocumentType: String, Codable, CaseIterable {
    case loanCover = "贷款资料封面"
    case documentCatalog = "资料清单目录"
    case identityInvestigation = "个人客户身份识别和尽职调查信息表"
    case businessLicense = "营业执照"
    case idCardCustomer = "身份证-客户"
    case idCardSpouse = "身份证-配偶"
    case marriageCertificate = "结婚证/离婚证"
    case householdRegister = "户口本"
    case propertyCertificate = "房产证明"
    case rentalContract = "租赁合同"
    case assetCertificate = "资产证明"
    case inventoryCertificate = "存货证明"
    case sunshineLoanNoticeCustomer = "个人贷款阳光办贷告知函-客户"
    case cleanLoanNoticeCustomer = "清廉办贷告知函-客户"
    case creditAuthorizationCustomer = "个人征信业务授权书-客户"
    case informationQueryAuthorizationCustomer = "信息查询授权书-客户"
    case riskWarningCustomer = "风险提示-客户"
    case sunshineLoanNoticeSpouse = "个人贷款阳光办贷告知函-配偶"
    case cleanLoanNoticeSpouse = "清廉办贷告知函-配偶"
    case creditAuthorizationSpouse = "个人征信业务授权书-配偶"
    case informationQueryAuthorizationSpouse = "信息查询授权书-配偶"
    case riskWarningSpouse = "风险提示-配偶"
    case creditReportCustomer = "征信报告-客户"
    case creditReportSpouse = "征信报告-配偶"
    case onSiteSurveyPhoto = "上门调查照片"
    case externalBusinessInfoQueryImage = "外部工商信息查询图片"
    case dishonestExecutorQueryImage = "失信被执行人查询图片"
    case businessIncomeCertification = "经营收入认定表"
    case incomeOverviewScreenshot = "收入流水总览截图"
    case transactionPdf = "流水PDF文件"
    
    var displayName: String {
        return self.rawValue
    }
    
    var requiresFixedTemplate: Bool {
        switch self {
        case .loanCover, .identityInvestigation, .businessIncomeCertification:
            return true
        default:
            return false
        }
    }
}

struct Document: Identifiable, Codable {
    let id: UUID
    let type: DocumentType
    var fileName: String
    var fileData: Data?
    var fileSize: Int
    var importDate: Date
    var isFront: Bool // For ID cards
    
    init(type: DocumentType, fileName: String, fileData: Data? = nil, isFront: Bool = true) {
        self.id = UUID()
        self.type = type
        self.fileName = fileName
        self.fileData = fileData
        self.fileSize = fileData?.count ?? 0
        self.importDate = Date()
        self.isFront = isFront
    }
}

struct DocumentInfo {
    let type: DocumentType
    let fileName: String
    let fileURL: URL?
    let isImage: Bool
    let isPDF: Bool
    let isExcel: Bool
    let isWord: Bool
}
