//
//  ContentView.swift
//  SampleSSML
//
//  Created by 遠藤拓弥 on 2025/07/15.
//

import SwiftUI
import SSMLSwift
import AVFoundation

struct ContentView: View {
    @State private var ssmlText = """
    <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis">
        <emphasis level="strong">重要な</emphasis>お知らせです。
        <break time="1s"/>
        <prosody rate="slow">ゆっくり話します。</prosody>
    </speak>
    """
    @State private var validationResult: SSMLValidationResult?
    @State private var isValidating = false
    
    private let validator = SSMLValidator()
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SSML Validator Sample")
                .font(.largeTitle)
                .padding()
            
            // SSML入力エリア
            VStack(alignment: .leading) {
                Text("SSML Input:")
                    .font(.headline)
                
                TextEditor(text: $ssmlText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .border(Color.gray, width: 1)
            }
            .padding()
            
            // 検証ボタン
            Button("Validate SSML") {
                validateSSML()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isValidating)
            
            // 結果表示
            if let result = validationResult {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Validation Result:")
                        .font(.headline)
                    
                    HStack {
                        Text("Valid SSML:")
                        Text(result.isValidSSML ? "✅ Yes" : "❌ No")
                            .foregroundColor(result.isValidSSML ? .green : .red)
                    }
                    
                    if let error = result.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    }
                    
                    if !result.supportedTags.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Supported Tags:")
                            Text(result.supportedTags.sorted().joined(separator: ", "))
                                .foregroundColor(.green)
                        }
                    }
                    
                    if !result.unsupportedTags.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Unsupported Tags:")
                            Text(result.unsupportedTags.sorted().joined(separator: ", "))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // 音声合成ボタン（有効なSSMLの場合のみ）
                    if result.isValidSSML {
                        Button("Speak with Apple TTS") {
                            speakSSML()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // サンプルSSMLボタン
            VStack {
                Text("Sample SSML:")
                    .font(.headline)
                
                HStack {
                    Button("Valid (All Supported)") {
                        ssmlText = """
                        <speak>
                            <break time="500ms"/>
                            <prosody rate="fast" pitch="high">速く高い声で</prosody>
                            <say-as interpret-as="telephone">090-1234-5678</say-as>
                        </speak>
                        """
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Valid (Mixed)") {
                        ssmlText = """
                        <speak>
                            <voice name="ja-JP">
                                <prosody rate="slow">ゆっくり</prosody>
                                <phoneme alphabet="ipa" ph="test">test</phoneme>
                            </voice>
                        </speak>
                        """
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Invalid") {
                        ssmlText = """
                            <emphasis level="strong">強調</emphasis>

                        """
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func validateSSML() {
        isValidating = true
        validationResult = validator.validate(ssmlText)
        isValidating = false
    }
    
    private func speakSSML() {
        // AVSpeechUtteranceのSSMLサポートを使用
        if let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlText) {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            synthesizer.speak(utterance)
        } else {
            // SSMLパースに失敗した場合はプレーンテキストとして読み上げ
            let plainText = ssmlText
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let utterance = AVSpeechUtterance(string: plainText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            synthesizer.speak(utterance)
        }
    }
}

#Preview {
    ContentView()
}
