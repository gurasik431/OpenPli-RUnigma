#
# auxiliary targets for model-specific builds
#

#
# release_common_utils
#
release_common_utils:
#	remove the slink to busybox
	rm -f $(prefix)/release/sbin/halt
	cp -f $(targetprefix)/sbin/halt $(prefix)/release/sbin/
	cp $(buildprefix)/root/release/umountfs $(prefix)/release/etc/init.d/
	cp $(buildprefix)/root/release/rc $(prefix)/release/etc/init.d/
	cp $(buildprefix)/root/release/sendsigs $(prefix)/release/etc/init.d/
	chmod 755 $(prefix)/release/etc/init.d/umountfs
	chmod 755 $(prefix)/release/etc/init.d/rc
	chmod 755 $(prefix)/release/etc/init.d/sendsigs
	mkdir -p $(prefix)/release/etc/rc.d/rc0.d
	ln -s ../init.d $(prefix)/release/etc/rc.d
	ln -fs halt $(prefix)/release/sbin/reboot
	ln -fs halt $(prefix)/release/sbin/poweroff
	ln -s ../init.d/sendsigs $(prefix)/release/etc/rc.d/rc0.d/S20sendsigs
	ln -s ../init.d/umountfs $(prefix)/release/etc/rc.d/rc0.d/S40umountfs
	ln -s ../init.d/halt $(prefix)/release/etc/rc.d/rc0.d/S90halt
	mkdir -p $(prefix)/release/etc/rc.d/rc6.d
	ln -s ../init.d/sendsigs $(prefix)/release/etc/rc.d/rc6.d/S20sendsigs
	ln -s ../init.d/umountfs $(prefix)/release/etc/rc.d/rc6.d/S40umountfs
	ln -s ../init.d/reboot $(prefix)/release/etc/rc.d/rc6.d/S90reboot

#
# release_hl101
#
release_hl101: release_common_utils
	echo "hl101" > $(prefix)/release/etc/hostname
	cp $(buildprefix)/root/release/halt_hl101 $(prefix)/release/etc/init.d/halt
	chmod 755 $(prefix)/release/etc/init.d/halt
	cp -f $(archivedir)/boot/video_7109.elf $(prefix)/release/boot/video.elf
	cp -f $(archivedir)/boot/audio_7109.elf $(prefix)/release/boot/audio.elf
	$(if $(P0207),cp -dp $(archivedir)/ptinp/pti_207.ko $(prefix)/release/lib/modules/$(KERNELVERSION)/extra/pti/pti.ko)
	$(if $(P0209),cp -dp $(archivedir)/ptinp/pti_209.ko $(prefix)/release/lib/modules/$(KERNELVERSION)/extra/pti/pti.ko)
	$(if $(P0210),cp -dp $(archivedir)/ptinp/pti_210.ko $(prefix)/release/lib/modules/$(KERNELVERSION)/extra/pti/pti.ko)
	$(if $(P0211),cp -dp $(archivedir)/ptinp/pti_211.ko $(prefix)/release/lib/modules/$(KERNELVERSION)/extra/pti/pti.ko)
	$(if $(P0302),cp -dp $(archivedir)/ptinp/pti_302.ko $(prefix)/release/lib/modules/$(KERNELVERSION)/extra/pti/pti.ko)
	cp $(targetprefix)/lib/firmware/dvb-fe-avl2108.fw $(prefix)/release/lib/firmware/
	cp $(targetprefix)/lib/firmware/dvb-fe-stv6306.fw $(prefix)/release/lib/firmware/
	rm -f $(prefix)/release/lib/firmware/dvb-fe-{avl6222,cx24116,cx21143}.fw
	cp -dp $(buildprefix)/root/etc/lircd_hl101.conf $(prefix)/release/etc/lircd.conf
	cp -p $(targetprefix)/usr/bin/lircd $(prefix)/release/usr/bin/
	mkdir -p $(prefix)/release/var/run/lirc
	rm -f $(prefix)/release/bin/evremote
	cp -f $(buildprefix)/root/usr/local/share/enigma2/keymap_hl101.xml $(prefix)/release/usr/local/share/enigma2/keymap.xml

