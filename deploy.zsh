#!/bin/zsh
set -e 
cd tapcat-deploy
git pull
cd $1
/bin/zsh $1.zsh
