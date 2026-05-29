import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: View {
    let documentType: DocumentType
    let customer: Customer
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingImagePicker = false
    @State private var showingFilePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedFileURL: URL?
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("选择 \(documentType.displayName) 的文件")
                    .font(.headline)
                    .padding()
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .rotationEffect(.degrees(rotationAngle))
                        .padding()
                    
                    HStack {
                        Button("旋转90°") {
                            rotationAngle += 90
                        }
                        .buttonStyle(.bordered)
                        
                        Button("重置旋转") {
                            rotationAngle = 0
                        }
                        .buttonStyle(.bordered)
                    }
                } else if let fileURL = selectedFileURL {
                    VStack {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text(fileURL.lastPathComponent)
                            .font(.body)
                            .padding()
                    }
                }
                
                VStack(spacing: 15) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Label("从相册选择", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        Label("从文件选择", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("导入文件")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveDocument()
                        dismiss()
                    }
                    .disabled(selectedImage == nil && selectedFileURL == nil)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.image, .pdf, .data],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedFileURL = url
                if url.startAccessingSecurityScopedResource() {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            }
        case .failure(let error):
            print("File import error: \(error)")
        }
    }
    
    private func saveDocument() {
        var documentData: Data?
        var fileName: String
        
        if let image = selectedImage {
            documentData = image.jpegData(compressionQuality: 0.8)
            fileName = "\(documentType.rawValue)_\(Date().timeIntervalSince1970).jpg"
        } else if let fileURL = selectedFileURL {
            fileName = fileURL.lastPathComponent
            documentData = try? Data(contentsOf: fileURL)
        } else {
            return
        }
        
        let document = Document(
            type: documentType,
            fileName: fileName,
            fileData: documentData,
            isFront: true
        )
        
        viewModel.addDocument(to: customer, document: document)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
}
