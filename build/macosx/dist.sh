#!/bin/sh

REVISION=`../shared/gen-version-string`

RELEASE=$REVISION
echo Creating Arduino distribution for revision $REVISION...

echo Removing old work directory, etc.

# remove any unfinished builds or old builds
rm -rf arduino
rm -rf arduino-*
rm -rf Arduino*
rm -rf work

echo Rerunning make.sh...
./make.sh

echo Finished with make.sh.  Packaging release.

# write the release version number into the output directory
echo $REVISION > work/MapleIDE.app/Contents/Resources/Java/lib/build-version.txt

echo Cleaning file boogers...

# remove boogers
find work -name "*~" -exec rm -f {} ';'
# need to leave ds store stuff cuz one of those is important
#find processing -name ".DS_Store" -exec rm -f {} ';'
find work -name "._*" -exec rm -f {} ';'
find work -name "Thumbs.db" -exec rm -f {} ';'


# the following was adopted from the makefile by Remko Troncon:
# http://el-tramo.be/guides/fancy-dmg

echo Creating disk image...

SOURCE_DIR="work"
SOURCE_FILES="MapleIDE.app"
OUTPUT_DMG="maple-ide-$RELEASE-macosx-10_6"
WORK_DMG="working.dmg"
WORK_DIR="working_dir"

gzip -cd dist/template.dmg.gz > "$WORK_DMG"
mkdir -p "$WORK_DIR"
hdiutil attach "$WORK_DMG" -noautoopen -quiet -mountpoint "$WORK_DIR"
for i in "$SOURCE_FILES"; do
	rm -rf "$WORK_DIR/$i"
	ditto -rsrc "$SOURCE_DIR/$i" "$WORK_DIR/$i"
done
WC_DEV=`hdiutil info | grep "$WORK_DIR" | awk '{print $1}'` && hdiutil detach $WC_DEV -quiet -force
hdiutil convert "$WORK_DMG" -quiet -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_DMG"
rm -rf "$WORK_DIR"
rm -f "$WORK_DMG"

# for later, if we need to resize, etc
#hdiutil resize -size 200mb -growonly -imageonly working.dmg

echo Done.
