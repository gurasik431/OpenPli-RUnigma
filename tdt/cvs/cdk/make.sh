#!/bin/bash

if [ "$1" == -h ] || [ "$1" == --help ]; then
 echo "Parameter 1: Поддерживаемая платформа (1)"
 echo "Parameter 2: Ядро (1-3)"
 echo "Parameter 3: Режим отладки (Y/N)"
 echo "Parameter 4: Плэйер (1)"
 echo "Parameter 5: Мультиком (1-2)"
 echo "Parameter 6: Мультимедийная платформа (1-2)"
 echo "Parameter 7: Поддержка внешнего LCD-дисплея (1-2)"
 echo "Parameter 8: VDR (1-3)"
 echo "Parameter 9: Графическая платформа (1-2)"
 exit
fi

CURDIR=`pwd`
KATIDIR=${CURDIR%/cvs/cdk}
export PATH=/usr/sbin:/sbin:$PATH

CONFIGPARAM=" \
 --enable-maintainer-mode \
 --prefix=$KATIDIR/tufsbox \
 --with-cvsdir=$KATIDIR/cvs \
 --with-customizationsdir=$KATIDIR/custom \
 --with-archivedir=$HOME/Archive \
 --enable-ccache"

##############################################
echo ""
echo "---------------------------------------"
echo ""
echo "Вас приветствуют piterkadet/teslanet/Greder"
echo ""
echo "---------------------------------------"
echo ""
echo "Подтвердите, пожалуйста, параметры компиляции"
echo ""
echo "---------------------------------------"
##############################################

# config.guess generates different answers for some packages
# Ensure that all packages use the same host by explicitly specifying it.

# First obtain the triplet
AM_VER=`automake --version | awk '{print $NF}' | grep -oEm1 "^[0-9]+.[0-9]+"`
host_alias=`/usr/share/automake-${AM_VER}/config.guess`

# Then undo Suse specific modifications, no harm to other distribution
case `echo ${host_alias} | cut -d '-' -f 1` in
  i?86) VENDOR=pc ;;
  *   ) VENDOR=unknown ;;
esac
host_alias=`echo ${host_alias} | sed -e "s/suse/${VENDOR}/"`

# And add it to the config parameters.
CONFIGPARAM="${CONFIGPARAM} --host=${host_alias} --build=${host_alias}"

##############################################
echo ""
echo ""
echo ""
echo "Поддерживаемая платформа:"
echo "---------------------------------------"
echo "   1) Opticum 9500 HD (HL-101)"
echo ""
case $1 in
	[1]) REPLY=$1
	echo -e "\nВыбранная платформа: $REPLY\n"
	;;
	*)
	read -p "Выберите платформу (1)? ";;
esac

case "$REPLY" in
	 1) TARGET="--enable-hl101";;
	 *) TARGET="--enable-hl101";;
esac
CONFIGPARAM="$CONFIGPARAM $TARGET"

##############################################
echo ""
echo -e "Ядро:"
echo "---------------------------------------"
echo "   1) STM 24 P0207"
echo "   2) STM 24 P0210"
echo "   3) STM 24 P0211"
echo "   4) STM 24 P0302"
echo ""
case $2 in
        [1-4] | 1[0-9]) REPLY=$2
        echo -e "\nВыбранное ядро: $REPLY\n"
        ;;
        *)
        read -p "Выберите ядро (1-4)? ";;
esac

case "$REPLY" in
	1) KERNEL="--enable-stm24 --enable-p0207";STMFB="stm24";;
	2) KERNEL="--enable-stm24 --enable-p0210";STMFB="stm24";;
	3) KERNEL="--enable-stm24 --enable-p0211";STMFB="stm24";;
	4) KERNEL="--enable-stm24 --enable-p0302";STMFB="stm24";;
	*) KERNEL="--enable-stm24 --enable-p0210";STMFB="stm24";;
esac
CONFIGPARAM="$CONFIGPARAM $KERNEL"

##############################################
echo ""
if [ "$3" ]; then
REPLY="$3"
echo "   Активировать отладку (y/N)? "
echo -e "\nВыберите вариант: $REPLY\n"
else
REPLY=N
read -p "   Активировать отладку (y/N)? "
echo "---------------------------------------"
fi
[ "$REPLY" == "y" -o "$REPLY" == "Y" ] && CONFIGPARAM="$CONFIGPARAM --enable-debug"

##############################################

cd ../driver/
echo "# Automatically generated config: don't edit" > .config
echo "#" >> .config
echo "export CONFIG_ZD1211REV_B=y" >> .config
echo "export CONFIG_ZD1211=n"		>> .config
cd -

##############################################
echo ""
echo -e "\nПлэйер:"
echo "---------------------------------------"
echo "   1) Плэйер 191"
echo ""
case $4 in
        [1]) REPLY=$4
        echo -e "\nВыбранный плэйер: $REPLY\n"
        ;;
        *)
        read -p "Выберите плэйер (1)? ";;
esac

