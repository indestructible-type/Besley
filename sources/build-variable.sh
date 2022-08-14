#!/bin/bash
set -e

FONTNAMES=("Besley" "Besley-Italic")
AXES="wdth,wght"

##########################################

echo ".
CHECKING FOR SOURCE FILES
."
if [ -e ufo ]
then
    echo ".
USING EXISTING UFO SOURCE FILES
."
    UFO_SOURCES=true
else
    UFO_SOURCES=false
fi

##########################################

if [ $UFO_SOURCES = false ]; then
	source ./gen-sources.sh
fi

##########################################

echo ".
CLEANING UP IF NEEDED
."
VF_DIR=../fonts/variable
mkdir -p ./"$VF_DIR" || true
for f in `find "$VF_DIR" -iname '*.ttf' -or -iname '*.otf' -type f`; do
	rm "$f"
	echo "Deleted $f"
done

echo ".
GENERATING VARIABLE
."
FONTS_GLYF=()
FONTS_CFF2=()

for fontName in "${FONTNAMES[@]}"; do 
	FONTS_GLYF+=("${VF_DIR}/${fontName}[${AXES}].ttf")
	FONTS_CFF2+=("${VF_DIR}/${fontName}[${AXES}].otf")
done

parallel bash -c < \
<(i=-1; for font in "${FONTS_GLYF[@]}"; do i=$i+1;
	echo fontmake -m designspace/"${FONTNAMES[$i]}".designspace -o variable --output-path "${font@Q}"
done

i=-1; for font in "${FONTS_CFF2[@]}"; do i=$i+1;
	echo fontmake -m designspace/"${FONTNAMES[$i]}".designspace -o variable-cff2 --output-path "${font@Q}"
done)

##########################################

echo ".
POST-PROCESSING VF
."
for font in "${FONTS_GLYF[@]}"
do
	TMPFILE=$(mktemp)
	gftools fix-nonhinting "$font" "$TMPFILE"
	gftools fix-unwanted-tables --tables MVAR "$TMPFILE"
	mv "$TMPFILE" "$font"
done

for font in "${FONTS_GLYF[@]}" "${FONTS_CFF2[@]}"; do
	statmake --designspace designspace/$fontName.designspace $font
done

rm $VF_DIR/*gasp*

##########################################

if [ $UFO_SOURCES = false ]; then
	rm -rf $UFO_DIR
	find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
fi

echo ".
COMPLETE!
."
