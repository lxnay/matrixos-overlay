#!/bin/bash

if [ -n "$PS1" ] && [ -t 1 ]; then
  return
fi

# matrixOS green colors
COLOR_LOGO="\033[1;32m"    # Bright Green
COLOR_TEXT="\033[0;32m"    # Darker Green
COLOR_WARN="\033[1;37m"    # White/Bold for the path
COLOR_RESET="\033[0m"
DOC_PATH="/matrixos/welcome/README.md"

echo -e "${COLOR_LOGO}"
cat << "EOF"
                  _        _       ___  ____  
  _ __ ___   __ _| |_ _ __(_)_  __/ _ \/ ___| 
 | '_ ` _ \ / _` | __| '__| \ \/ / | | \___ \ 
 | | | | | | (_| | |_| |  | |>  <| |_| |___) |
 |_| |_| |_|\__,_|\__|_|  |_/_/\_\\___/|____/ 
EOF

echo -e "${COLOR_TEXT}"
echo -e " :: System:  $(uname -n) [$(uname -r)]"
echo -e " :: User:    $(whoami)@$(hostname)"
echo -e "${COLOR_RESET}"

if [ -f "$DOC_PATH" ]; then
    echo -e " ---------------------------------------------------"
    echo -e "  [!] REQUIRED READING:"
    echo -e "      ${COLOR_WARN}cat $DOC_PATH${COLOR_RESET}"
    echo -e " ---------------------------------------------------"
    echo ""
fi
