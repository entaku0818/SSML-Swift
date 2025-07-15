import Foundation
import AVFoundation

/// SSML検証結果
public struct SSMLValidationResult {
    /// SSML形式として有効か
    public let isValidSSML: Bool
    
    /// 使用されているタグのうちサポートされているもの
    public let supportedTags: Set<String>
    
    /// 使用されているタグのうちサポートされていないもの
    public let unsupportedTags: Set<String>
    
    /// エラーメッセージ（ある場合）
    public let errorMessage: String?
}

/// SSMLバリデーター
public class SSMLValidator {
    
    /// Apple TTSでサポートされているSSMLタグ
    private let supportedTags: Set<String> = [
        "speak",
        "break",
        "emphasis",
        "prosody",
        "say-as"
    ]
    
    public init() {}
    
    /// SSMLテキストを検証
    /// - Parameter ssml: 検証するSSML文字列
    /// - Returns: 検証結果
    public func validate(_ ssml: String) -> SSMLValidationResult {
        // SSML形式の基本チェック
        guard ssml.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<speak") else {
            return SSMLValidationResult(
                isValidSSML: false,
                supportedTags: [],
                unsupportedTags: [],
                errorMessage: "SSML must start with <speak> tag"
            )
        }
        
        guard ssml.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("</speak>") else {
            return SSMLValidationResult(
                isValidSSML: false,
                supportedTags: [],
                unsupportedTags: [],
                errorMessage: "SSML must end with </speak> tag"
            )
        }
        
        // XMLパーサーで検証
        let parser = XMLParser(data: Data(ssml.utf8))
        let delegate = SSMLParserDelegate()
        parser.delegate = delegate
        
        let parseSuccess = parser.parse()
        
        if !parseSuccess {
            return SSMLValidationResult(
                isValidSSML: false,
                supportedTags: [],
                unsupportedTags: [],
                errorMessage: parser.parserError?.localizedDescription ?? "Invalid XML format"
            )
        }
        
        // 使用されているタグを分類
        let usedTags = delegate.foundTags
        let supported = usedTags.intersection(supportedTags)
        let unsupported = usedTags.subtracting(supportedTags)
        
        return SSMLValidationResult(
            isValidSSML: true,
            supportedTags: supported,
            unsupportedTags: unsupported,
            errorMessage: nil
        )
    }
}

/// XMLパーサーのデリゲート
private class SSMLParserDelegate: NSObject, XMLParserDelegate {
    var foundTags = Set<String>()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        foundTags.insert(elementName)
    }
}