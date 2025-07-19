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
        "prosody",
        "say-as"
    ]
    
    public init() {}
    
    /// SSMLテキストを検証
    /// - Parameter ssml: 検証するSSML文字列
    /// - Returns: 検証結果
    public func validate(_ ssml: String) -> SSMLValidationResult {
        let trimmedSSML = ssml.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        
        // speakタグの有無をチェック
        let hasSpeak = trimmedSSML.hasPrefix("<speak") && trimmedSSML.hasSuffix("</speak>")
        
        // emphasisタグの存在チェック
        let hasEmphasis = usedTags.contains("emphasis")
        
        // 有効性の判定：
        // 1. emphasisタグが含まれている場合は無効
        // 2. speakタグがある場合は有効（emphasisがない場合）
        // 3. speakタグがなくても、全てのタグがサポートされていれば有効
        let isValid = !hasEmphasis && (hasSpeak || unsupported.isEmpty)
        
        // エラーメッセージの生成
        var errorMessage: String? = nil
        if !isValid {
            if hasEmphasis {
                errorMessage = "Contains emphasis tag which has no effect in Apple TTS"
            } else if !hasSpeak && !unsupported.isEmpty {
                errorMessage = "Contains unsupported tags without <speak> wrapper: \(unsupported.sorted().joined(separator: ", "))"
            }
        }
        
        return SSMLValidationResult(
            isValidSSML: isValid,
            supportedTags: supported,
            unsupportedTags: unsupported,
            errorMessage: errorMessage
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