#!/usr/bin/env bash

# Credit to https://github.com/mathiasbynens/dotfiles for macOS customization

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# Color key
#

red=$'\e[1;31m'
green=$'\e[1;32m'
yellow=$'\e[1;33m'
blue=$'\e[1;34m'
magenta=$'\e[1;35m'
cyan=$'\e[1;36m'
end=$'\e[0m'

#
# Prep
#

bin_dir="/usr/local/bin"
work_dir="$HOME/work/"
ruby_version="2.5.1"

printf "%s\n======================================================================\n%s" $yellow $end
printf "%s# Loading ocordova/config\n%s" $yellow $end
printf "%s======================================================================\n%s" $yellow $end

#
# Copying dotfiles
#

printf "%s\n# Copying dotfiles...\n%s" $yellow $end

dotfiles=( zshrc gitconfig )
for file in "${dotfiles[@]}"
do
  printf "%s  - .$file%s"
  if [[ ! -e "$HOME/.$file" ]]; then
    {
      curl https://raw.githubusercontent.com/ocordova/config/master/.$file > $HOME/.$file
    } &> /dev/null
    printf "%s - Success!\n%s" $green $end
  else
    printf "%s - Already present\n%s" $cyan $end
  fi
done

#
# Creating directories
#

printf "%s\n# Creating directories...\n%s" $yellow $end

printf "%s  - Creating $work_dir...%s"
if [[ ! -e "$work_dir" ]]; then
  mkdir $work_dir
  printf "%s - Success!\n%s" $green $end
else
  printf "%s - Already created\n%s" $cyan $end
fi

printf "%s  - Creating $github_dir...%s"
if [[ ! -e "$github_dir" ]]; then
  mkdir $github_dir
  printf "%s - Success!\n%s" $green $end
else
  printf "%s - Already created\n%s" $cyan $end
fi


#
# macOS preferences
#

printf "%s\n# Adjusting macOS...\n%s" $yellow $end
{
  # Dock
  #
  # System Preferences > Dock > Automatically hide and show the Dock:
  defaults write com.apple.dock autohide -bool true
  # System Preferences > Dock > Size:
  defaults write com.apple.dock tilesize -int 64
  # System Preferences > Mission Control > Automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false
  # Clear out the dock of default icons
  defaults delete com.apple.dock persistent-apps
  defaults delete com.apple.dock persistent-others
  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Finder
  #
  # Hide desktop icons
  defaults write com.apple.finder CreateDesktop false
  # View as columns
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true
  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true
  # Set sidebar icon size to small
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # Prevent .DS_Store files
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  # Set Desktop as the default location for new Finder windows
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfDe"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

  # Save & Print
  #
  # Expand save and print modals by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
  # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
  #rm -rf ~/Library/Application Support/Dock/desktoppicture.db
  #sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
  #sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

  # System Preferences
  #
  # Disable LCD font smoothing (default 4)
  defaults -currentHost write -globalDomain AppleFontSmoothing -int 0
  # Hot corner: Bottom right, put display to sleep
  defaults write com.apple.dock wvous-br-corner -int 10
  defaults write com.apple.dock wvous-br-modifier -int 0
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  # Enable tap to click for trackpad
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  # Disable keyboard autocorrect
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true
  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true
  # Show battery percentage in menu bar
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"


  # Terminal
  #
  # Disable the annoying line marks
  defaults write com.apple.Terminal ShowLineMarks -int 0

  # Restart Finder and Dock (though many changes need a restart/relog)
  killall Finder
  killall Dock

} &> /dev/null
printf "%sDone!\n%s" $green $end

#
# Additional dependencies
#

printf "%s\n# Installing additional dependencies...\n%s" $yellow $end

printf "%s\n  Homebrew:\n%s" $yellow $end

if [[ ! -e "/usr/local/bin/brew" ]]; then
  {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  } &> /dev/null
  printf "%s - Done!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# rbenv
printf "%s  - Install rbenv%s"
if [[ ! -e "$HOME/.rbenv" ]]; then
  {
    brew install rbenv
  } &> /dev/null
  printf "%s - Done!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# wget (for downloading files from Terminal)
printf "%s  - Install wget%s"
if [[ ! -e "$bin_dir/wget" ]]; then
  {
    brew install wget --with-libressl
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# install a version of ruby
printf "%s  - Install Ruby v$ruby_version%s"
if [[ ! -e "$HOME/.rbenv/versions/$ruby_version/" ]]; then
  {
    rbenv install $ruby_version
  } &> /dev/null
  printf "%s - Done!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# set a global version
printf "%s  - Set global Ruby version%s"
if [[ ! -e "$HOME/.rbenv/version" ]]; then
  {
    rbenv install $ruby_version
  } &> /dev/null
  printf "%s - Done!\n%s" $green $end
else
  printf "%s - Already set\n%s" $cyan $end
fi

# node
printf "%s  - node%s"
if [[ ! -e "$bin_dir/node" ]]; then
  {
    brew install node
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# ruby gems
printf "%s\n  Gems:\n%s" $yellow $end
gems=( bundler sass jekyll )
for gem in "${gems[@]}"
do
  printf "%s  - $gem%s"
  if [[ ! -e "$HOME/.rbenv/versions/$ruby_version/bin/$gem" ]]; then
    {
      gem install $gem
    } &> /dev/null
    printf "%s - Installed!\n%s" $green $end
  else
    printf "%s - Already installed\n%s" $cyan $end
  fi
done

# Insomnia
printf "%s  - insomnia%s"
if [[ ! -e "$bin_dir/insomnia" ]]; then
  {
    brew install insomnia
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi

# VS Code
printf "%s  - vs code%s"
if [[ ! -e "$bin_dir/visual-studio-code" ]]; then
  {
    brew install visual-studio-code
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi


# Hyper
printf "%s  - hyper%s"
if [[ ! -e "$bin_dir/hyper" ]]; then
  {
    brew install hyper
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi


# Stoplight Studio
printf "%s  - stoplight-studio%s"
if [[ ! -e "$bin_dir/stoplight-studio" ]]; then
  {
    brew install stoplight-studio
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi


# Mini conda
printf "%s  - miniconda%s"
if [[ ! -e "$bin_dir/miniconda" ]]; then
  {
    brew install miniconda
  } &> /dev/null
  printf "%s - Installed!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi


#
# All done!
#

printf "%s\nWoohoo, all done!\n%s" $green $end