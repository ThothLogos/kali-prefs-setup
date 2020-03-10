#!/bin/bash

#TODO:

#  - Set QTerminal options: font, colors, margin, transparency, history unlimited
#       /home/thoth/.config/qterminal.org/qterminal.ini
#  - Setup git credentials
#  - Screen timeout
#  - Move whisker panel to bottom
#  - Set R-Super to open whisker-menu
#  - (Optional) Install golang and setup path, gvm?
#  - (Optional) Install rust/cargo/etc
#  - Install VSCode, DeepDark

source config.sh

display_usage() {
  echo -e "
    Usage: $(basename) [OPTIONS]
  -h, --help                        This screen
  "
}

while [ "$#" -gt 0 ];do
  case "$1" in
    -h|--help) display_usage; exit 0;;
    -C|--code) code=true; shift 1;;
    -R|--rust) rust=true; shift 1;;
    -G|--golang) golang=true; shift 1;;
    -A|--all) golang=true; rust=true; code=true; shift 1;;
    *) err_echo "Unknown command: $1" >&2; exit 1;;
  esac
done

main() {
  setup_git
  setup_qterminal
  [[ $code ]] && setup_vscode
  [[ $rust ]] && setup_rust
  [[ $golang ]] && setup_golang
  setup_bashrc

  # since we're prob running this from qterm, we have to kill it
  # to prevent the current loaded prefs in the session being re-written
  local i=10
  echo "This terminal will self destruct in $i..."
  sleep 1.0
  while [[ $i -gt 1 ]];do
    i=$(($i-1))
    echo "... $i"
    sleep 1.0
  done
  #pkill qterminal
  # "As I rained blows upon him, I realized; there had to be another way!" - Frank Costanza
}

setup_bashrc() {
  echo "cd ~/Projects" >> ~/.bashrc
  [[ $rust_installed ]] && echo "export PATH=\"$HOME/.cargo/bin:$PATH\"" >> ~/.bashrc
  [[ $golang_installed ]] && echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
}

setup_rust() {
  local rustuploc=$(which rustup)
  if ! [[ $rustuploc == "" ]];then
    echo "rRust is already installed, skipping."
  else
    echo "[+] Installing latest stable Rust..."
    curl https://sh.rustup.rs -sSf | sh
    if [[ $? -eq 0 ]];then
      echo "Rust installation successful, running update."
      rustup update
      rust_installed=true
    else
      echo "Rust installation failed!"
      rust_installed=false
    fi
  fi
}

setup_golang() {
  local goloc=$(which go)
  if ! [[ $rustuploc == "" ]];then
    echo "[-] Golang is already installed, skipping."
  else
    echo "[+] Installing latest stable Golang..."
    local url=$(curl -s https://golang.org/dl/ 2>&1 |
                grep -Eoi '<a [^>]+>'     |
                grep -Eo 'href="[^\"]+"'  |
                grep -Eo 'https?://[^"]+' |
                grep -i "Linux" | sed -n 1p)
    echo "Retrieved URL: $url"
    wget -O ~/Downloads/install_golang.tar.gz $url
    if [[ $? -eq 0 ]];then
      sudo tar -C /usr/local -xzf ~/Downloads/install_golang.tar.gz
      if [[ $? -eq 0 ]];then golang_installed=true;fi
    else
      echo "Download with wget failed for $url, golang installation aborted"
      golang_installed=false
    fi
  fi
}

setup_git() {
    git config --system user.name > /dev/null
    if [[ $? -eq 0 ]];then
      local gcname=$(git config --system user.name)
      echo "git user.name already set to $gcname, no changes"
    else
      echo "Setting git config --system user.name to $GITUSER"
      sudo git config --system user.name $GITUSER
    fi
    git config --system user.email > /dev/null
    if [[ $? -eq 0 ]];then
      local gcmail=$(git config --system user.email)
      echo "git user.email already set to $gcmail, no changes"
    else
      echo "Setting git config --system user.email to $GITMAIL"
      sudo git config --system user.email $GITMAIL
    fi
}

setup_qterminal() {
  echo "Setting options in $QTCONFIG/qterminal.ini..."
  sed -i 's/Borderless.*/Borderless=true/' $QTCONFIG/qterminal.ini
  sed -i 's/HistoryLimited.*/HistoryLimited=false/' $QTCONFIG/qterminal.ini
  sed -i 's/MenuVisible.*/MenuVisible=false/' $QTCONFIG/qterminal.ini
  sed -i 's/ScrollbarPosition.*/ScrollbarPosition=0/' $QTCONFIG/qterminal.ini
  sed -i 's/TerminalMargin.*/TerminalMargin=0/' $QTCONFIG/qterminal.ini
  sed -i 's/TerminalTransparency.*/TerminalTransparency=0/' $QTCONFIG/qterminal.ini
  sed -i 's/colorScheme.*/colorScheme=Tango/' $QTCONFIG/qterminal.ini
  sed -i 's/fontFamily.*/fontFamily=DejaVu Sans Mono/' $QTCONFIG/qterminal.ini
  sed -i 's/fontSize.*/fontSize=7/' $QTCONFIG/qterminal.ini
  sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' $QTCONFIG/qterminal.ini
  #sed -i 's/.*//' $QTCONFIG
  # also set ctrl+w, ctrl+e, ctrl+d - split panes and close subterminal?  
  #echo "Removing write permissions from qterminal.ini,,, (workaround to make prefs stick)"
  #chmod -w $QTCONFIG/qterminal.ini
}

setup_vscode() {
  local codeloc=$(which code)
  if ! [[ $codeloc == "" ]];then
    echo "[-] VSCode is already installed, skipping."
  else
    echo "[+] Installing VSCode..."
    wget -O ~/Downloads/installcode.deb https://go.microsoft.com/fwlink/?LinkID=760868
    sudo apt install ~/Downloads/installcode.deb
    if [[ $? -eq 0 ]];then
      echo "VSCode installation complete"
      vs_installed=true
    else
      echo "VSCode installation failed!"
      vs_installed=false
    fi
  fi
  if [[ $vs_installed ]];then
    code --install-extension nimda.deepdark-material
    echo "Setting up VSCode settings.json..."
    echo '{
    "breadcrumbs.enabled": false,
    "window.zoomLevel": -1,
    "workbench.colorTheme": "Deepdark Material Theme | Full Black Version",
    "editor.minimap.enabled": false,
    "editor.tabSize": 2,
    "editor.fontSize": 11,
    "editor.mouseWheelZoom": true,
    "workbench.editor.closeEmptyGroups": false,
    "scm.countBadge": "off",
    "editor.glyphMargin": false,
    "editor.rulers": [80, 100, 120] }' > $VSCONFIG/settings.json
  fi
}

main
exit 0
