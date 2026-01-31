#!/data/data/com.termux/files/usr/bin/bash

# =============================================================================
# Viral Reel Generator - Termux Setup Script
# Run this in Termux to set up the entire project on your Android phone
# =============================================================================

set -e  # Exit on any error

echo "=========================================="
echo "  Viral Reel Generator - Termux Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# STEP 1: Update packages
# =============================================================================
echo -e "${YELLOW}[1/10] Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y
echo -e "${GREEN}✓ Packages updated${NC}"
echo ""

# =============================================================================
# STEP 2: Install system dependencies
# =============================================================================
echo -e "${YELLOW}[2/10] Installing system dependencies...${NC}"
pkg install -y \
    python \
    git \
    ffmpeg \
    clang \
    pkg-config \
    libffi \
    openssl \
    rust \
    wget \
    curl

echo -e "${GREEN}✓ System dependencies installed${NC}"
echo ""

# =============================================================================
# STEP 3: Setup storage access (optional but recommended)
# =============================================================================
echo -e "${YELLOW}[3/10] Setting up storage access...${NC}"
termux-setup-storage 2>/dev/null || true
echo -e "${GREEN}✓ Storage access configured${NC}"
echo ""

# =============================================================================
# STEP 4: Create project directory
# =============================================================================
echo -e "${YELLOW}[4/10] Creating project directory...${NC}"
PROJECT_DIR="$HOME/viral-reel-generator"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo -e "${GREEN}✓ Project directory: $PROJECT_DIR${NC}"
echo ""

# =============================================================================
# STEP 5: Create Python virtual environment
# =============================================================================
echo -e "${YELLOW}[5/10] Creating Python virtual environment...${NC}"
python -m venv venv
source venv/bin/activate
echo -e "${GREEN}✓ Virtual environment created${NC}"
echo ""

# =============================================================================
# STEP 6: Upgrade pip and install build tools
# =============================================================================
echo -e "${YELLOW}[6/10] Upgrading pip...${NC}"
pip install --upgrade pip setuptools wheel
echo -e "${GREEN}✓ Pip upgraded${NC}"
echo ""

# =============================================================================
# STEP 7: Create backend structure
# =============================================================================
echo -e "${YELLOW}[7/10] Creating backend structure...${NC}"
mkdir -p backend/{downloads,outputs,temp}

# Create requirements.txt
cat > backend/requirements.txt << 'REQEOF'
# Core Framework
fastapi==0.115.0
uvicorn[standard]==0.32.0
python-multipart==0.0.12

# YouTube Download
yt-dlp==2024.12.13

# Audio Processing
openai-whisper==20231117
librosa==0.10.2.post1
soundfile==0.12.1
numpy==1.26.4

# Video Processing
moviepy==1.0.3
opencv-python==4.10.0.84
mediapipe==0.10.18
ffmpeg-python==0.2.0

# AI/LLM
openai==1.57.0
google-generativeai==0.8.3

# Utilities
pydantic==2.10.3
pydantic-settings==2.6.1
python-dotenv==1.0.1
aiofiles==24.1.0
aiohttp==3.11.10
requests==2.32.3
REQEOF

echo -e "${GREEN}✓ Backend structure created${NC}"
echo ""

# =============================================================================
# STEP 8: Install Python packages (this takes time)
# =============================================================================
echo -e "${YELLOW}[8/10] Installing Python packages (this will take 15-30 minutes)...${NC}"
echo -e "${YELLOW}        Grab a coffee! ☕${NC}"
echo ""

cd backend

# Install packages one by one to avoid memory issues
install_package() {
    echo -e "${YELLOW}Installing: $1${NC}"
    pip install --no-cache-dir "$1" || {
        echo -e "${RED}Failed to install $1, retrying...${NC}"
        pip install "$1"
    }
}

# Core packages first
install_package "fastapi uvicorn python-multipart"
install_package "yt-dlp"

# Audio processing
install_package "numpy==1.26.4"
install_package "soundfile"
install_package "librosa"

# Whisper (special handling)
echo -e "${YELLOW}Installing Whisper...${NC}"
pip install --no-cache-dir openai-whisper || pip install openai-whisper

# Video processing
install_package "opencv-python"
install_package "moviepy"
install_package "mediapipe"
install_package "ffmpeg-python"

# AI packages
install_package "openai"
install_package "google-generativeai"

# Utilities
install_package "pydantic pydantic-settings"
install_package "python-dotenv aiofiles aiohttp requests"

echo -e "${GREEN}✓ Python packages installed${NC}"
echo ""

# =============================================================================
# STEP 9: Download Whisper model
# =============================================================================
echo -e "${YELLOW}[9/10] Downloading Whisper model (large-v3)...${NC}"
python3 << 'PYEOF'
import whisper
import sys

try:
    print("Downloading Whisper large-v3 model...")
    print("This is a ~3GB download and may take several minutes...")
    model = whisper.load_model("large-v3")
    print("✓ Whisper model downloaded successfully!")
except Exception as e:
    print(f"Warning: Could not download model: {e}")
    print("The model will be downloaded on first use.")
    sys.exit(0)
PYEOF

echo -e "${GREEN}✓ Whisper model ready${NC}"
echo ""

# =============================================================================
# STEP 10: Create configuration files
# =============================================================================
echo -e "${YELLOW}[10/10] Creating configuration files...${NC}"

# Create .env file
cat > .env << 'ENVEOF'
# API Keys - ADD YOUR KEYS HERE
OPENAI_API_KEY=sk-your-openai-api-key-here
GOOGLE_API_KEY=
ELEVENLABS_API_KEY=

# Paths
DOWNLOAD_PATH=./downloads
OUTPUT_PATH=./outputs
TEMP_PATH=./temp

# Model Configuration
WHISPER_MODEL=large-v3
LLM_MODEL=gpt-4o
LLM_TEMPERATURE=0.3

# Processing
MAX_CONCURRENT_DOWNLOADS=1
MAX_VIDEO_DURATION_MINUTES=30
DEFAULT_REEL_DURATION_SECONDS=60
ENVEOF

# Create a simple startup script
cat > ../start-server.sh << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
cd "$(dirname "$0")/backend"
source ../venv/bin/activate
echo "Starting Viral Reel Generator API..."
echo "API will be available at: http://localhost:8000"
echo "API docs at: http://localhost:8000/docs"
echo ""
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
STARTEOF

chmod +x ../start-server.sh

# Create a quick test script
cat > ../test-api.sh << 'TESTEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Testing API..."
curl -s http://localhost:8000/health | python3 -m json.tool
TESTEOF

chmod +x ../test-api.sh

echo -e "${GREEN}✓ Configuration files created${NC}"
echo ""

# =============================================================================
# DONE
# =============================================================================
echo "=========================================="
echo -e "${GREEN}  Setup Complete! 🎉${NC}"
echo "=========================================="
echo ""
echo "Project location: $PROJECT_DIR"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Add your OpenAI API key:"
echo "   nano $PROJECT_DIR/backend/.env"
echo ""
echo "2. Start the server:"
echo "   cd $PROJECT_DIR"
echo "   ./start-server.sh"
echo ""
echo "3. Test the API:"
echo "   ./test-api.sh"
echo ""
echo "4. Open in browser:"
echo "   http://localhost:8000/docs"
echo ""
echo "=========================================="
