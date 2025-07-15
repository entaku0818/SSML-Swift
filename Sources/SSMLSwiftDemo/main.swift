import Foundation
import SSMLSwift

let validator = SSMLValidator()

print("=== SSMLSwift Validation Demo ===\n")

// Test 1: Valid SSML with all supported tags
let validSSML = """
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
    <emphasis level="strong">重要な</emphasis>お知らせです。
    <break time="1s"/>
    <prosody rate="slow" pitch="high">ゆっくり高い声で話します。</prosody>
    <say-as interpret-as="telephone">090-1234-5678</say-as>
</speak>
"""

print("Test 1: Valid SSML with supported tags")
print("SSML:")
print(validSSML)
print("\nResult:")
let result1 = validator.validate(validSSML)
print("✅ Valid: \(result1.isValidSSML)")
print("📋 Supported tags: \(result1.supportedTags.sorted())")
print("⚠️  Unsupported tags: \(result1.unsupportedTags.sorted())")
print("❌ Error: \(result1.errorMessage ?? "None")")
print("\n" + String(repeating: "-", count: 50) + "\n")

// Test 2: Valid SSML with mixed tags
let mixedSSML = """
<speak>
    <voice name="ja-JP">
        <prosody rate="slow">ゆっくり</prosody>
        <phoneme alphabet="ipa" ph="test">test</phoneme>
    </voice>
</speak>
"""

print("Test 2: Valid SSML with mixed tags")
print("SSML:")
print(mixedSSML)
print("\nResult:")
let result2 = validator.validate(mixedSSML)
print("✅ Valid: \(result2.isValidSSML)")
print("📋 Supported tags: \(result2.supportedTags.sorted())")
print("⚠️  Unsupported tags: \(result2.unsupportedTags.sorted())")
print("❌ Error: \(result2.errorMessage ?? "None")")
print("\n" + String(repeating: "-", count: 50) + "\n")

// Test 3: Invalid SSML (missing speak tag)
let invalidSSML = """
<prosody rate="slow">
    speakタグがありません
</prosody>
"""

print("Test 3: Invalid SSML (missing speak tag)")
print("SSML:")
print(invalidSSML)
print("\nResult:")
let result3 = validator.validate(invalidSSML)
print("✅ Valid: \(result3.isValidSSML)")
print("❌ Error: \(result3.errorMessage ?? "None")")
print("\n" + String(repeating: "-", count: 50) + "\n")

// Test 4: Malformed XML
let malformedSSML = """
<speak>
    <emphasis>閉じタグがありません
</speak>
"""

print("Test 4: Malformed XML")
print("SSML:")
print(malformedSSML)
print("\nResult:")
let result4 = validator.validate(malformedSSML)
print("✅ Valid: \(result4.isValidSSML)")
print("❌ Error: \(result4.errorMessage ?? "None")")

print("\n=== Demo Complete ===")