#!/usr/bin/env bash

TMP=$(mktemp -d cgf.XXXXXX)
git clone --depth 1 https://github.com/db0/godot-card-game-framework.git $TMP
SHA=$(git --git-dir=$TMP/.git rev-parse HEAD)
cp -R $TMP/src .
rm -rf $TMP
echo "Updated godot-card-game-framework to sha $SHA"

# cleanup
rm src/custom/cards/CardConfig.gd
rm src/custom/cards/CustomScripts.gd
rm src/custom/CFConst.gd