#
# release_base
#
# the following target creates the common file base
release_base:
	rm -rf $(prefix)/release || true
	$(INSTALL_DIR) $(prefix)/release && \
	$(INSTALL_DIR) $(prefix)/release/{bin,boot,dev,dev.static,etc,lib,media,mnt,proc,ram,root,sbin,share,sys,tmp,usr,var} && \
	$(INSTALL_DIR) $(prefix)/release/etc/{enigma2,fonts,init.d,network,tuxbox} && \
	$(INSTALL_DIR) $(prefix)/release/etc/network/{if-down.d,if-post-down.d,if-pre-up.d,if-up.d} && \
	$(INSTALL_DIR) $(prefix)/release/lib/modules && \
	$(INSTALL_DIR) $(prefix)/release/media/{dvd,hdd,net} && \
	ln -s /media/hdd $(prefix)/release/hdd && \
	$(INSTALL_DIR) $(prefix)/release/mnt/{hdd,nfs,usb} && \
	$(INSTALL_DIR) $(prefix)/release/usr/{bin,lib,local,share,tuxtxt} && \
	$(INSTALL_DIR) $(prefix)/release/usr/local/{bin,share} && \
	ln -sf /etc $(prefix)/release/usr/local/etc && \
	$(INSTALL_DIR) $(prefix)/release/usr/local/share/{enigma2,keymaps} && \
	ln -s /usr/local/share/keymaps $(prefix)/release/usr/share/keymaps
	$(INSTALL_DIR) $(prefix)/release/usr/share/{fonts,zoneinfo,udhcpc} && \
	$(INSTALL_DIR) $(prefix)/release/var/{etc,opkg} && \
	export CROSS_COMPILE=$(target)- && \
		$(MAKE) install -C @DIR_busybox@ CONFIG_PREFIX=$(prefix)/release && \
	touch $(prefix)/release/var/etc/.firstboot && \
	cp -a $(targetprefix)/bin/* $(prefix)/release/bin/ && \
	ln -sf /bin/showiframe $(prefix)/release/usr/bin/showiframe && \
	cp -dp $(targetprefix)/usr/bin/sdparm $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/init $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/usr/bin/killall5 $(prefix)/release/usr/bin/ && \
	cp -dp $(targetprefix)/sbin/portmap $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/mke2fs $(prefix)/release/sbin/ && \
	ln -sf /sbin/mke2fs $(prefix)/release/sbin/mkfs.ext2 && \
	ln -sf /sbin/mke2fs $(prefix)/release/sbin/mkfs.ext3 && \
	ln -sf /sbin/mke2fs $(prefix)/release/sbin/mkfs.ext4 && \
	ln -sf /sbin/mke2fs $(prefix)/release/sbin/mkfs.ext4dev && \
	cp -dp $(targetprefix)/sbin/fsck $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/e2fsck $(prefix)/release/sbin/ && \
	ln -sf /sbin/e2fsck $(prefix)/release/sbin/fsck.ext2 && \
	ln -sf /sbin/e2fsck $(prefix)/release/sbin/fsck.ext3 && \
	ln -sf /sbin/e2fsck $(prefix)/release/sbin/fsck.ext4 && \
	ln -sf /sbin/e2fsck $(prefix)/release/sbin/fsck.ext4dev && \
	cp -dp $(targetprefix)/sbin/jfs_fsck $(prefix)/release/sbin/ && \
	ln -sf /sbin/jfs_fsck $(prefix)/release/sbin/fsck.jfs && \
	cp -dp $(targetprefix)/sbin/jfs_mkfs $(prefix)/release/sbin/ && \
	ln -sf /sbin/jfs_mkfs $(prefix)/release/sbin/mkfs.jfs && \
	cp -dp $(targetprefix)/sbin/jfs_tune $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/fsck.nfs $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/sfdisk $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/sbin/tune2fs $(prefix)/release/sbin/ && \
	cp -dp $(targetprefix)/etc/init.d/portmap $(prefix)/release/etc/init.d/ && \
	cp -dp $(buildprefix)/root/etc/init.d/udhcpc $(prefix)/release/etc/init.d/ && \
	cp -dp $(targetprefix)/sbin/MAKEDEV $(prefix)/release/sbin/MAKEDEV && \
	cp -f $(buildprefix)/root/release/makedev $(prefix)/release/etc/init.d/ && \
	cp -dp $(targetprefix)/usr/bin/grep $(prefix)/release/bin/ && \
	cp -dp $(targetprefix)/usr/bin/egrep $(prefix)/release/bin/ && \
	cp $(targetprefix)/boot/uImage $(prefix)/release/boot/ && \
	cp -a $(targetprefix)/dev/* $(prefix)/release/dev/ && \
	cp -dp $(targetprefix)/etc/fstab $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/group $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/host.conf $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/hostname $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/hosts $(prefix)/release/etc/ && \
	cp $(buildprefix)/root/etc/inetd.conf $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/inittab $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/localtime $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/mtab $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/passwd $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/profile $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/protocols $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/resolv.conf $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/services $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/shells $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/shells.conf $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/vsftpd.conf $(prefix)/release/etc/ && \
	cp $(buildprefix)/root/etc/image-version $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/timezone.xml $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/vdstandby.cfg $(prefix)/release/etc/ && \
	cp -dp $(targetprefix)/etc/network/interfaces $(prefix)/release/etc/network/ && \
	cp -dp $(targetprefix)/etc/network/options $(prefix)/release/etc/network/ && \
	cp -dp $(targetprefix)/etc/init.d/umountfs $(prefix)/release/etc/init.d/ && \
	cp -dp $(targetprefix)/etc/init.d/sendsigs $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/reboot $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/etc/tuxbox/satellites.xml $(prefix)/release/etc/tuxbox/ && \
	cp $(buildprefix)/root/etc/tuxbox/cables.xml $(prefix)/release/etc/tuxbox/ && \
	cp $(buildprefix)/root/etc/tuxbox/terrestrial.xml $(prefix)/release/etc/tuxbox/ && \
	cp $(buildprefix)/root/etc/tuxbox/tuxtxt2.conf $(prefix)/release/usr/tuxtxt/ && \
	cp -aR $(buildprefix)/root/usr/share/udhcpc/* $(prefix)/release/usr/share/udhcpc/ && \
	cp -aR $(buildprefix)/root/usr/share/zoneinfo/* $(prefix)/release/usr/share/zoneinfo/ && \
	ln -sf /etc/timezone.xml $(prefix)/release/etc/tuxbox/timezone.xml && \
	echo "576i50" > $(prefix)/release/etc/videomode && \
	cp -R $(targetprefix)/etc/fonts/* $(prefix)/release/etc/fonts/ && \
	cp $(buildprefix)/root/release/rcS$(if $(HL101),_$(HL101)) $(prefix)/release/etc/init.d/rcS && \
	chmod 755 $(prefix)/release/etc/init.d/rcS && \
	cp $(buildprefix)/root/release/mountvirtfs $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/mme_check $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/mountall $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/hostname $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/vsftpd $(prefix)/release/etc/init.d/ && \
	cp -dp $(targetprefix)/usr/bin/vsftpd $(prefix)/release/usr/bin/ && \
	cp $(buildprefix)/root/release/bootclean.sh $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/network $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/release/networking $(prefix)/release/etc/init.d/ && \
	cp $(buildprefix)/root/bootscreen/bootlogo.mvi $(prefix)/release/boot/ && \
	cp $(buildprefix)/root/bin/autologin $(prefix)/release/bin/ && \
	cp $(buildprefix)/root/bin/vdstandby $(prefix)/release/bin/ && \
	cp -p $(targetprefix)/usr/bin/killall $(prefix)/release/usr/bin/ && \
	cp -p $(targetprefix)/usr/bin/opkg-cl $(prefix)/release/usr/bin/opkg && \
	cp -p $(targetprefix)/usr/bin/python $(prefix)/release/usr/bin/ && \
	cp -p $(targetprefix)/usr/bin/ffmpeg $(prefix)/release/sbin/ && \
	cp -p $(buildprefix)/module-init-tools-3.16/build/modprobe $(prefix)/release/sbin/ && \
	chmod 755 $(prefix)/release/sbin/modprobe && \
	cp -p $(targetprefix)/usr/sbin/ethtool $(prefix)/release/usr/sbin/
if STM24
	cp -dp $(targetprefix)/sbin/mkfs $(prefix)/release/sbin/
endif

# select initmodules
#	cd $(DIR_init_scripts) && \
#	mv initmodules$(if $(HL101),_$(HL101)) initmodules

#
# Player
#
if ENABLE_PLAYER191
	cd $(targetprefix)/lib/modules/$(KERNELVERSION)/extra && \
	for mod in \
		sound/pseudocard/pseudocard.ko \
		sound/silencegen/silencegen.ko \
		stm/mmelog/mmelog.ko \
		stm/monitor/stm_monitor.ko \
		media/dvb/stm/dvb/stmdvb.ko \
		sound/ksound/ksound.ko \
		sound/kreplay/kreplay.ko \
		sound/kreplay/kreplay-fdma.ko \
		sound/ksound/ktone.ko \
		media/dvb/stm/mpeg2_hard_host_transformer/mpeg2hw.ko \
		media/dvb/stm/backend/player2.ko \
		media/dvb/stm/h264_preprocessor/sth264pp.ko \
		media/dvb/stm/allocator/stmalloc.ko \
		stm/platform/platform.ko \
		stm/platform/p2div64.ko \
		media/sysfs/stm/stmsysfs.ko \
	;do \
		echo `pwd` player2/linux/drivers/$$mod; \
		if [ -e player2/linux/drivers/$$mod ]; then \
			sh4-linux-strip --strip-unneeded $(prefix)/release/lib/modules/`basename $$mod`; \
		else \
			touch $(prefix)/release/lib/modules/`basename $$mod`; \
		fi; \
		echo "."; \
	done
	echo "touched";
endif

#
# modules
#

	find $(prefix)/release/lib/modules/ -name '*.ko' -exec sh4-linux-strip --strip-unneeded {} \;

#
# lib usr/lib
#
	cp -R $(targetprefix)/lib/* $(prefix)/release/lib/
	rm -f $(prefix)/release/lib/*.{a,o,la}
	chmod 755 $(prefix)/release/lib/*
	find $(prefix)/release/lib/ -name '*.so*' -exec sh4-linux-strip --strip-unneeded --remove-section=.comment --remove-section=.note {} \;

	cp -R $(targetprefix)/usr/lib/* $(prefix)/release/usr/lib/
	rm -rf $(prefix)/release/usr/lib/{engines,enigma2,gconv,ldscripts,libxslt-plugins,pkgconfig,python2.6,sigc++-1.2,X11}
	rm -f $(prefix)/release/usr/lib/*.{a,o,la}
	rm -f $(prefix)/release/usr/lib/libbfd.so
	rm -f $(prefix)/release/usr/lib/libopcodes.so
	chmod 755 $(prefix)/release/usr/lib/*
	find $(prefix)/release/usr/lib/ -name '*.so*' -exec sh4-linux-strip --strip-unneeded --remove-section=.comment --remove-section=.note {} \;

#
# fonts
#
	cp $(buildprefix)/root/usr/share/fonts/* $(prefix)/release/usr/share/fonts/
	if [ -e $(targetprefix)/usr/share/fonts/tuxtxt.otb ]; then \
		cp $(targetprefix)/usr/share/fonts/tuxtxt.otb $(prefix)/release/usr/share/fonts/; \
	fi
	if [ -e $(targetprefix)/usr/local/share/fonts/andale.ttf ]; then \
		cp $(targetprefix)/usr/local/share/fonts/andale.ttf $(prefix)/release/usr/share/fonts/; \
	fi
	if [ -e $(targetprefix)/usr/local/share/fonts/DroidSans-Bold.ttf ]; then \
		cp $(targetprefix)/usr/local/share/fonts/DroidSans-Bold.ttf $(prefix)/release/usr/share/fonts/; \
	fi
	ln -s /usr/share/fonts $(prefix)/release/usr/local/share/fonts

#
# enigma2
#
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		cp -f $(targetprefix)/usr/bin/enigma2 $(prefix)/release/usr/local/bin/enigma2;fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		cp -f $(targetprefix)/usr/local/bin/enigma2 $(prefix)/release/usr/local/bin/enigma2;fi
	find $(prefix)/release/usr/local/bin/ -name  enigma2 -exec sh4-linux-strip --strip-unneeded {} \;

	cp -a $(targetprefix)/usr/local/share/enigma2/* $(prefix)/release/usr/local/share/enigma2
	cp $(buildprefix)/root/etc/enigma2/* $(prefix)/release/etc/enigma2
	ln -s /usr/local/share/enigma2 $(prefix)/release/usr/share/enigma2

	$(INSTALL_DIR) $(prefix)/release/usr/lib/enigma2
	cp -a $(targetprefix)/usr/lib/enigma2/* $(prefix)/release/usr/lib/enigma2/
	if test -d $(targetprefix)/usr/local/lib/enigma2; then \
		cp -a $(targetprefix)/usr/local/lib/enigma2/* $(prefix)/release/usr/lib/enigma2/; fi

#
# tuxtxt
#
	if [ -e $(targetprefix)/usr/bin/tuxtxt ]; then \
		cp -p $(targetprefix)/usr/bin/tuxtxt $(prefix)/release/usr/bin/; \
	fi

#
# Delete unnecessary plugins and files
#
	rm -rf $(prefix)/release/lib/autofs
	depmod -b $(prefix)/release $(KERNELVERSION)
	rm -rf $(prefix)/release/usr/lib/enigma2/python/Plugins/DemoPlugins
	rm -rf $(prefix)/release/usr/lib/enigma2/python/Plugins/SystemPlugins/FrontprocessorUpgrade
	rm -rf $(prefix)/release/usr/lib/enigma2/python/Plugins/SystemPlugins/NFIFlash
	rm -rf $(prefix)/release/usr/lib/enigma2/python/Plugins/Extensions/FileManager
	rm -rf $(prefix)/release/usr/lib/enigma2/python/Plugins/Extensions/TuxboxPlugins

	$(INSTALL_DIR) $(prefix)/release/usr/lib/python2.6
	cp -a $(targetprefix)/usr/lib/python2.6/* $(prefix)/release/usr/lib/python2.6/
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/Cheetah-2.4.4-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/elementtree-1.2.6_20050316-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/lxml
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/lxml-2.2.8-py2.6.egg-info
	rm -f $(prefix)/release/usr/lib/python2.6/site-packages/libxml2mod.so
	rm -f $(prefix)/release/usr/lib/python2.6/site-packages/libxsltmod.so
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/OpenSSL/test
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/pyOpenSSL-0.9-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/python_wifi-0.5.0-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/setuptools
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/setuptools-0.6c11-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/zope.interface-4.0.1-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/Twisted-12.1.0-py2.6.egg-info
	rm -rf $(prefix)/release/usr/lib/python2.6/site-packages/twisted/{test,conch,mail,manhole,names,news,trial,words,application,enterprise,flow,lore,pair,runner,scripts,tap,topfiles}
	rm -rf $(prefix)/release/usr/lib/python2.6/{bsddb,compiler,config,ctypes,curses,distutils,email,plat-linux3,test}

#
# Dont remove pyo files, remove pyc instead
#
	find $(prefix)/release/usr/lib/enigma2/ -name '*.pyc' -exec rm -f {} \;
#	find $(prefix)/release/usr/lib/enigma2/ -not -name 'mytest.py' -name '*.py' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/enigma2/ -name '*.a' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/enigma2/ -name '*.o' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/enigma2/ -name '*.la' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/enigma2/ -name '*.so*' -exec sh4-linux-strip --strip-unneeded {} \;

	find $(prefix)/release/usr/lib/python2.6/ -name '*.pyc' -exec rm -f {} \;
#	find $(prefix)/release/usr/lib/python2.6/ -name '*.py' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/python2.6/ -name '*.a' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/python2.6/ -name '*.o' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/python2.6/ -name '*.la' -exec rm -f {} \;
	find $(prefix)/release/usr/lib/python2.6/ -name '*.so*' -exec sh4-linux-strip --strip-unneeded {} \;

#
# hotplug
#
	if [ -e $(targetprefix)/usr/bin/hotplug_e2_helper ]; then \
		cp -dp $(targetprefix)/usr/bin/hotplug_e2_helper $(prefix)/release/sbin/hotplug; \
		cp -dp $(targetprefix)/usr/bin/bdpoll $(prefix)/release/sbin/; \
		rm -f $(prefix)/release/bin/hotplug; \
	else \
		cp -dp $(targetprefix)/bin/hotplug $(prefix)/release/sbin/; \
	fi;

#
# alsa
#
	if [ -e $(targetprefix)/usr/share/alsa ]; then \
		mkdir $(prefix)/release/usr/share/alsa/; \
		mkdir $(prefix)/release/usr/share/alsa/cards/; \
		mkdir $(prefix)/release/usr/share/alsa/pcm/; \
		cp $(targetprefix)/usr/share/alsa/alsa.conf          $(prefix)/release/usr/share/alsa/alsa.conf; \
		cp $(targetprefix)/usr/share/alsa/cards/aliases.conf $(prefix)/release/usr/share/alsa/cards/; \
		cp $(targetprefix)/usr/share/alsa/pcm/default.conf   $(prefix)/release/usr/share/alsa/pcm/; \
		cp $(targetprefix)/usr/share/alsa/pcm/dmix.conf      $(prefix)/release/usr/share/alsa/pcm/; \
	fi

#
# AUTOFS
#
	if [ -d $(prefix)/release/usr/lib/autofs ]; then \
		cp -f $(targetprefix)/usr/sbin/automount $(prefix)/release/usr/sbin/; \
		cp -f $(buildprefix)/root/release/auto.hotplug $(prefix)/release/etc/; \
		cp -f $(buildprefix)/root/release/auto.network $(prefix)/release/etc/; \
		cp -f $(buildprefix)/root/release/autofs $(prefix)/release/etc/init.d/; \
	fi

#
# GSTREAMER
#
	if [ -d $(prefix)/release/usr/lib/gstreamer-0.10 ]; then \
		#removed rm \
		rm -rf $(prefix)/release/usr/lib/libgstfft*; \
		rm -rf $(prefix)/release/usr/lib/gstreamer-0.10/*; \
		cp -a $(targetprefix)/usr/bin/gst-launch* $(prefix)/release/usr/bin/; \
		sh4-linux-strip --strip-unneeded $(prefix)/release/usr/bin/gst-launch*; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstalsa.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstapp.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstasf.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstassrender.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstaudioconvert.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstaudioparsers.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstaudioresample.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstautodetect.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstavi.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstcdxaparse.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstcoreelements.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstcoreindexers.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstdecodebin.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstdecodebin2.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstdvbaudiosink.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstdvbvideosink.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstdvdsub.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstflac.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstflv.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstfragmented.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgsticydemux.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstid3demux.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstisomp4.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstmad.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstmatroska.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstmpegaudioparse.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstmpegdemux.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstmpegstream.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstogg.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstplaybin.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstrtmp.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstrtp.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstrtpmanager.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstrtsp.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstsouphttpsrc.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstsubparse.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgsttypefindfunctions.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstudp.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstvcdsrc.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstwavparse.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		if [ -e $(targetprefix)/usr/lib/gstreamer-0.10/libgstffmpeg.so ]; then \
			cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstffmpeg.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
			cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstffmpegscale.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
			cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstpostproc.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		fi; \
		if [ -e $(targetprefix)/usr/lib/gstreamer-0.10/libgstsubsink.so ]; then \
			cp -a $(targetprefix)/usr/lib/gstreamer-0.10/libgstsubsink.so $(prefix)/release/usr/lib/gstreamer-0.10/; \
		fi; \
		sh4-linux-strip --strip-unneeded $(prefix)/release/usr/lib/gstreamer-0.10/*; \
	fi

#
# DIRECTFB
#
	if [ -d $(prefix)/release/usr/lib/directfb-1.4-5 ]; then \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/gfxdrivers/*.{a,o,la}; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/inputdrivers/*; \
		cp -a $(targetprefix)/usr/lib/directfb-1.4-5/inputdrivers/libdirectfb_enigma2remote.so $(prefix)/release/usr/lib/directfb-1.4-5/inputdrivers/; \
		cp -a $(targetprefix)/usr/lib/directfb-1.4-5/inputdrivers/libdirectfb_linux_input.so $(prefix)/release/usr/lib/directfb-1.4-5/inputdrivers/; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/systems/*.{a,o,la}; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/systems/libdirectfb_dummy.so; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/systems/libdirectfb_fbdev.so; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/wm/*.{a,o,la}; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/interfaces/IDirectFBFont/*.{a,o,la}; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/interfaces/IDirectFBImageProvider/*.{a,o,la}; \
		rm -rf $(prefix)/release/usr/lib/directfb-1.4-5/interfaces/IDirectFBVideoProvider/*.{a,o,la}; \
	fi
	if [ -d $(prefix)/release/usr/lib/icu ]; then \
		rm -rf $(prefix)/release/usr/lib/icu; \
	fi
	if [ -d $(prefix)/release/usr/lib/glib-2.0 ]; then \
		rm -rf $(prefix)/release/usr/lib/glib-2.0; \
	fi
	if [ -d $(prefix)/release/usr/lib/gio ]; then \
		rm -rf $(prefix)/release/usr/lib/gio; \
	fi
	if [ -d $(prefix)/release/usr/lib/enchant ]; then \
		rm -rf $(prefix)/release/usr/lib/enchant; \
	fi

#
# GRAPHLCD
#
	if [ -e $(prefix)/release/usr/lib/libglcddrivers.so ]; then \
		cp -f $(targetprefix)/etc/graphlcd.conf $(prefix)/release/etc/graphlcd.conf; \
	fi

#
# The main target depends on the model.
# IMPORTANT: it is assumed that only one variable is set. Otherwise the target name won't be resolved.
#
$(DEPDIR)/min-release $(DEPDIR)/std-release $(DEPDIR)/max-release $(DEPDIR)/release: \
$(DEPDIR)/%release: release_base release_$(TF7700)$(HL101)$(VIP1_V2)$(VIP2_V1)$(UFS910)$(UFS912)$(UFS913)$(SPARK)$(SPARK7162)$(UFS922)$(OCTAGON1008)$(FORTIS_HDBOX)$(ATEVIO7500)$(HS7810A)$(HS7110)$(WHITEBOX)$(CUBEREVO)$(CUBEREVO_MINI)$(CUBEREVO_MINI2)$(CUBEREVO_MINI_FTA)$(CUBEREVO_250HD)$(CUBEREVO_2000HD)$(CUBEREVO_9500HD)$(HOMECAST5101)$(IPBOX9900)$(IPBOX99)$(IPBOX55)$(ADB_BOX)
	touch $@

#
# FOR YOUR OWN CHANGES use these folder in cdk/own_build/enigma2
#
	cp -RP $(buildprefix)/own_build/enigma2/* $(prefix)/release/

#
# release-clean
#
release-clean:
	rm -f $(DEPDIR)/release
