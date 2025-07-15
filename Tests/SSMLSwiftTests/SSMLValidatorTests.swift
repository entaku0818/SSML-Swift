import XCTest
@testable import SSMLSwift

final class SSMLValidatorTests: XCTestCase {
    
    var validator: SSMLValidator!
    
    override func setUp() {
        super.setUp()
        validator = SSMLValidator()
    }
    
    override func tearDown() {
        validator = nil
        super.tearDown()
    }
    
    // MARK: - Valid SSML Tests
    
    func testValidSSMLWithSupportedTags() {
        let ssml = """
        <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
            <emphasis level="strong">強調</emphasis>
            <break time="1s"/>
            <prosody rate="slow" pitch="high">ゆっくり高い声</prosody>
            <say-as interpret-as="telephone">090-1234-5678</say-as>
        </speak>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["speak", "emphasis", "break", "prosody", "say-as"])
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    func testValidSSMLWithMixedTags() {
        let ssml = """
        <speak>
            <voice name="ja-JP">
                <prosody rate="fast">速く話します</prosody>
                <phoneme alphabet="ipa" ph="test">test</phoneme>
            </voice>
        </speak>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["speak", "prosody"])
        XCTAssertEqual(result.unsupportedTags, ["voice", "phoneme"])
    }
    
    func testMinimalValidSSML() {
        let ssml = "<speak>Hello World</speak>"
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["speak"])
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    // MARK: - Invalid SSML Tests
    
    func testMissingSpeakStartTag() {
        // prosodyはサポートされているタグなので、speakタグがなくても有効
        let ssml = """
        <prosody rate="slow">テキスト</prosody>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["prosody"])
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    func testMissingSpeakEndTag() {
        // 不正なXML（閉じタグがない）
        let ssml = """
        <speak>
            <emphasis>テキスト</emphasis>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertFalse(result.isValidSSML)
        XCTAssertNotNil(result.errorMessage)
        XCTAssertTrue(result.errorMessage?.contains("NSXMLParserErrorDomain") ?? false)
    }
    
    func testMalformedXML() {
        let ssml = """
        <speak>
            <emphasis>閉じタグがない
        </speak>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertFalse(result.isValidSSML)
        XCTAssertNotNil(result.errorMessage)
        XCTAssertTrue(result.supportedTags.isEmpty)
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    func testEmptyString() {
        let ssml = ""
        
        let result = validator.validate(ssml)
        
        XCTAssertFalse(result.isValidSSML)
        XCTAssertNotNil(result.errorMessage)
    }
    
    func testWhitespaceOnly() {
        let ssml = "   \n\t   "
        
        let result = validator.validate(ssml)
        
        XCTAssertFalse(result.isValidSSML)
        XCTAssertNotNil(result.errorMessage)
    }
    
    // MARK: - Edge Cases
    
    func testSSMLWithWhitespace() {
        let ssml = """
        
        
        <speak>
            <break time="500ms"/>
        </speak>
        
        
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["speak", "break"])
    }
    
    func testNestedTags() {
        let ssml = """
        <speak>
            <prosody rate="slow">
                <emphasis level="strong">
                    <say-as interpret-as="date">2024-01-01</say-as>
                </emphasis>
            </prosody>
        </speak>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags, ["speak", "prosody", "emphasis", "say-as"])
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    func testSelfClosingTags() {
        let ssml = """
        <speak>
            テキスト<break time="1s"/>続きのテキスト
        </speak>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertTrue(result.supportedTags.contains("break"))
    }
    
    // MARK: - New Validation Logic Tests
    
    func testSupportedTagsWithoutSpeak() {
        // サポートされているタグのみを使用（speakタグなし）- 単一のルート要素
        let ssml = """
        <prosody rate="slow">
            <emphasis level="strong">重要</emphasis>
            <break time="500ms"/>
            ゆっくり
        </prosody>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertTrue(result.isValidSSML)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.supportedTags.sorted(), ["break", "emphasis", "prosody"])
        XCTAssertTrue(result.unsupportedTags.isEmpty)
    }
    
    func testUnsupportedTagsWithoutSpeak() {
        // サポートされていないタグを含む（speakタグなし）
        let ssml = """
        <voice name="ja-JP">
            <prosody rate="slow">ゆっくり</prosody>
        </voice>
        """
        
        let result = validator.validate(ssml)
        
        XCTAssertFalse(result.isValidSSML)
        XCTAssertEqual(result.errorMessage, "Contains unsupported tags without <speak> wrapper: voice")
        XCTAssertEqual(result.supportedTags, ["prosody"])
        XCTAssertEqual(result.unsupportedTags, ["voice"])
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceValidation() {
        let ssml = """
        <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
            <prosody rate="fast" pitch="high" volume="loud">
                これは長いテキストです。
                <emphasis level="strong">強調部分</emphasis>
                <break time="500ms"/>
                <say-as interpret-as="telephone">090-1234-5678</say-as>
            </prosody>
        </speak>
        """
        
        measure {
            for _ in 0..<1000 {
                _ = validator.validate(ssml)
            }
        }
    }
}