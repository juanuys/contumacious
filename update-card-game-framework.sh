#!/usr/bin/env bash

TMP=tmp-cgf
rm -rf $TMP
git clone --depth 1 https://github.com/db0/godot-card-game-framework.git $TMP
SHA=$(git --git-dir=$TMP/.git rev-parse HEAD)


rm -rf src/core
cp -R $TMP/src/core src/

rm -rf src/custom
cp -R $TMP/src/custom src

# these are scripts that are supposed to be "moved" from custom to cc,
# i.e. they shouldn't exist in custom anymore after the move.
rm src/custom/CFConst.gd
rm src/custom/cards/CardConfig.gd

VERSION=cgf-version.txt
rm -f $VERSION
touch $VERSION
echo $SHA > $VERSION

echo "Updated godot-card-game-framework to sha $SHA"
echo "tmp left in-tact at $TMP"
echo
echo "Remember to look at the history for:"
echo
echo "https://github.com/db0/godot-card-game-framework/blob/main/src/custom/CFConst.gd"
echo "https://github.com/db0/godot-card-game-framework/blob/main/src/custom/cards/CardConfig.gd"
