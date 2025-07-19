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
        <break time="1s"/>
        <prosody rate="slow">ゆっくり話します。</prosody>
    </speak>
    """
    @State private var validationResult: SSMLValidationResult?
    @State private var isValidating = false
    
    private let validator = SSMLValidator()
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("SSML Validator Sample")
                    .font(.largeTitle)
                    .padding()
                
                // SSML入力エリア
                VStack(alignment: .leading) {
                    Text("SSML Input:")
                        .font(.headline)
                    
                    TextEditor(text: .constant(ssmlText))
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 200)
                        .border(Color.gray, width: 1)
                        .disabled(true)
                }
                .padding()
                
                // 検証＆読み上げボタン
                HStack {
                    Button("Validate & Speak") {
                        validateAndSpeak()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isValidating)
                    
                    Button("Speak Only") {
                        speakOnly()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isValidating)
                }
                
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
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // サンプルSSMLボタン
                VStack(spacing: 15) {
                    Text("HAKATA.swift Demo 🎉:")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        VStack(spacing: 10) {
                            Button("あいさつ１: 通常の読み上げ") {
                                // Create an utterance.
                                let utterance = AVSpeechUtterance(string: "こんにちは！今日はHAKATA.swiftに参加しています。")

                                // Configure the utterance.
                                utterance.rate = 0.57
                                utterance.pitchMultiplier = 0.8
                                utterance.postUtteranceDelay = 0.2
                                utterance.volume = 0.8

                                // Japanese voice
                                let voice = AVSpeechSynthesisVoice(language: "ja-JP")

                                // Assign the voice to the utterance.
                                utterance.voice = voice

                                synthesizer.speak(utterance)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        }

                        Button("あいさつ２　HAKATA.swift") {
                            ssmlText = """
                            <speak>
                                こんにちは！
                                今日はHAKATA.swiftに参加しています。
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("あいさつ3: SSML でHAKATA.(ドット)swift") {
                            ssmlText = """
                            <speak>
                                <prosody volume="loud">こんにちは！</prosody>
                                今日は<prosody rate="slow">HAKATA</prosody>
                                <break time="200ms"/>
                                ドット
                                <break time="200ms"/>
                                <prosody rate="slow">swift</prosody>に参加しています。
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("不明なタグ") {
                            ssmlText = """
                            <speak>
                                <aaaaa>
                                    <bbbb>不明なタグがあった場合に話すことはできます</bbbb>
                                </aaaaa>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("英語と日本語") {
                            ssmlText = """
                            <speak>
                                今日は<lang xml:lang="en-US">AVSpeechUtterance</lang>について話します。
                                <break time="500ms"/>
                                <lang xml:lang="en-US">This is AVSpeechUtterance class.</lang>
                                <break time="300ms"/>
                                音声合成のためのクラスです。
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)


                        Button("emphasis") {
                            ssmlText = """
                            <speak>
                                <emphasis level='strong'>emphasisはどうなる？</emphasis>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    

                    
                    Text("Basic SSML Examples:")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Button("AVFoundation Example") {
                            ssmlText = """
                            <speak>
                                The quick brown fox jumped over the lazy dog.
                                <break time="200ms"/>
                                <prosody rate="0.57" pitch="0.8">
                                    This text is spoken with adjusted rate and pitch.
                                </prosody>
                                <break time="200ms"/>
                                <prosody volume="0.8">
                                    And this has adjusted volume.
                                </prosody>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Break Examples") {
                            ssmlText = """
                            <speak>
                                Take a breath <break time="200ms"/> here.
                                Longer pause <break time="3s"/> three seconds.
                                <break strength="weak"/> weak break.
                                <break strength="medium"/> medium break.
                                <break strength="strong"/> strong break.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Prosody Examples") {
                            ssmlText = """
                            <speak>
                                <prosody rate="x-slow">extra slow speech</prosody>
                                <prosody rate="slow">slow speech</prosody>
                                <prosody rate="medium">medium speech</prosody>
                                <prosody rate="fast">fast speech</prosody>
                                <prosody rate="x-fast">extra fast speech</prosody>
                                <prosody pitch="x-low">very low pitch</prosody>
                                <prosody pitch="low">low pitch</prosody>
                                <prosody pitch="medium">medium pitch</prosody>
                                <prosody pitch="high">high pitch</prosody>
                                <prosody pitch="x-high">very high pitch</prosody>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("W3C SSML 1.1 Examples:")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Button("Say-As Numbers") {
                            ssmlText = """
                            <speak>
                                The number is <say-as interpret-as="cardinal">12345</say-as>.
                                The ordinal is <say-as interpret-as="ordinal">1</say-as>.
                                Phone: <say-as interpret-as="telephone">+1-800-555-1234</say-as>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Say-As Date/Time") {
                            ssmlText = """
                            <speak>
                                The date is <say-as interpret-as="date" format="mdy">01/02/2023</say-as>.
                                The time is <say-as interpret-as="time" format="hms24">14:30:00</say-as>.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Say-As Currency") {
                            ssmlText = """
                            <speak>
                                That costs <say-as interpret-as="currency">$25.50</say-as>.
                                In Japan it's <say-as interpret-as="currency">¥1000</say-as>.
                                In Europe it's <say-as interpret-as="currency">€50</say-as>.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Button("Paragraph & Sentence") {
                            ssmlText = """
                            <speak>
                                <aaaaa>
                                    <bbbb>This is the first sentence of the paragraph.</bbbb>
                                    <bbbbb>Here's another sentence.</bbbbb>
                                </aaaaa>
                                <p>
                                    <s>This is a new paragraph.</s>
                                </p>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)

                        
                        Button("Sub (Alias)") {
                            ssmlText = """
                            <speak>
                                <sub alias="World Wide Web Consortium">W3C</sub> defines standards.
                                <sub alias="doctor">Dr.</sub> Smith will see you.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Advanced W3C Examples:")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Button("Phoneme") {
                            ssmlText = """
                            <speak>
                                You say <phoneme alphabet="ipa" ph="təˈmeɪtoʊ">tomato</phoneme>.
                                I say <phoneme alphabet="ipa" ph="təˈmɑːtoʊ">tomato</phoneme>.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Voice Selection") {
                            ssmlText = """
                            <speak>
                                <voice gender="female" age="10">Mary had a little lamb.</voice>
                                <voice name="Mike">I want to be like Mike.</voice>
                                <voice variant="2">This is variant number two.</voice>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Mark") {
                            ssmlText = """
                            <speak>
                                Go to the store <mark name="store"/> and buy some milk.
                                <mark name="here"/> Proceed to the checkout.
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Button("Emphasis Levels") {
                            ssmlText = """
                            <speak>
                                <emphasis level="strong">This is strong emphasis.</emphasis>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Say-As Spell Out") {
                            ssmlText = """
                            <speak>
                                <say-as interpret-as="spell-out">hello</say-as>
                                <say-as interpret-as="spell-out">ABC</say-as>
                                <say-as interpret-as="characters">12345</say-as>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Mixed Prosody") {
                            ssmlText = """
                            <speak>
                                <prosody rate="slow" pitch="low" volume="soft">
                                    This is spoken slowly, with low pitch and soft volume.
                                </prosody>
                                <prosody rate="200%" pitch="+5st" volume="+10dB">
                                    This is fast, higher pitched, and louder.
                                </prosody>
                            </speak>
                            """
                        }
                        .buttonStyle(.bordered)
                    }
                    


                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func validateAndSpeak() {
        isValidating = true
        
        // 検証前に読み上げ処理を実行
        performAlwaysExecutedProcess()
        
        // 検証
        validationResult = validator.validate(ssmlText)
        

        isValidating = false
    }
    
    private func speakOnly() {
        isValidating = true
        
        // 読み上げのみ実行（検証なし）
        performAlwaysExecutedProcess()
        
        isValidating = false
    }
    
    // 検証結果がOKの場合のみ実行する処理
    private func performValidSSMLProcess() {
        guard let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlText) else {
            return
        }
        // SSMLとして読み上げ成功
        synthesizer.speak(utterance)
    }
    
    // 検証結果に関わらず実行する処理（検証前に実行）
    private func performAlwaysExecutedProcess() {
        // 検証前に読み上げを実行
        guard let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlText) else {
            // SSMLとして解析できない場合は通常のテキストとして読み上げ
            let plainUtterance = AVSpeechUtterance(string: ssmlText)
            plainUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            synthesizer.speak(plainUtterance)
            return
        }
        synthesizer.speak(utterance)
    }
}

#Preview {
    ContentView()
}

