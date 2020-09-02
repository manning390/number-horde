#!/usr/bin/env sh

# abort on errors
set -e

# build
cmd "/C cd /d D:\ && cd Railalis\Documents\Code\godot\number-horde\client && npm run build"

# navigate into the build output directory
cd dist

git init
git add -A
git commit -m 'deploy'

# if you are deploying to https://<USERNAME>.github.io/<REPO>
# because fucky wucky, make sure to delete the branch in remote first via ssh. -f is fucked and everything is fucked and I dont' fucking care
git push -f geth@manning390:/home/geth/repo/number-horde.git master:client-prod

cd -
