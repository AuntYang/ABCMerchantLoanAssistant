import Foundation
import SwiftUI
import PDFKit

class CustomerViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    
    private let customersKey = "saved_customers"
    
    init() {
        loadCustomers()
    }
    
    func addCustomer(_ customer: Customer) {
        customers.append(customer)
        saveCustomers()
    }
    
    func deleteCustomer(at offsets: IndexSet) {
        customers.remove(atOffsets: offsets)
        saveCustomers()
    }
    
    func updateCustomer(_ customer: Customer) {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index] = customer
            saveCustomers()
        }
    }
    
    func addDocument(to customer: Customer, document: Document) {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index].documents.append(document)
            saveCustomers()
        }
    }
    
    func removeDocument(from customer: Customer, documentId: UUID) {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index].documents.removeAll { $0.id == documentId }
            saveCustomers()
        }
    }
    
    func extractIDCardInfo(from image: UIImage, isCustomer: Bool) -> (name: String, gender: String, idNumber: String, expiryDate: String)? {
        // OCR implementation placeholder
        // In a real app, this would use VisionKit or a third-party OCR library
        return nil
    }
    
    func extractBusinessLicenseInfo(from image: UIImage) -> (name: String, type: String, legalRepresentative: String, address: String)? {
        // OCR implementation placeholder
        return nil
    }
    
    func validateIDNumber(_ idNumber: String) -> Bool {
        // Chinese ID card validation
        let idRegex = "^[1-9]\\d{5}(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}[\\dXx]$"
        return idNumber.range(of: idRegex, options: .regularExpression) != nil
    }
    
    func validatePhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        return phone.range(of: phoneRegex, options: .regularExpression) != nil
    }
    
    func generatePDF(for customer: Customer) {
        let pdfMetaData = [
            kCGPDFContextCreator: "ABC商户贷助手",
            kCGPDFContextAuthor: "ABC Bank",
            kCGPDFContextTitle: "\(customer.name) - 资料清单"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw content
            let title = "商户贷款资料清单"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let customerName = "客户姓名: \(customer.name)"
            let customerPhone = "客户电话: \(customer.phone)"
            let date = "日期: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
            
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            title.draw(at: CGPoint(x: 200, y: 50), withAttributes: titleAttributes)
            customerName.draw(at: CGPoint(x: 50, y: 100), withAttributes: normalAttributes)
            customerPhone.draw(at: CGPoint(x: 50, y: 120), withAttributes: normalAttributes)
            date.draw(at: CGPoint(x: 50, y: 140), withAttributes: normalAttributes)
            
            // Draw document list
            var yPosition = 180
            for (index, docType) in DocumentType.allCases.enumerated() {
                let hasDocument = customer.hasDocument(type: docType)
                let status = hasDocument ? "?" : "○"
                let docText = "\(index + 1). \(docType.displayName) \(status)"
                docText.draw(at: CGPoint(x: 50, y: CGFloat(yPosition)), withAttributes: normalAttributes)
                yPosition += 25
            }
        }
        
        // Save PDF to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath = documentsPath.appendingPathComponent("\(customer.name)_资料清单.pdf")
        
        do {
            try data.write(to: pdfPath)
            // Share or open PDF
            print("PDF generated at: \(pdfPath)")
        } catch {
            print("Error generating PDF: \(error)")
        }
    }
    
    private func saveCustomers() {
        if let encoded = try? JSONEncoder().encode(customers) {
            UserDefaults.standard.set(encoded, forKey: customersKey)
        }
    }
    
    private func loadCustomers() {
        if let data = UserDefaults.standard.data(forKey: customersKey),
           let decoded = try? JSONDecoder().decode([Customer].self, from: data) {
            customers = decoded
        }
    }
}
