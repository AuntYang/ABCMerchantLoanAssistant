import SwiftUI
import AVFoundation

struct OCRView: View {
    let customer: Customer
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var ocrResult: IDCardInfo?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .padding()
                    
                    if isProcessing {
                        ProgressView("正在识别...")
                            .padding()
                    } else if let result = ocrResult {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("识别结果")
                                .font(.headline)
                            
                            HStack {
                                Text("姓名:")
                                Spacer()
                                Text(result.name)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("性别:")
                                Spacer()
                                Text(result.gender)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("身份证号:")
                                Spacer()
                                Text(result.idNumber)
                                    .foregroundColor(.blue)
                                    .font(.system(.body, design: .monospaced))
                            }
                            
                            HStack {
                                Text("地址:")
                                Spacer()
                                Text(result.address)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                    }
                } else {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("点击下方按钮拍摄证件")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: 300)
                }
                
                VStack(spacing: 15) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        Label("拍摄证件", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if ocrResult != nil {
                        Button(action: {
                            applyOCRResult()
                        }) {
                            Label("应用识别结果", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("OCR识别")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .onChange(of: capturedImage) { newValue in
                if let image = newValue {
                    performOCR(on: image)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func performOCR(on image: UIImage) {
        isProcessing = true
        OCRManager.shared.recognizeIDCard(from: image) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let info):
                    ocrResult = info
                case .failure(let error):
                    alertMessage = "识别失败: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func applyOCRResult() {
        guard let result = ocrResult else { return }
        
        // Update customer info would go here
        alertMessage = "识别结果已应用"
        showingAlert = true
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }
    }
}
