#!/bin/sh
set -e
#source ../env/bin/activate

fontName="Besley"
fontName_it="Besley-Italic"
axes="wdth,wght"

##########################################

echo ".
CHECKING FOR SOURCE FILES
."
if [ -e ufo ]
then
    echo ".
USING UFO SOURCE FILES
."
    UFO_SOURCES=true
else
    UFO_SOURCES=false
fi

##########################################

if [ $UFO_SOURCES = false ]
    then
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
fi

##########################################

echo ".
GENERATING VARIABLE
."
VF_DIR=../fonts/variable
rm -rf $VF_DIR
mkdir -p $VF_DIR

fontmake -m designspace/$fontName.designspace -o variable --output-path $VF_DIR/$fontName[$axes].ttf
fontmake -m designspace/$fontName_it.designspace -o variable --output-path $VF_DIR/$fontName_it[$axes].ttf

##########################################

echo ".
POST-PROCESSING VF
."
vfs=$(ls $VF_DIR/*.ttf)
for font in $vfs
do
	gftools fix-dsig --autofix $font
	gftools fix-nonhinting $font $font.fix
	mv $font.fix $font
	gftools fix-unwanted-tables --tables MVAR $font
done

statmake --designspace designspace/$fontName.designspace $VF_DIR/$fontName[$axes].ttf
statmake --designspace designspace/$fontName_it.designspace $VF_DIR/$fontName_it[$axes].ttf

rm $VF_DIR/*gasp*

##########################################

if [ $UFO_SOURCES = false ]
then
	rm -rf $UFO_DIR
	find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
fi

echo ".
COMPLETE!
."
