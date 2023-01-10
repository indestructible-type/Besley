#!/bin/bash
. misc/init.sh

if [[ ! -d ../fonts/webfonts ]]; then
    mkdir ../fonts/webfonts
fi

HAS_PARALLEL=$(hash parallel ; echo $?)
TTFONTS=../fonts/ttf/*
VARFONTS=../fonts/variable/*
BUILDFONT='
    FA="`basename $FONT`"
    fonttools ttLib.woff2 compress "$FONT" --output-file "../fonts/webfonts/${FA%%.*}.woff2"
'

if [[ $HAS_PARALLEL -eq 0 ]]; then
    parallel --bar '
        FONT={};'"$BUILDFONT" ::: $TTFONTS $VARFONTS
else
    >&2 echo 'This script will run slower. Consider installing GNU `parallel`.'
    for FONT in $TTFONTS $VARFONTS; do
        eval $BUILDFONT
    done
fi
