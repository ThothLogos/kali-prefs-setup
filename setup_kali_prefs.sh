#!/bin/bash

# TODO:
#
# - Rust asks for confirmation, can we --yes that?
# - qterminal seds fail unless user has opened the prefs pane already and hit apply, fix
# - Make window borders thinner? May require .xpm headaches
# - Possible to force xfce to reload all confs without session restart?
# - VSCode extensions for Golang, Rust - what else?

if ! [[ -f config.sh ]];then
  echo "The config.sh file is missing! Please cp config_example.sh config.sh and setup."
  exit 1
elif [[ $(grep "changeme" config.sh) ]];then
  echo "The config.sh file exists but still holds default example values, please configure!"
  exit 1
fi

source config.sh

display_usage() {
  echo -e "
    Usage: $(basename) [OPTIONS]

  -C, --code                        Install & configure VSCode + extensions
  -R, --rust                        Install & update Rust latest stable
  -G, --golang                      Install Go latest stable
  -X, --xfce                        Configure xfce4 panel, power, shortcuts
  -F, --fonts                       Monaco, Menlo, ProggyTinySZ
  -A, --all                         Install & configure all options
  -h, --help                        This screen

  "
}

while [ "$#" -gt 0 ];do
  case "$1" in
    -h|--help) display_usage; exit 0;;
    -C|--code) code=true; shift 1;;
    -R|--rust) rust=true; shift 1;;
    -G|--golang) golang=true; shift 1;;
    -X|--xfce) xfce=true; shift 1;;
    -F|--fonts) fonts=true; shift 1;;
    -A|--all) golang=true; rust=true; code=true, xfce=true, fonts=true; shift 1;;
    *) err_echo "Unknown command: $1" >&2; exit 1;;
  esac
done

main() {
  sudo apt update
  sudo apt upgrade -y
  setup_git
  setup_qterminal
  [[ $fonts ]] && setup_fonts
  [[ $xfce ]] && setup_xfce4
  [[ $code ]] && setup_vscode
  [[ $rust ]] && setup_rust
  [[ $golang ]] && setup_golang

  if ! [[ -d ~/Projects ]];then
    mkdir ~/Projects
  fi

  if ! [[ $(grep "cd ~/Projects" ~/.bashrc) ]];then
    echo "cd ~/Projects" >> ~/.bashrc
  fi

  # since we're prob running this from qterm, we have to kill it
  # to prevent the current loaded prefs in the session being re-written
  local i=5
  echo "This terminal will self destruct in $i..."
  sleep 1.0
  while [[ $i -gt 1 ]];do
    i=$(($i-1))
    echo "... $i"
    sleep 1.0
  done
  pkill qterminal
  # "As I rained blows upon him, I realized; there had to be another way!" - Frank Costanza
}

setup_fonts() {
  local monaco_url="https://github.com/hbin/top-programming-fonts/raw/master/Monaco-Linux.ttf"
  local menlo_url="https://github.com/hbin/top-programming-fonts/raw/master/Menlo-Regular.ttf"
  local proggy_url="https://cdn.proggyfonts.net/wp-content/downloads/ProggyTinySZ.ttf.zip"
  sudo wget -O /usr/share/fonts/Monaco-Linux.ttf $monaco_url
  sudo wget -O /usr/share/fonts/Menlo-Regular.ttf $menlo_url
  sudo wget -O ~/Downloads/ProggyTinySZ.ttf.zip $proggy_url
  sudo unzip ~/Downloads/ProggyTinySZ.ttf.zip -d /usr/share/fonts/
  sudo fc-cache -fv
}

setup_rust() {
  local rustuploc=$(which rustup)
  if ! [[ $rustuploc == "" ]];then
    echo "[-] Rust is already installed, skipping."
  else
    echo "[+] Installing latest stable Rust..."
    curl https://sh.rustup.rs -sSf | sh
    if [[ $? -eq 0 ]];then
      echo "Rust installation successful, running update."
      echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
      rustup update
    else
      echo "Rust installation failed!"
      rust_installed=false
    fi
  fi
}

