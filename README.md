# SSMLSwift

Apple TTS (Text-to-Speech) のSSML対応状況を検証するSwiftライブラリ

## 概要

SSMLSwiftは、文字列を受け取ってSSML形式の妥当性とApple TTSでサポートされているタグを一度にチェックするシンプルなライブラリです。

## 機能

- ✅ SSML形式の妥当性チェック
- ✅ Apple TTSでサポートされているタグの判定
- ✅ サポートされていないタグの検出
- ✅ 詳細なエラーメッセージ

## インストール

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SSMLSwift.git", from: "1.0.0")
]
```

## 使い方

```swift
import SSMLSwift

let validator = SSMLValidator()

let ssml = """
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
    <emphasis level="strong">重要な</emphasis>お知らせです。
    <break time="1s"/>
    <prosody rate="slow">ゆっくり話します。</prosody>
</speak>
"""

let result = validator.validate(ssml)

if result.isValidSSML {
    print("✅ 有効なSSMLです")
    print("サポートされているタグ: \(result.supportedTags)")
    print("サポートされていないタグ: \(result.unsupportedTags)")
} else {
    print("❌ 無効なSSML: \(result.errorMessage ?? "不明なエラー")")
}
```

## Apple TTSでサポートされているSSMLタグ

| タグ | サポート状況 | 説明 |
|------|------------|------|
| `<speak>` | ✅ | ルート要素 |
| `<break>` | ✅ | 一時停止を挿入 |
| `<emphasis>` | ✅ | テキストを強調 |
| `<prosody>` | ✅ | 音声のピッチ、速度、音量を制御 |
| `<say-as>` | ✅ | テキストの読み方を指定 |

## サポートされていない主なSSMLタグ

- `<voice>` - 音声の変更
- `<phoneme>` - 発音記号の指定
- `<mark>` - マーカーの挿入
- `<sub>` - 代替テキスト
- `<p>`, `<s>` - 段落・文の境界

## API

### SSMLValidator

```swift
public class SSMLValidator {
    public init()
    public func validate(_ ssml: String) -> SSMLValidationResult
}
```

### SSMLValidationResult

```swift
public struct SSMLValidationResult {
    public let isValidSSML: Bool
    public let supportedTags: Set<String>
    public let unsupportedTags: Set<String>
    public let errorMessage: String?
}
```

## 要件

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 5.9+

## ライセンス

MIT License

## 貢献

Issues、Pull Requestsは歓迎です。

## 作者

[Your Name]