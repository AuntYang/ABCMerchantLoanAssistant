import UIKit
import Vision
import VisionKit

class OCRManager {
    
    static let shared = OCRManager()
    
    private init() {}
    
    func recognizeIDCard(from image: UIImage, completion: @escaping (Result<IDCardInfo, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let idCardInfo = self.parseIDCardInfo(from: recognizedStrings)
            completion(.success(idCardInfo))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    func recognizeBusinessLicense(from image: UIImage, completion: @escaping (Result<BusinessLicenseInfo, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let licenseInfo = self.parseBusinessLicenseInfo(from: recognizedStrings)
            completion(.success(licenseInfo))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    private func parseIDCardInfo(from strings: [String]) -> IDCardInfo {
        var name = ""
        var gender = ""
        var idNumber = ""
        var address = ""
        var ethnicity = ""
        var birthDate = ""
        
        for (index, string) in strings.enumerated() {
            if string.contains("姓名") || string.contains("姓") {
                if index + 1 < strings.count {
                    name = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("性别") {
                if index + 1 < strings.count {
                    gender = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("民族") {
                if index + 1 < strings.count {
                    ethnicity = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("出生") {
                if index + 1 < strings.count {
                    birthDate = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("住址") {
                if index + 1 < strings.count {
                    address = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            // Try to find ID number
            let idPattern = "[1-9]\\d{5}(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}[\\dXx]"
            if let regex = try? NSRegularExpression(pattern: idPattern),
               let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) {
                idNumber = String(string[Range(match.range, in: string)!])
            }
        }
        
        return IDCardInfo(name: name, gender: gender, ethnicity: ethnicity, birthDate: birthDate, address: address, idNumber: idNumber)
    }
    
    private func parseBusinessLicenseInfo(from strings: [String]) -> BusinessLicenseInfo {
        var name = ""
        var type = ""
        var legalRepresentative = ""
        var address = ""
        
        for (index, string) in strings.enumerated() {
            if string.contains("名称") || string.contains("字号") {
                if index + 1 < strings.count {
                    name = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("类型") {
                if index + 1 < strings.count {
                    type = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("法定代表人") || string.contains("负责人") {
                if index + 1 < strings.count {
                    legalRepresentative = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            if string.contains("住所") || string.contains("经营场所") {
                if index + 1 < strings.count {
                    address = strings[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return BusinessLicenseInfo(name: name, type: type, legalRepresentative: legalRepresentative, address: address)
    }
}

struct IDCardInfo {
    let name: String
    let gender: String
    let ethnicity: String
    let birthDate: String
    let address: String
    let idNumber: String
}

struct BusinessLicenseInfo {
    let name: String
    let type: String
    let legalRepresentative: String
    let address: String
}

enum OCRError: Error {
    case invalidImage
    case noTextFound
    case parsingFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "无法识别图片"
        case .noTextFound:
            return "未找到文字"
        case .parsingFailed:
            return "解析失败"
        }
    }
}
