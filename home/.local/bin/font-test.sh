#! /bin/bash

bold=$(tput bold)
italics=$(tput sitm)
normal=$(tput sgr0)
underline=$(tput smul)

echo "Normal"
echo -e "${bold}Bold${normal}"
echo -e "${italics}Italic${normal}"
echo -e "${bold}${italics}Bold Italic${normal}"
echo -e "${underline}Underline${normal}"
echo "== === !== >= <= =>"
echo "契          勒 鈴 "
echo "契勒鈴"
