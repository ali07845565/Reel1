# AI-Powered Multi-Lingual Viral Reel Generator

An end-to-end automated pipeline that takes a single YouTube URL as input and generates high-potential viral reels (9:16) in multiple languages.

## Features

- **Smart Ingestion**: Extract video metadata and identify all available audio tracks (multi-lingual)
- **Viral Hook Detection**: AI-powered analysis using OpenAI Whisper + GPT-4o/Gemini to detect viral moments
- **Audio Energy Validation**: Librosa-based analysis for laughter, volume peaks, and music intensity
- **Smart Cropping**: MediaPipe face detection for 16:9 to 9:16 conversion with speaker centering
- **Dynamic Captions**: Alex Hormozi-style animated captions
- **Multi-Lingual Output**: Support for multiple language tracks

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   YouTube URL   │────▶│  Downloader      │────▶│  Whisper        │
│   Input         │     │  (yt-dlp)        │     │  Transcription  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                           │
                           ┌──────────────────┐           │
                           │  Video Processor │◀──────────┘
                           │  (Face Tracking, │
                           │   Captions)      │
                           └──────────────────┘
                                    │
                           ┌──────────────────┐
                           │  Viral Reels     │
                           │  Output (9:16)   │
                           └──────────────────┘
```

## Quick Start

### Prerequisites

- Python 3.10+
- Node.js 18+
- FFmpeg
- Redis (optional, for production)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd viral-reel-generator
```

2. **Set up Python environment**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your API keys
```

4. **Install Whisper model**
```python
import whisper
whisper.load_model("large-v3")
```

5. **Start the backend**
```bash
python main.py
# Or with uvicorn directly:
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

6. **Set up frontend**
```bash
cd ../frontend
npm install
npm start
```

7. **Open the app**
Navigate to `http://localhost:3000`

## API Endpoints

### Fetch Video Metadata
```http
POST /api/v1/videos/fetch-metadata
Content-Type: application/json

{
  "url": "https://www.youtube.com/watch?v=..."
}
```

Response:
```json
{
  "job_id": "abc123",
  "metadata": {
    "video_id": "...",
    "title": "Video Title",
    "duration": 3600,
    "available_languages": [
      {
        "language": "en",
        "language_name": "English",
        "format_id": "...",
        "is_original": true
      }
    ]
  }
}
```

### Start Processing
```http
POST /api/v1/videos/process
Content-Type: application/json

{
  "job_id": "abc123",
  "language_code": "en",
  "num_reels": 5,
  "reel_duration": 60
}
```

### Check Status
```http
GET /api/v1/videos/status/{job_id}
```

### Get Reels
```http
GET /api/v1/videos/reels/{job_id}
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for Whisper and GPT-4o | Required |
| `GOOGLE_API_KEY` | Google API key for Gemini (alternative) | Optional |
| `ELEVENLABS_API_KEY` | ElevenLabs API for AI dubbing | Optional |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379/0` |
| `DOWNLOAD_PATH` | Path for downloaded videos | `./downloads` |
| `OUTPUT_PATH` | Path for generated reels | `./outputs` |
| `WHISPER_MODEL` | Whisper model size | `large-v3` |
| `LLM_MODEL` | LLM model for analysis | `gpt-4o` |

## Project Structure

```
viral-reel-generator/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── config.py               # Configuration management
│   ├── models.py               # Pydantic models
│   ├── downloader.py           # YouTube downloader (yt-dlp)
│   ├── viral_detector.py       # Viral moment detection (Whisper + LLM)
│   ├── video_processor.py      # Video processing (FFmpeg, MediaPipe)
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── App.js
│   │   ├── components/
│   │   │   ├── VideoUrlInput.js
│   │   │   ├── LanguageSelector.js
│   │   │   ├── ProcessingStatus.js
│   │   │   └── ReelGallery.js
│   │   └── index.js
│   ├── package.json
│   └── public/
└── README.md
```

## Core Modules

### 1. Downloader (`downloader.py`)

Handles YouTube video downloading with multi-language audio support:
- Extract metadata with available audio tracks
- Download specific language audio streams
- Progress tracking
- Automatic retry with fallback

```python
from downloader import fetch_video_metadata, download_video_with_language

# Fetch metadata
metadata = await fetch_video_metadata("https://youtube.com/watch?v=...")

# Download with specific language
video_path, audio_path = await download_video_with_language(
    url, 
    language_code="es"
)
```

### 2. Viral Detector (`viral_detector.py`)

Detects viral moments using AI:
- Whisper transcription with timestamps
- LLM analysis for hooks, climaxes, insights
- Audio energy validation (Librosa)
- Combined scoring

```python
from viral_detector import detect_viral_moments

moments = await detect_viral_moments(
    audio_path,
    video_metadata,
    language="en",
    num_moments=10
)
```

### 3. Video Processor (`video_processor.py`)

Processes videos into vertical reels:
- Face tracking with MediaPipe
- 16:9 to 9:16 conversion
- Dynamic caption generation
- Audio muxing

```python
from video_processor import get_video_processor

processor = get_video_processor()
reel_path = await processor.process_reel(
    video_path,
    audio_path,
    viral_moment,
    transcript_segments
)
```

## Processing Pipeline

1. **Input**: User pastes YouTube URL
2. **Metadata Fetch**: Extract video info and available languages
3. **Language Selection**: User selects target language
4. **Download**: Download video and audio
5. **Transcription**: Whisper transcribes audio with timestamps
6. **AI Analysis**: LLM identifies viral moments
7. **Audio Validation**: Librosa validates with energy analysis
8. **Video Processing**: 
   - Convert to 9:16 with face tracking
   - Add animated captions
9. **Output**: Generated reels available for download

## Supported Languages

The system can detect and process videos with multiple audio tracks:
- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Russian (ru)
- Japanese (ja)
- Korean (ko)
- Chinese (zh)
- Hindi (hi)
- Arabic (ar)
- And more...

## Viral Moment Types

The AI identifies four types of viral moments:

1. **Hook**: Attention-grabbing openings, controversial statements, curiosity gaps
2. **Climax**: Peak emotional or intellectual moments, revelations, plot twists
3. **Insight**: Actionable advice, "aha" moments, valuable knowledge
4. **Emotional**: Laughter, surprise, inspiration, relatability

## Development

### Running Tests
```bash
cd backend
pytest
```

### Code Formatting
```bash
black backend/
isort backend/
```

## Production Deployment

### Docker
```dockerfile
# Dockerfile for backend
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Setup
- Use Redis for job queue
- Configure proper API key management
- Set up monitoring and logging
- Use CDN for video delivery

## Troubleshooting

### Whisper Model Download
If Whisper model download fails:
```bash
# Manual download
whisper --model large-v3 --language en dummy.wav
```

### FFmpeg Issues
Ensure FFmpeg is installed:
```bash
# macOS
brew install ffmpeg

# Ubuntu
sudo apt-get install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html
```

### CUDA/GPU Support
For GPU acceleration with Whisper:
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

## License

MIT License

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [MediaPipe](https://mediapipe.dev/)
- [MoviePy](https://zulko.github.io/moviepy/)
