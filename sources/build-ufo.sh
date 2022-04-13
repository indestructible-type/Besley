#!/bin/sh
set -e
#source ../env/bin/activate

fontName="Besley"
fontName_it="Besley-Italic"

##########################################

echo ".
GENERATING SOURCES
."
SOURCE_DIR=fontforge
UFO_DIR=ufo
rm -rf $UFO_DIR
mkdir -p $UFO_DIR
sfds=$(ls $SOURCE_DIR/*.sfd)
for source in $sfds
do
	base=${source##*/}
    test="Italic"
#	sfd2ufo $source $UFO_DIR/${base%.*}.ufo
	python3 misc/sfd2ufo --ufo-kerning --ufo-anchors $source $UFO_DIR/${base%.*}.ufo
	if test "${base#*$test}" != "$base"
    then
        cp misc/featuresItalic.fea $UFO_DIR/${base%.*}.ufo/features.fea
    else
        cp misc/features.fea $UFO_DIR/${base%.*}.ufo/features.fea
    fi
done

##########################################

find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf

echo ".
COMPLETE!
."
