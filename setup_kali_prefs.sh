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
    #setup_qterminal
    #setup_vscode
    echo "Yarr"
}

setup_git() {
    local gcname=$(git config --system user.name)
    if [[ $? -eq 0 ]];
      echo "git user.name already set to $gcname, no changes"
    else
      sudo git config --system user.name $GITUSER
    fi
    local gcmail=$(git config --system user.email)
    if [[ $? -eq 0 ]];
      echo "git user.email already set to $gcmail, no changes"
    else
      sudo git config --system user.email $GITMAIL
    fi
}

setup_qterminal() {
  echo "Setting options in $QTERMINI..."
  sed -i 's/Borderless.*/Borderless=true/' $QTERMINI
  sed -i 's/HistoryLimited.*/HistoryLimited=false/' $QTERMINI
  sed -i 's/MenuVisible.*/MenuVisible=false/' $QTERMINI
  sed -i 's/ScrollbarPosition.*/ScrollbarPosition=0/' $QTERMINI
  sed -i 's/TerminalMargin.*/TerminalMargin=0/' $QTERMINI
  sed -i 's/TerminalTransparency.*/TerminalTransparency=0/' $QTERMINI
  sed -i 's/colorScheme.*/colorScheme=Tango/' $QTERMINI
  sed -i 's/fontFamily.*/fontFamily=DejaVu Sans Mono/' $QTERMINI
  sed -i 's/fontSize.*/fontSize=8/' $QTERMINI
  sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' $QTERMINI
  #sed -i 's/.*//' $QTERMINI
  # also set ctrl+w, ctrl+e, ctrl+d - split panes and close subterminal?
}

setup_vscode() {
  wget -O ~/Downloads/installcode.deb https://go.microsoft.com/fwlink/?LinkID=760868
  sudo apt install ~/Downloads/installcode.deb
  code --install-extension nimda.deepdark-material

  # change tab size
}

main
exit 0
