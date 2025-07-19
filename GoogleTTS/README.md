# Google Text-to-Speech SSML Generator

SSMLリストからGoogle Cloud Text-to-Speech APIを使用して音声ファイルを生成するPythonスクリプト。

## セットアップ

### 1. Google Cloud プロジェクトの設定

1. [Google Cloud Console](https://console.cloud.google.com)でプロジェクトを作成
2. Text-to-Speech APIを有効化
3. サービスアカウントを作成し、認証用のJSONキーファイルをダウンロード

### 2. 環境設定

```bash
# 依存関係をインストール
pip install -r requirements.txt

# .envファイルを作成
cp .env.example .env

# .envファイルを編集して認証情報のパスを設定
# GOOGLE_APPLICATION_CREDENTIALS=path/to/your/credentials.json
```

### 3. 使用方法

#### 基本的な使用

```bash
# デフォルトのサンプルSSMLで実行
python ssml_to_speech.py
```

#### JSONファイルからSSMLリストを読み込む

`ssml_list.json`ファイルにSSMLのリストを定義して実行：

```json
[
    {
        "name": "sample1",
        "ssml": "<speak>こんにちは</speak>"
    },
    {
        "name": "sample2", 
        "ssml": "<speak>Hello</speak>",
        "voice": {
            "language_code": "en-US",
            "name": "en-US-Neural2-C",
            "gender": "FEMALE"
        }
    }
]
```

#### プログラムから使用

```python
from ssml_to_speech import GoogleTTSGenerator

# 初期化
tts = GoogleTTSGenerator()

# 単一のSSMLを音声化
tts.generate_speech(
    ssml="<speak>こんにちは</speak>",
    output_path="hello.mp3"
)

# SSMLリストを一括処理
ssml_list = [
    {"name": "test1", "ssml": "<speak>テスト1</speak>"},
    {"name": "test2", "ssml": "<speak>テスト2</speak>"}
]
tts.process_ssml_list(ssml_list, output_dir="output")
```

## 音声パラメータ

### 日本語音声
- `ja-JP-Neural2-A` (女性)
- `ja-JP-Neural2-B` (男性)
- `ja-JP-Neural2-C` (男性)
- `ja-JP-Neural2-D` (男性)

### 英語音声
- `en-US-Neural2-A` (男性)
- `en-US-Neural2-C` (女性)
- `en-US-Neural2-D` (男性)
- `en-US-Neural2-F` (女性)

## 環境変数

- `GOOGLE_APPLICATION_CREDENTIALS`: Google Cloud認証用JSONファイルのパス（必須）
- `GOOGLE_CLOUD_PROJECT`: Google CloudプロジェクトID（オプション）

## 出力

- デフォルトで`output/`ディレクトリにMP3ファイルが生成されます
- ファイル名は`{name}.mp3`の形式になります