#!/bin/bash

# Oh My Zsh installation script for Arch Linux
# Assumes zsh is already installed

echo "Installing Oh My Zsh..."

# Download and run the Oh My Zsh installer
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Configuring Starship with Catppuccin Powerline preset..."
starship preset catppuccin-powerline -o ~/.config/starship.toml
