#!/bin/bash

CURDIR=`pwd`
KATIDIR=${CURDIR%/cvs/cdk}
export PATH=/usr/sbin:/sbin:$PATH
CONFIGPARAM=`cat lastChoice`

echo ""
echo "---------------------------------------"
echo ""
echo "Вас приветствуют piterkadet/teslanet/Greder"
echo ""
echo "---------------------------------------"
echo ""

echo && \
echo "Performing autogen.sh..." && \
echo "------------------------" && \
./autogen.sh && \
echo && \
echo "Performing configure..." && \
echo "-----------------------" && \
echo && \
./configure $CONFIGPARAM

echo ""
echo ""
echo "-----------------------"
echo "Параметры Вашей компиляции подтверждены!"
echo "-----------------------"
echo ""
echo "Теперь Вы должны выбрать один из вариантов компиляции:"
echo "-----------------------"
echo ""
echo "make yaud-enigma2-nightly"
echo "make yaud-enigma2-pli-nightly"
echo "make yaud-xbmc-nightly"
echo "-----------------------"
echo ""
