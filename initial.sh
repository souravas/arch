#!/bin/bash
# ---
# Combined Arch Linux installation script.
# 1. Ensures yay (AUR helper) is installed.
# 2. Updates the system.
# 3. Installs specified Pacman and AUR packages.
# 4. Installs and configures Docker.
# 5. Configures Git.
# 6. Sets up SSH keys from a local folder.
# ---

# Stop script on any error
set -e

# --- Section 1: Install yay (AUR Helper) ---

echo "--- Checking for yay (AUR Helper) ---"
if command -v yay >/dev/null 2>&1; then
    echo "✅ yay is already installed. Skipping installation."
else
    echo "🚀 yay not found. Proceeding with installation..."
    
    # Install dependencies
    echo "🔧 Installing required packages (git, base-devel)..."
    sudo pacman -S --needed --noconfirm git base-devel

    # Clone yay-bin if not already cloned
    if [ ! -d "$HOME/yay-bin" ]; then
        echo "📦 Cloning yay-bin repository..."
        git clone https://aur.archlinux.org/yay-bin.git "$HOME/yay-bin"
    else
        echo "📁 yay-bin directory already exists. Using existing clone."
    fi

    # Build and install yay
    echo "🛠️ Building and installing yay..."
    cd "$HOME/yay-bin"
    makepkg -si --noconfirm

    echo "🎉 yay installation complete!"
fi

# --- Section 2: Package Definitions ---

# Packages from the Arch User Repository (AUR)
yay_packages=(
    localsend-bin
    ticktick
    brave-bin
    visual-studio-code-bin
)

# Packages from the official Arch repositories
pacman_packages=(
    mpv
    ghostty
    obsidian
    veracrypt
    qbittorrent
    vlc
    vlc-plugins-all
    calibre
    zellij
    zoxide
    7zip
    partitionmanager
    ntfs-3g
    exfatprogs
    power-profiles-daemon
    qalculate-qt
    unrar
    unzip
    bat
    yt-dlp
    eza
    fastfetch
    fd
    ffmpeg
    fortune-mod
    lazydocker
    lazygit
    ripgrep
    stow
    tealdeer
    vim
    gufw
    gwenview
    docker
    docker-compose
    zsh
    cmatrix
    cowsay
    curl
    wget
    lolcat
    ttf-cascadia-code-nerd
    diff-so-fancy
    fzf
    piper
    krename
    jq
    less
    starship
)

# --- Section 3: System Update & Package Installation ---

echo "--- Syncing repositories and updating base system ---"
sudo pacman -Syu --noconfirm

echo "--- Installing Pacman (official repo) packages ---"
# We pass the entire array to -S.
# --needed skips any packages that are already installed and up-to-date.
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

echo "--- Installing AUR (yay) packages ---"
# Same logic for yay. It also respects the --needed flag.
# No sudo is needed for yay.
yay -S --noconfirm --needed "${yay_packages[@]}"

# --- Section 4: Docker Configuration ---
echo "--- Configuring Docker ---"

# Start and enable Docker service
echo "🐳 Starting and enabling Docker service..."
sudo systemctl start docker.service
sudo systemctl enable docker.service

# Add current user to docker group
echo "👤 Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER
echo "✅ Docker configuration complete. You'll need to log out and back in for group changes to take effect."

# --- Section 5: Git Configuration ---
echo "--- Configuring Git global settings ---"
# These commands run as the user executing the script.
# We run this *after* yay installs 'visual-studio-code-bin'
git config --global user.name "sourav"
git config --global user.email "souravas007@gmail.com"
git config --global core.editor "code -w"
echo "✅ Git configuration complete."

echo "--- Configuring Zsh as default shell ---"

# Change default shell to zsh
echo "🐚 Setting zsh as default shell for user '$USER'..."
chsh -s /usr/bin/zsh
echo "✅ Zsh set as default shell. Change will take effect after logout/login."

# --- Section 6: SSH Key Setup ---
echo "--- Setting up SSH keys ---"

# Define source and destination paths
# '$0' is the path to this script, 'dirname' gets its directory.
SCRIPT_DIR=$(dirname "$0")
SOURCE_SSH_DIR="$SCRIPT_DIR/ssh"
DEST_SSH_DIR="$HOME/.ssh"

# Check if the source 'ssh' directory exists
if [ -d "$SOURCE_SSH_DIR" ]; then
    echo "📁 'ssh' directory found at $SOURCE_SSH_DIR. Restoring keys..."

    # 1. Create the .ssh directory in home (if it doesn't exist)
    mkdir -p "$DEST_SSH_DIR"

    # 2. Copy the files
    echo "    -> Copying id_rsa, id_rsa.pub, and known_hosts..."
    cp "$SOURCE_SSH_DIR/id_rsa" "$DEST_SSH_DIR/"
    cp "$SOURCE_SSH_DIR/id_rsa.pub" "$DEST_SSH_DIR/"
    
    # Only copy known_hosts if it exists in the source
    if [ -f "$SOURCE_SSH_DIR/known_hosts" ]; then
        cp "$SOURCE_SSH_DIR/known_hosts" "$DEST_SSH_DIR/"
    fi

    # 3. Set strict permissions (CRITICAL for SSH to work)
    echo "🔐 Setting SSH file permissions..."
    chmod 700 "$DEST_SSH_DIR"
    chmod 600 "$DEST_SSH_DIR/id_rsa"
    chmod 644 "$DEST_SSH_DIR/id_rsa.pub"
    
    if [ -f "$DEST_SSH_DIR/known_hosts" ]; then
        chmod 644 "$DEST_SSH_DIR/known_hosts"
    fi

    echo "✅ SSH keys restored to $DEST_SSH_DIR."

else
    echo "⚠️  No 'ssh' directory found at $SOURCE_SSH_DIR. Skipping SSH setup."
    echo "    (If you intended to restore keys, create that directory and place your keys inside.)"
fi
