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

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) display_usage; exit 0;;
    -G|--golang) golang=true; shift 1;;
    -R|--rust) rust=true; shift 1;;
    -C|--code) code=true; shift 1;;
    *) err_echo "Unknown command: $1" >&2; exit 1;;
  esac
done

main() {
    setup_git
    setup_qterminal
    [[ $code ]] && setup_vscode
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
  sed -i 's/fontSize.*/fontSize=8/' $QTCONFIG/qterminal.ini
  sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' $QTCONFIG/qterminal.ini
  #sed -i 's/.*//' $QTCONFIG
  # also set ctrl+w, ctrl+e, ctrl+d - split panes and close subterminal?
}

setup_vscode() {
  local codeloc=$(which code)
  if ! [[ $codeloc == "" ]];then
    echo "VSCode is already installed, skipping install"
  else
    echo "Installing VSCode..."
    wget -O ~/Downloads/installcode.deb https://go.microsoft.com/fwlink/?LinkID=760868
    sudo apt install ~/Downloads/installcode.deb
  fi
  code --install-extension nimda.deepdark-material
  echo "Setting up VSCode settings.json..."
  echo '{
    "window.zoomLevel": -2,
    "workbench.colorTheme": "Deepdark Material Theme | Full Black Version",
    "editor.minimap.enabled": false,
    "editor.tabSize": 2
}' > $VSCONFIG/settings.json
}

main
exit 0
