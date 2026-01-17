#!/bin/bash

# Enable aliases
GIT=0 # 1 = on, 0 = off

# Git
if [ "$GIT" -eq 1 ]; then
    alias g='git'
    alias ga='git add'
    alias gaa='git add .'
    alias gcm='git commit -m'
    alias gcam='git commit -a -m'
    alias gco='git checkout'
    alias gd='git diff'
    alias gg='git gui'
    alias gst='git status'
    alias gb='git branch'
    alias gl='git log'
    alias gp='git pull'
    alias gpu='git push'
    alias gcl='git clone'
    alias gm='git merge'
    alias gre='git rebase'
    alias gr='git remote'
    alias grv='git remote -v'
    alias gcb='git checkout -b'
    alias grh='git reset --hard'
    alias grs='git reset --soft'
    # -----
    alias gfo='git fetch origin'
    alias gs='git stash'
    alias gsp='git stash pop'
fi