setup_golang() {
  local goloc=$(which go)
  if ! [[ $goloc == "" ]];then
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
      if [[ $? -eq 0 ]];then
        echo "export PATH=\"$HOME/.cargo/bin:$PATH\"" >> ~/.bashrc
        golang_installed=true
      fi
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
  if ! [[ -f $QTCONFIG/qterminal.ini ]];then
    touch $QTCONFIG/qterminal.ini
    sed -i 's/Borderless.*/Borderless=true/' $QTCONFIG/qterminal.ini
    sed -i 's/HistoryLimited.*/HistoryLimited=false/' $QTCONFIG/qterminal.ini
    sed -i 's/MenuVisible.*/MenuVisible=false/' $QTCONFIG/qterminal.ini
    sed -i 's/ScrollbarPosition.*/ScrollbarPosition=0/' $QTCONFIG/qterminal.ini
    sed -i 's/TerminalMargin.*/TerminalMargin=1/' $QTCONFIG/qterminal.ini
    sed -i 's/TerminalTransparency.*/TerminalTransparency=0/' $QTCONFIG/qterminal.ini
    sed -i 's/colorScheme.*/colorScheme=Tango/' $QTCONFIG/qterminal.ini
    se d -i 's/fontFamily.*/fontFamily=DejaVu Sans Mono/' $QTCONFIG/qterminal.ini
    sed -i 's/fontSize.*/fontSize=7/' $QTCONFIG/qterminal.ini
    sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' $QTCONFIG/qterminal.ini
  else
    sed -i 's/Borderless.*/Borderless=true/' $QTCONFIG/qterminal.ini
    sed -i 's/HistoryLimited.*/HistoryLimited=false/' $QTCONFIG/qterminal.ini
    sed -i 's/MenuVisible.*/MenuVisible=false/' $QTCONFIG/qterminal.ini
    sed -i 's/ScrollbarPosition.*/ScrollbarPosition=0/' $QTCONFIG/qterminal.ini
    sed -i 's/TerminalMargin.*/TerminalMargin=1/' $QTCONFIG/qterminal.ini
    sed -i 's/TerminalTransparency.*/TerminalTransparency=0/' $QTCONFIG/qterminal.ini
    sed -i 's/colorScheme.*/colorScheme=Tango/' $QTCONFIG/qterminal.ini
    sed -i 's/fontFamily.*/fontFamily=DejaVu Sans Mono/' $QTCONFIG/qterminal.ini
    sed -i 's/fontSize.*/fontSize=7/' $QTCONFIG/qterminal.ini
    sed -i 's/ApplicationTransparency.*/ApplicationTransparency=0/' $QTCONFIG/qterminal.ini
    #sed -i 's/.*//' $QTCONFIG
    # also set ctrl+w, ctrl+e, ctrl+d - split panes and close subterminal?
  fi
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

setup_xfce4() {
  # Add right-super key to pull up whiskermenu
  local whisker_old='<property name="&lt;Primary&gt;Escape" type="string" value="xfce4-popup-whiskermenu"/>'
  local whisker_new='<property name="Super_R" type="string" value="xfce4-popup-whiskermenu"/>'
  sed -i "s#$whisker_old#$whiker_new#" $XFCECONFIG/xfce4-keyboard-shortcuts.xml

  # Change screen timeout
  local acsleep='    <property name="dpms-on-ac-sleep" type="uint" value="0"/>'
  local acblank='    <property name="blank-on-ac" type="int" value="27"/>'
  local acoff='    <property name="dpms-on-ac-off" type="uint" value="0"/>'
  sed -i "/show-tray-icon/ a $acoff" $XFCECONFIG/xfce4-panel.xml
  sed -i "/show-tray-icon/ a $acblank" $XFCECONFIG/xfce4-panel.xml
  sed -i "/show-tray-icon/ a $acsleep" $XFCECONFIG/xfce4-panel.xml

  # Move taskbar panel to bottom of screen
  local panel_pos_old='<property name="position" type="string" value="p=6;x=0;y=0"/>'
  local panel_pos_new='<property name="position" type="string" value="p=8;x=1280;y=1423"/>'
  sed -i "s#$panel_pos_old#$panel_pos_new#" $XFCECONFIG/xfce4-panel.xml

  # Make taskbar a bit thinner
  local panel_size_old='<property name="size" type="uint" value="30"/>'
  local panel_size_new='<property name="size" type="uint" value="18"/>'
  sed -i "s#$panel_size_old#$panel_size_new#" $XFCECONFIG/xfce4-panel.xml
}

main
exit 0
