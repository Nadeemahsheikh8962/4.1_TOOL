#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║        NADEEM TOOL INSTALLER        ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# Check if running in Termux
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}Error: This script must be run in Termux${NC}"
    exit 1
fi

# Update packages
echo -e "${YELLOW}[*] Updating packages...${NC}"
pkg update -y

# Install dependencies
echo -e "${YELLOW}[*] Installing dependencies...${NC}"
pkg install -y python git wget unzip

# Create NADEEM directory
echo -e "${YELLOW}[*] Creating NADEEM directory...${NC}"
mkdir -p ~/storage/shared/NADEEM
cd ~/storage/shared/NADEEM

# Download and extract the tool
echo -e "${YELLOW}[*] Downloading NADEEM tool...${NC}"
wget -O nadeem.zip https://github.com/Nadeemahsheikh8962/4.1_TOOL/archive/refs/heads/main.zip

if [ ! -f "nadeem.zip" ]; then
    echo -e "${RED}Error: Failed to download the tool${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Extracting files...${NC}"
unzip -o nadeem.zip
rm nadeem.zip

# Move files to proper location
mv 4.1_TOOL-main/* .
rm -rf 4.1_TOOL-main

# Install Python requirements
echo -e "${YELLOW}[*] Installing Python modules...${NC}"

# Install required packages individually to handle potential issues
pip install requests rich colorama tqdm pycryptodome

# Try to install zstandard if available
pip install zstandard 2>/dev/null || echo -e "${YELLOW}[!] zstandard not available, skipping...${NC}"

# Try to install gmalg if available  
pip install gmalg 2>/dev/null || echo -e "${YELLOW}[!] gmalg not available, using fallback...${NC}"

# Detect the main file and make it executable
echo -e "${YELLOW}[*] Setting up main executable...${NC}"
MAIN_FILE=""
if [ -f "nadeem.py" ]; then
    MAIN_FILE="nadeem.py"
    chmod +x nadeem.py
elif [ -f "nadeem" ]; then
    MAIN_FILE="nadeem"
    chmod +x nadeem
else
    echo -e "${RED}Error: Could not find main executable file${NC}"
    echo -e "${YELLOW}[*] Available files:${NC}"
    ls -la
    exit 1
fi

echo -e "${GREEN}[+] Main file detected: $MAIN_FILE${NC}"

# Create alias for easy access
echo -e "${YELLOW}[*] Setting up command alias...${NC}"
if ! grep -q "alias nadeem" ~/.bashrc; then
    echo "alias nadeem='cd ~/storage/shared/NADEEM && python $MAIN_FILE'" >> ~/.bashrc
fi

if [ -f ~/.zshrc ]; then
    if ! grep -q "alias nadeem" ~/.zshrc; then
        echo "alias nadeem='cd ~/storage/shared/NADEEM && python $MAIN_FILE'" >> ~/.zshrc
    fi
fi

# Create a launcher script
cat > ~/../usr/bin/nadeem << EOF
#!/bin/bash
cd ~/storage/shared/NADEEM
python $MAIN_FILE "\$@"
EOF

chmod +x ~/../usr/bin/nadeem

# Reload bashrc
source ~/.bashrc

echo -e "${GREEN}"
echo "╔══════════════════════════════════════╗"
echo "║         INSTALLATION COMPLETE        ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}[+] Tool installed successfully!${NC}"
echo -e "${GREEN}[+] Main file: $MAIN_FILE${NC}"
echo -e "${GREEN}[+] You can now run the tool by typing:${NC}"
echo -e "${BLUE}    nadeem${NC}"
echo -e "${GREEN}[+] Or navigate to:${NC}"
echo -e "${BLUE}    cd ~/storage/shared/NADEEM && python $MAIN_FILE${NC}"
echo -e "${YELLOW}[*] If 'nadeem' command doesn't work, restart Termux or run:${NC}"
echo -e "${BLUE}    source ~/.bashrc${NC}"
