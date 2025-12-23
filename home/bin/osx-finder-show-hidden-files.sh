#! /opt/local/bin/bash

new_state=${1,,}

case "$new_state" in
    yes|y|true|t|1)
        new_state=YES
        ;;
    no|n|false|f|0)
        new_state=NO
        ;;
    *)
        command=$(basename "$0") 
        echo "Usage: $command yes|no"
        exit 1
        ;;
esac

defaults write com.apple.Finder AppleShowAllFiles $new_state

echo "New state set to '$result'.  Must wait a few seconds before you can reset it again."

killall Finder

