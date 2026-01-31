# Deployment Guide: Viral Reel Generator

Complete step-by-step instructions to deploy this project on Render (backend) and Vercel (frontend), plus local Termux setup.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Deploy Backend on Render](#deploy-backend-on-render)
3. [Deploy Frontend on Vercel](#deploy-frontend-on-vercel)
4. [Local Development with Termux (Android)](#local-development-with-termux-android)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- [GitHub](https://github.com) - For code repository
- [Render](https://render.com) - For backend hosting
- [Vercel](https://vercel.com) - For frontend hosting
- [OpenAI](https://platform.openai.com) - For Whisper & GPT-4o API

### API Keys Needed
1. **OpenAI API Key** - For Whisper transcription and GPT-4o analysis
2. **Google API Key** (optional) - For Gemini alternative
3. **ElevenLabs API Key** (optional) - For AI dubbing

---

## Deploy Backend on Render

### Step 1: Push Code to GitHub

```bash
# Initialize git repository
cd viral-reel-generator
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Viral Reel Generator"

# Create GitHub repository (via web or CLI)
# Then push
git remote add origin https://github.com/YOUR_USERNAME/viral-reel-generator.git
git branch -M main
git push -u origin main
```

### Step 2: Create Render Account

1. Go to [render.com](https://render.com)
2. Sign up with GitHub
3. Click "New +" → "Web Service"

### Step 3: Connect Repository

1. Select your GitHub repository `viral-reel-generator`
2. Click "Connect"
3. Configure the service:

| Setting | Value |
|---------|-------|
| Name | `viral-reel-api` |
| Environment | `Python 3` |
| Region | Choose closest to you |
| Branch | `main` |
| Root Directory | `backend` |
| Build Command | See below |
| Start Command | `uvicorn main:app --host 0.0.0.0 --port $PORT` |

**Build Command:**
```bash
apt-get update && apt-get install -y ffmpeg && pip install -r requirements.txt
```

### Step 4: Add Environment Variables

In Render dashboard, go to "Environment" tab and add:

```
OPENAI_API_KEY=sk-your-openai-key-here
GOOGLE_API_KEY=your-google-key-here (optional)
ELEVENLABS_API_KEY=your-elevenlabs-key-here (optional)
DOWNLOAD_PATH=/tmp/downloads
OUTPUT_PATH=/tmp/outputs
TEMP_PATH=/tmp/temp
WHISPER_MODEL=large-v3
LLM_MODEL=gpt-4o
```

### Step 5: Add Disk (For File Storage)

1. Go to "Disks" tab
2. Click "Add Disk"
3. Configure:
   - Name: `temp-storage`
   - Mount Path: `/tmp`
   - Size: 10 GB
   - Type: SSD

### Step 6: Deploy

1. Click "Create Web Service"
2. Wait for build to complete (5-10 minutes)
3. Your API URL will be: `https://viral-reel-api.onrender.com`

### Step 7: Test the API

```bash
curl https://viral-reel-api.onrender.com/health
```

Should return:
```json
{"status": "healthy", "version": "1.0.0"}
```

---

## Deploy Frontend on Vercel

### Step 1: Update API URL

Edit `frontend/src/components/VideoUrlInput.js`:

```javascript
// Change this line
const API_BASE_URL = 'https://viral-reel-api.onrender.com'; // Your Render URL
```

Also update in:
- `LanguageSelector.js`
- `ProcessingStatus.js`
- `ReelGallery.js`

### Step 2: Push Frontend Changes

```bash
git add .
git commit -m "Update API URL for production"
git push
```

### Step 3: Deploy to Vercel

#### Option A: Via Vercel Dashboard (Recommended)

1. Go to [vercel.com](https://vercel.com)
2. Sign up with GitHub
3. Click "Add New Project"
4. Import your GitHub repository
5. Configure:
   - Framework Preset: `Create React App`
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `build`
6. Add Environment Variable:
   - Name: `REACT_APP_API_URL`
   - Value: `https://viral-reel-api.onrender.com`
7. Click "Deploy"

#### Option B: Via Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Navigate to frontend
cd frontend

# Deploy
vercel

# Follow prompts:
# - Set up and deploy? Yes
# - Link to existing project? No
# - What's your project name? viral-reel-generator
# - In which directory is your code? ./
# - Build command? npm run build
# - Output directory? build
```

### Step 4: Configure CORS on Backend

Update `backend/main.py` to allow your Vercel domain:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-vercel-app.vercel.app",  # Your Vercel URL
        "http://localhost:3000",  # Local development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Push this change to GitHub and Render will auto-deploy.

### Step 5: Access Your App

Your app will be at:
- Frontend: `https://viral-reel-generator.vercel.app`
- Backend: `https://viral-reel-api.onrender.com`

---

## Local Development with Termux (Android)

### Step 1: Install Termux

1. Download Termux from F-Droid (not Play Store)
   - [F-Droid Termux](https://f-droid.org/packages/com.termux/)

2. Open Termux and update packages:
```bash
pkg update && pkg upgrade -y
```

### Step 2: Install Required Packages

```bash
# Install Python, Git, FFmpeg
pkg install python git ffmpeg -y

# Install build essentials
pkg install clang pkg-config libffi openssl -y

# Install Rust (for some Python packages)
pkg install rust -y
```

### Step 3: Clone Repository

```bash
# Navigate to storage (optional, for easier file access)
cd /sdcard/Download

# Or stay in home
cd ~

# Clone repository
git clone https://github.com/YOUR_USERNAME/viral-reel-generator.git
cd viral-reel-generator
```

### Step 4: Set Up Python Environment

```bash
# Create virtual environment
python -m venv venv

# Activate
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install dependencies (this will take 10-15 minutes)
pip install -r backend/requirements.txt
```

**Note:** If installation fails due to memory, try:
```bash
# Install packages one by one
pip install fastapi uvicorn
pip install yt-dlp
pip install openai-whisper
pip install librosa soundfile
pip install moviepy opencv-python
pip install mediapipe
pip install openai google-generativeai
```

### Step 5: Download Whisper Model

```bash
# Create Python script to download model
cat > download_model.py << 'EOF'
import whisper
print("Downloading Whisper large-v3 model...")
model = whisper.load_model("large-v3")
print("Model downloaded successfully!")
EOF

python download_model.py
```

### Step 6: Create Environment File

```bash
cd backend
cat > .env << 'EOF'
OPENAI_API_KEY=sk-your-openai-key-here
GOOGLE_API_KEY=
ELEVENLABS_API_KEY=
DOWNLOAD_PATH=./downloads
OUTPUT_PATH=./outputs
TEMP_PATH=./temp
WHISPER_MODEL=large-v3
LLM_MODEL=gpt-4o
EOF
```

### Step 7: Create Directories

```bash
mkdir -p downloads outputs temp
```

### Step 8: Start Backend Server

```bash
# In one Termux session
cd ~/viral-reel-generator/backend
source ../venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Step 9: Access from Phone Browser

1. Find your phone's IP:
```bash
ifconfig | grep "inet "
```

2. Open browser and go to:
```
http://YOUR_PHONE_IP:8000
```

Or use localhost:
```
http://localhost:8000/docs
```

### Step 10: Set Up Frontend (Optional on Termux)

Frontend is resource-intensive. Better to use the deployed Vercel version. But if you want local:

```bash
# In new Termux session
pkg install nodejs-lts

cd ~/viral-reel-generator/frontend

# Edit API URL to use local backend
# Edit src/components/VideoUrlInput.js
# Change API_BASE_URL to: http://localhost:8000

npm install
npm start
```

---

## Complete Termux Setup Script

Save this as `setup.sh` and run:

```bash
#!/data/data/com.termux/files/usr/bin/bash

echo "=== Viral Reel Generator - Termux Setup ==="

# Update packages
echo "[1/8] Updating packages..."
pkg update -y && pkg upgrade -y

# Install dependencies
echo "[2/8] Installing dependencies..."
pkg install -y python git ffmpeg clang pkg-config libffi openssl rust

# Clone repo
echo "[3/8] Cloning repository..."
cd ~
if [ ! -d "viral-reel-generator" ]; then
    git clone https://github.com/YOUR_USERNAME/viral-reel-generator.git
fi
cd viral-reel-generator

# Create virtual environment
echo "[4/8] Creating Python environment..."
python -m venv venv
source venv/bin/activate

# Install Python packages
echo "[5/8] Installing Python packages (this may take 15-20 minutes)..."
pip install --upgrade pip
pip install fastapi uvicorn python-multipart
pip install yt-dlp
pip install openai-whisper
pip install librosa soundfile numpy
pip install moviepy opencv-python mediapipe ffmpeg-python
pip install openai google-generativeai
pip install pydantic pydantic-settings python-dotenv aiofiles

# Create directories
echo "[6/8] Creating directories..."
mkdir -p backend/downloads backend/outputs backend/temp

# Download Whisper model
echo "[7/8] Downloading Whisper model..."
python -c "import whisper; whisper.load_model('large-v3')"

# Create .env file
echo "[8/8] Creating config..."
cd backend
cat > .env << 'EOF'
OPENAI_API_KEY=your-key-here
DOWNLOAD_PATH=./downloads
OUTPUT_PATH=./outputs
TEMP_PATH=./temp
WHISPER_MODEL=large-v3
LLM_MODEL=gpt-4o
EOF

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "To start the server:"
echo "  cd ~/viral-reel-generator/backend"
echo "  source ../venv/bin/activate"
echo "  uvicorn main:app --host 0.0.0.0 --port 8000"
echo ""
echo "Then open: http://localhost:8000/docs"
```

Run it:
```bash
chmod +x setup.sh
./setup.sh
```

---

## Quick Start Commands

### Start Backend (Termux)
```bash
cd ~/viral-reel-generator/backend
source ../venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Test API
```bash
curl http://localhost:8000/health
```

### View Logs
```bash
# In another Termux session
cd ~/viral-reel-generator/backend
tail -f logs.txt
```

---

## Troubleshooting

### Render Build Fails

**Problem:** FFmpeg not found
```
Solution: Use the build command with apt-get install ffmpeg
```

**Problem:** Out of memory during Whisper model load
```
Solution: Use smaller model (base instead of large-v3)
Change WHISPER_MODEL=base in environment variables
```

### Vercel Build Fails

**Problem:** Build exceeds 15 minutes
```
Solution: Check for large dependencies, optimize build
```

### Termux Issues

**Problem:** pip install fails with memory error
```bash
# Solution: Increase swap or install packages individually
pip install --no-cache-dir package-name
```

**Problem:** Whisper model download fails
```bash
# Solution: Download manually
python -c "import whisper; whisper.load_model('base')"
```

**Problem:** FFmpeg not working
```bash
# Reinstall FFmpeg
pkg reinstall ffmpeg
```

**Problem:** Port already in use
```bash
# Find and kill process
lsof -i :8000
kill -9 <PID>
```

### CORS Errors

Update `backend/main.py` with your exact Vercel URL:
```python
allow_origins=["https://your-app.vercel.app"]
```

---

## Cost Estimates

### Render (Backend)
- **Free Tier**: 512 MB RAM, 0.1 CPU (sufficient for testing)
- **Starter ($7/month)**: 512 MB RAM, 0.5 CPU (recommended)
- **Standard ($25/month)**: 2 GB RAM, 1 CPU (for production)

### Vercel (Frontend)
- **Hobby (Free)**: 100 GB bandwidth, 6000 build minutes
- **Pro ($20/month)**: 1 TB bandwidth

### OpenAI API
- Whisper: ~$0.006/minute of audio
- GPT-4o: ~$0.005/1K tokens
- Typical 10-minute video: ~$0.10-0.20

---

## Mobile Access

Once deployed:

1. **Open Vercel URL on phone**: `https://your-app.vercel.app`
2. **Use as PWA**:
   - Open in Chrome/Safari
   - Tap "Add to Home Screen"
   - Use like a native app

3. **Share with others**: Just share the Vercel URL

---

## Security Notes

1. **Never commit `.env` file** - It's in `.gitignore`
2. **Use Render/Vercel environment variables** for production
3. **Set up API key restrictions** in OpenAI dashboard
4. **Consider adding rate limiting** for production use

---

## Next Steps

1. Set up custom domain (optional)
2. Add authentication for paid users
3. Implement Redis for better job queue
4. Add webhook notifications
5. Set up monitoring (Sentry, etc.)

---

**Need help?** Check the logs on Render/Vercel dashboard or run with debug mode locally.
