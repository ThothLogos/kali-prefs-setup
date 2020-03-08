#!/bin/bash

#TODO:

#  - Set QTerminal options: font, colors, margin, transparency, history unlimited
#       /home/thoth/.config/qterminal.org/qterminal.ini
#  - Setup git credentials
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
    #setup_git
    #setup_qterminal
    #setup_vscode
    echo "Yarr"
}

setup_git() {
    sudo git config --system user.name $GITUSER
    sudo git config --system user.email $GITMAIL
}

setup_qterminal() {
  sed -i 's/Borderless.*/Borderless=true/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/HistoryLimited.*/HistoryLimited=false/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/MenuVisible.*/MenuVisible=false/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/ScrollbarPosition.*/ScrollbarPosition=0/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/TerminalTransparency.*/TerminalTransparency=0/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/fontFamily.*/fontFamily=DejaVu Sans Mono/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/fontSize.*/fontSize=8/' /home/thoth/.config/qterminal.org/qterminal.ini
  sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' /home/thoth/.config/qterminal.org/qterminal.ini
  #sed -i 's/.*//' /home/thoth/.config/qterminal.org/qterminal.ini
  # also set ctrl+w, ctrl+e, ctrl+d - split panes and close subterminal?
}

setup_vscode() {
  wget -O ~/Downloads/installcode.deb https://go.microsoft.com/fwlink/?LinkID=760868
  sudo apt install ~/Downloads/installcode.deb
  code --install-extension nimda.deepdark-material
}

main
exit 0