case "$REPLY" in
	1) PLAYER="--enable-player191"
       cd ../driver/include/
       if [ -L player2 ]; then
          rm player2
       fi

       if [ -L stmfb ]; then
          rm stmfb
       fi
       ln -s player2_179 player2
       if [ "$STMFB" == "stm24" ]; then
           ln -s stmfb-3.1_stm24_0102 stmfb
       else
           ln -s stmfb-3.1_stm23_0032 stmfb
       fi
       cd -

       cd ../driver/
       if [ -L player2 ]; then
          rm player2
       fi
       ln -s player2_191 player2
       echo "export CONFIG_PLAYER_191=y" >> .config
       cd -

       cd ../driver/stgfb
       if [ -L stmfb ]; then
          rm stmfb
       fi
       if [ "$STMFB" == "stm24" ]; then
           ln -s stmfb-3.1_stm24_0102 stmfb
       else
           ln -s stmfb-3.1_stm23_0032 stmfb
       fi
       cd -
    ;;
	*) PLAYER="--enable-player191";;
esac

##############################################
echo ""
echo -e "\nМультиком:"
echo "---------------------------------------"
echo "   1) Мультиком 3.2.4 "
echo ""
case $5 in
        [1]) REPLY=$5
        echo -e "\nВыбранный мультиком: $REPLY\n"
        ;;
        *)
        read -p "Выберите мультиком (1)? ";;
esac
echo ""
case "$REPLY" in
       1) MULTICOM="--enable-multicom324"
       cd ../driver/include/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s ../multicom-3.2.4/include multicom
       cd -

       cd ../driver/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s multicom-3.2.4 multicom
       echo "export CONFIG_MULTICOM324=y" >> .config
       cd -
    ;;
	*) MULTICOM="--enable-multicom324";;
esac

##############################################
echo ""
echo -e "\nМультимедийная платформа:"
echo "---------------------------------------"
echo "   1) eplayer3  (Рекомендуется для Enigma1/2, Neutrino/HD, VDR)"
echo "   2) gstreamer (Рекомендуется для Enigma2 / PLI, XBMC)"
echo ""
case $6 in
        [1-2]) REPLY=$6
        echo -e "\nВыбранная мультимедийная платформа: $REPLY\n"
        ;;
        *)
        read -p "Выберите мультимедийную платформу (1-2)? ";;
esac

case "$REPLY" in
	1) MEDIAFW="";;
	2) MEDIAFW="--enable-mediafwgstreamer";;
	*) MEDIAFW="";;
esac

##############################################
echo ""
echo -e "\nПоддержка внешнего LCD-дисплея:"
echo "---------------------------------------"
echo "   1) Без поддержки LCD-дисплея"
echo "   2) С поддержкой LCD-дисплея"
echo ""
case $7 in
        [1-2]) REPLY=$7
        echo -e "\nВыбранный режим: $REPLY\n"
        ;;
        *)
        read -p "Выберите режим поддержки LCD-дисплея (1-2)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="";;
	2) EXTERNAL_LCD="--enable-externallcd";;
	*) EXTERNAL_LCD="";;
esac

##############################################

CONFIGPARAM="$CONFIGPARAM $PLAYER $MULTICOM $MEDIAFW $EXTERNAL_LCD"

##############################################
echo ""
echo -e "\nВыбрать тип VDR:"
echo "---------------------------------------"
echo "   1) НЕТ"
echo "   2) VDR-1.7.22"
echo "   3) VDR-1.7.27"
echo ""
case $8 in
	[1-3]) REPLY=$8
        echo -e "\nВыбранный тип VDR: $REPLY\n"
        ;;
        *)
        read -p "Выберитое тип VDR (1-3)? ";;
esac
case "$REPLY" in
	1) VDR=""
       cd ../apps/vdr/
       if [ -L vdr ]; then
          rm vdr
       fi
       cd -
    ;;
	2) VDR="--enable-vdr1722"
       cd ../apps/vdr/
       if [ -L vdr ]; then
          rm vdr
       fi

       ln -s vdr-1.7.22 vdr
       cd -
    ;;
    	3) VDR="--enable-vdr1727"
       cd ../apps/vdr/
       if [ -L vdr ]; then
          rm vdr
       fi

       ln -s vdr-1.7.27 vdr
       cd -
    ;;
	*) VDR="--enable-vdr1727";;
esac

##############################################
echo ""
echo -e "\nГрафическая платформа:"
echo "---------------------------------------"
echo "   1) Framebuffer (Рекомендуется для Enigma1/2, Neutrino1/HD, VDR)"
echo "   2) DirectFB    (Рекомендуется для XBMC)"
echo ""
case $9 in
        [1-2]) REPLY=$9
        echo -e "\nВыбранная графическая платформа: $REPLY\n"
        ;;
        *)
        read -p "Выберите графическую платформу (1-2)? ";;
esac

case "$REPLY" in
	1) GFW="";;
	2) GFW="--enable-graphicfwdirectfb";;
	*) GFW="";;
esac

##############################################

CONFIGPARAM="$CONFIGPARAM $PLAYER $MULTICOM $MEDIAFW $EXTERNAL_LCD $VDR $GFW"

##############################################


echo && \
echo "Performing autogen.sh..." && \
echo "------------------------" && \
./autogen.sh && \
echo && \
echo "Performing configure..." && \
echo "-----------------------" && \
echo && \
./configure $CONFIGPARAM

#Dagobert: I find it sometimes useful to know
#what I have build last in this directory ;)
echo $CONFIGPARAM >lastChoice
echo ""
echo ""
echo "-----------------------"
echo "Параметры Вашей компиляции подтверждены!"
echo "-----------------------"
echo ""
echo "Теперь Вы должны выбрать один из вариантов компиляции:"
echo "-----------------------"
echo ""
echo "make yaud-enigma2-pli-nightly"
echo "make yaud-enigma2-pli-nightly-full"
echo "make yaud-xbmc-nightly"
echo "-----------------------"
echo ""
