#!/usr/bin/env python3
import os
import json
from pathlib import Path
from typing import List, Dict, Optional
from google.cloud import texttospeech
from dotenv import load_dotenv

load_dotenv()

class GoogleTTSGenerator:
    def __init__(self):
        # 環境変数から認証情報を設定
        credentials_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
        if credentials_path:
            os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
        
        self.client = texttospeech.TextToSpeechClient()
        
        # デフォルトの音声設定
        self.voice = texttospeech.VoiceSelectionParams(
            language_code="ja-JP",
            name="ja-JP-Neural2-B",
            ssml_gender=texttospeech.SsmlVoiceGender.MALE
        )
        
        # オーディオ設定
        self.audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )
    
    def generate_speech(self, ssml: str, output_path: str, voice_params: Optional[Dict] = None):
        """
        SSMLから音声ファイルを生成
        
        Args:
            ssml: SSML形式のテキスト
            output_path: 出力ファイルパス
            voice_params: 音声パラメータ（オプション）
        """
        # 音声パラメータをカスタマイズ
        if voice_params:
            voice = texttospeech.VoiceSelectionParams(
                language_code=voice_params.get('language_code', 'ja-JP'),
                name=voice_params.get('name', 'ja-JP-Neural2-B'),
                ssml_gender=getattr(
                    texttospeech.SsmlVoiceGender, 
                    voice_params.get('gender', 'MALE').upper()
                )
            )
        else:
            voice = self.voice
        
        # SSML入力を作成
        input_text = texttospeech.SynthesisInput(ssml=ssml)
        
        # 音声合成リクエスト
        response = self.client.synthesize_speech(
            input=input_text,
            voice=voice,
            audio_config=self.audio_config
        )
        
        # 音声ファイルを保存
        with open(output_path, 'wb') as out:
            out.write(response.audio_content)
        
        print(f"音声ファイルを生成しました: {output_path}")
    
    def process_ssml_list(self, ssml_list: List[Dict[str, str]], output_dir: str = "output"):
        """
        SSMLのリストから複数の音声ファイルを生成
        
        Args:
            ssml_list: SSMLと設定のリスト
            output_dir: 出力ディレクトリ
        """
        # 出力ディレクトリを作成
        Path(output_dir).mkdir(exist_ok=True)
        
        for i, item in enumerate(ssml_list):
            ssml = item.get('ssml', '')
            name = item.get('name', f'audio_{i:03d}')
            voice_params = item.get('voice', None)
            
            output_path = os.path.join(output_dir, f"{name}.mp3")
            
            try:
                self.generate_speech(ssml, output_path, voice_params)
            except Exception as e:
                print(f"エラー ({name}): {e}")


def main():
    # サンプルSSMLリスト
    ssml_samples = [
        {
            "name": "greeting",
            "ssml": """
            <speak>
                こんにちは！
                <break time="500ms"/>
                Google Cloud Text-to-Speech APIを使用しています。
            </speak>
            """
        },
        {
            "name": "hakata_swift",
            "ssml": """
            <speak>
                今日は<prosody rate="slow">HAKATA</prosody>
                <break time="200ms"/>
                <say-as interpret-as="spell-out">.</say-as>
                <break time="200ms"/>
                <prosody rate="slow">swift</prosody>に参加しています。
            </speak>
            """
        },
        {
            "name": "english_sample",
            "ssml": """
            <speak>
                <prosody rate="medium" pitch="+2st">
                    Welcome to Google Cloud Text-to-Speech!
                </prosody>
            </speak>
            """,
            "voice": {
                "language_code": "en-US",
                "name": "en-US-Neural2-C",
                "gender": "FEMALE"
            }
        },
        {
            "name": "numbers",
            "ssml": """
            <speak>
                電話番号は<say-as interpret-as="telephone">03-1234-5678</say-as>です。
                金額は<say-as interpret-as="currency">¥1,000</say-as>です。
                今日は<say-as interpret-as="date" format="ymd">2025/01/19</say-as>です。
            </speak>
            """
        }
    ]
    
    # JSONファイルからSSMLリストを読み込む場合
    json_file = "ssml_list.json"
    if os.path.exists(json_file):
        with open(json_file, 'r', encoding='utf-8') as f:
            ssml_samples = json.load(f)
    
    # TTSジェネレーターを初期化
    tts = GoogleTTSGenerator()
    
    # SSMLリストを処理
    tts.process_ssml_list(ssml_samples)


if __name__ == "__main__":
    main()