#!/bin/sh
set -e
#source ../env/bin/activate

fontName="Besley"
axes="wght"

##########################################

echo ".
GENERATING VARIABLE
."
VF_DIR=../fonts/variable
rm -rf $VF_DIR
mkdir -p $VF_DIR

fontmake -m designspace/$fontName.designspace -o variable --output-path $VF_DIR/$fontName[$axes].ttf

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
	gftools fix-vf-meta $font;
	mv "$font.fix" $font;
done
rm $VF_DIR/*gasp*


##########################################

rm -rf instance_ufo/ master_ufo/

echo ".
COMPLETE!
."
