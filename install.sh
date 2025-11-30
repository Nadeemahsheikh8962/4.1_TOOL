#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║           NADEEM TOOL INSTALLER         ║"
echo "║           Auto-Installation Script      ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running in Termux
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}❌ Error: This script must be run in Termux${NC}"
    exit 1
fi

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
    fi
}

# Update packages
echo -e "${YELLOW}[1] Updating packages...${NC}"
pkg update -y
check_success

# Install dependencies
echo -e "${YELLOW}[2] Installing dependencies...${NC}"
pkg install -y python git wget unzip -o Dpkg::Options::="--force-confnew"
check_success

# Create NADEEM directory in Termux home
echo -e "${YELLOW}[3] Creating NADEEM directory...${NC}"
mkdir -p ~/NADEEM
cd ~/NADEEM
check_success

# Clean previous installations
echo -e "${YELLOW}[4] Cleaning previous installations...${NC}"
rm -f nadeem.zip
rm -rf 4.1_TOOL-main
check_success

# Download the tool
echo -e "${YELLOW}[5] Downloading NADEEM tool...${NC}"
wget -O nadeem.zip https://github.com/Nadeemahsheikh8962/4.1_TOOL/archive/refs/heads/main.zip

if [ ! -f "nadeem.zip" ]; then
    echo -e "${RED}❌ Error: Failed to download the tool${NC}"
    exit 1
fi
check_success

# Extract files
echo -e "${YELLOW}[6] Extracting files...${NC}"
unzip -o nadeem.zip
rm -f nadeem.zip
mv 4.1_TOOL-main/* .
rm -rf 4.1_TOOL-main
check_success

# Install Python modules (for any Python dependencies)
echo -e "${YELLOW}[7] Installing Python modules...${NC}"
pip install requests rich colorama tqdm pycryptodome zstandard gmalg 2>/dev/null || echo -e "${YELLOW}[!] Some modules skipped (optional)${NC}"

# Set up the binary executable
echo -e "${YELLOW}[8] Setting up executable...${NC}"
if [ -f "nadeem" ]; then
    # It's a compiled binary - make it executable
    chmod +x nadeem
    MAIN_FILE="nadeem"
    echo -e "${GREEN}✅ Binary executable detected${NC}"
else
    echo -e "${RED}❌ Error: Main executable not found${NC}"
    exit 1
fi

# Create alias for easy access
echo -e "${YELLOW}[9] Creating command alias...${NC}"
# Remove existing aliases
sed -i '/alias nadeem/d' ~/.bashrc 2>/dev/null
sed -i '/alias nadeem/d' ~/.zshrc 2>/dev/null

# Create new alias - run the binary directly
echo "alias nadeem='~/NADEEM/nadeem'" >> ~/.bashrc

if [ -f ~/.zshrc ]; then
    echo "alias nadeem='~/NADEEM/nadeem'" >> ~/.zshrc
fi

# Create launcher script in Termux bin directory
echo -e "${YELLOW}[10] Creating launcher...${NC}"
cat > $PREFIX/bin/nadeem << EOF
#!/bin/bash
cd ~/NADEEM
exec ./nadeem "\$@"
EOF

chmod +x $PREFIX/bin/nadeem
check_success

# Final setup
echo -e "${YELLOW}[11] Finalizing installation...${NC}"
source ~/.bashrc 2>/dev/null

# Display completion message
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║           INSTALLATION COMPLETE!        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}🎉 NADEEM Tool successfully installed!${NC}"
echo ""
echo -e "${CYAN}🚀 Quick Start:${NC}"
echo -e "${GREEN}   Type: ${CYAN}nadeem${GREEN} to start the tool${NC}"
echo ""
echo -e "${YELLOW}📁 Location:${NC}"
echo -e "   ${CYAN}~/NADEEM/${NC}"
echo ""
echo -e "${YELLOW}🔧 If 'nadeem' command doesn't work:${NC}"
echo -e "   ${CYAN}1. Restart Termux${NC}"
echo -e "   ${CYAN}2. Or run: ${GREEN}source ~/.bashrc${NC}"
echo -e "   ${CYAN}3. Or run manually: ${GREEN}cd ~/NADEEM && ./nadeem${NC}"
echo ""
echo -e "${GREEN}💡 The tool is now available anywhere in Termux!${NC}"
