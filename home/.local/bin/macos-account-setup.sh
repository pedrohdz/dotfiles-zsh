#!/bin/bash

#----
# Dock
#----
defaults write com.apple.dock static-only -bool true
defaults write com.apple.dock mouse-over-hilite-stack -boolean yes


#----
# Disk Utility
#----
# com.apple.DiskUtility : Show hidden partitions
defaults write com.apple.DiskUtility DUDebugMenuEnabled 1

killall Dock

