import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CustomerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerListView(viewModel: viewModel)
                .tabItem {
                    Label("客户列表", systemImage: "person.2")
                }
                .tag(0)
            
            DocumentManagementView(viewModel: viewModel)
                .tabItem {
                    Label("资料管理", systemImage: "doc.text")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

struct CustomerListView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @State private var showingAddCustomer = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.customers) { customer in
                    NavigationLink(destination: CustomerDetailView(customer: customer, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(customer.name)
                                .font(.headline)
                            Text("电话: \(customer.phone)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteCustomer)
            }
            .navigationTitle("商户贷客户")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCustomer = true }) {
                        Label("添加客户", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCustomer) {
                AddCustomerView(viewModel: viewModel)
            }
        }
    }
}

struct CustomerDetailView: View {
    let customer: Customer
    @ObservedObject var viewModel: CustomerViewModel
    @State private var showingDocumentPicker = false
    @State private var showingOCR = false
    @State private var selectedDocumentType: DocumentType = .businessLicense
    
    var body: some View {
        List {
            Section(header: Text("客户信息")) {
                HStack {
                    Text("姓名")
                    Spacer()
                    Text(customer.name)
                }
                HStack {
                    Text("电话")
                    Spacer()
                    Text(customer.phone)
                }
                HStack {
                    Text("配偶电话")
                    Spacer()
                    Text(customer.spousePhone)
                }
                HStack {
                    Text("地址")
                    Spacer()
                    Text(customer.address)
                }
            }
            
            Section(header: Text("证件信息")) {
                HStack {
                    Text("身份证号码")
                    Spacer()
                    Text(customer.idNumber)
                }
                HStack {
                    Text("配偶身份证")
                    Spacer()
                    Text(customer.spouseIdNumber)
                }
                HStack {
                    Text("营业执照类型")
                    Spacer()
                    Text(customer.businessLicenseType)
                }
            }
            
            Section(header: Text("资料上传")) {
                ForEach(DocumentType.allCases, id: \.self) { docType in
                    Button(action: {
                        selectedDocumentType = docType
                        showingDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: customer.hasDocument(type: docType) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(customer.hasDocument(type: docType) ? .green : .gray)
                            Text(docType.displayName)
                            Spacer()
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            
            Section(header: Text("操作")) {
                Button(action: {
                    showingOCR = true
                }) {
                    Label("OCR识别证件", systemImage: "camera")
                }
                
                Button(action: {
                    viewModel.generatePDF(for: customer)
                }) {
                    Label("生成资料清单", systemImage: "doc.plaintext")
                }
            }
        }
        .navigationTitle(customer.name)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView(documentType: selectedDocumentType, customer: customer, viewModel: viewModel)
        }
        .sheet(isPresented: $showingOCR) {
            OCRView(customer: customer, viewModel: viewModel)
        }
    }
}

struct AddCustomerView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var spousePhone = ""
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("客户基本信息")) {
                    TextField("客户姓名", text: $name)
                    TextField("客户电话", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("配偶电话", text: $spousePhone)
                        .keyboardType(.phonePad)
                    TextField("现住址", text: $address)
                }
            }
            .navigationTitle("新建客户")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let customer = Customer(
                            name: name,
                            phone: phone,
                            spousePhone: spousePhone,
                            address: address
                        )
                        viewModel.addCustomer(customer)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

struct DocumentManagementView: View {
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.customers) { customer in
                    Section(header: Text(customer.name)) {
                        ForEach(DocumentType.allCases, id: \.self) { docType in
                            if customer.hasDocument(type: docType) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(.blue)
                                    Text(docType.displayName)
                                    Spacer()
                                    Text("已上传")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("资料管理")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                    }
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("ABC Bank")
                    }
                }
                
                Section(header: Text("数据管理")) {
                    Button("导出所有数据") {
                        // Export functionality
                    }
                    Button("清除所有数据", role: .destructive) {
                        // Clear data functionality
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    ContentView()
}