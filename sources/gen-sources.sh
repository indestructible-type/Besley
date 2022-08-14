#!/bin/bash
PYTHON_HOME="$PWD/misc/sfdnormalize:$PWD/misc/sfd2ufo/Lib/sfdLib:$PWD/misc/sfd2ufo/Lib:$PYTHON_HOME"

echo ".
GENERATING UFO SOURCES
."
SOURCE_DIR=fontforge
UFO_DIR=ufo
rm -rf $UFO_DIR
mkdir -p $UFO_DIR
sfds=$(ls $SOURCE_DIR/*.sfd)
for source in $sfds
do
	base=${source##*/}
	italic="Italic"
	sfdnormalize ./"$source" "$source"_out -k Copyright -D VWidth
	mv ./"$source"_out ./"$source"
	python3 misc/sfd2ufo/Lib/sfdLib/__main__.py --ufo-kerning --ufo-anchors $source $UFO_DIR/${base%.*}.ufo
	if test "${base#*$italic}" != "$base"
	then
		cp misc/features${italic}.fea $UFO_DIR/${base%.*}.ufo/features.fea
	else
		cp misc/features.fea $UFO_DIR/${base%.*}.ufo/features.fea
	fi
done
