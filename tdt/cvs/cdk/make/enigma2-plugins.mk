#
# Plugins
#
$(DEPDIR)/enigma2-plugins: enigma2_openwebif enigma2_networkbrowser

#
# enigma2-openwebif
#

DESCRIPTION_enigma2_openwebif = "open webinteface plugin for enigma2 by openpli team"
RDEPENDS_enigma2_openwebif = libpng12 libjpeg6b

$(DEPDIR)/enigma2_openwebif.do_prepare: bootstrap python pythoncheetah @DEPENDS_enigma2_openwebif@
	@PREPARE_enigma2_openwebif@
	touch $@

$(DEPDIR)/min-enigma2_openwebif $(DEPDIR)/std-enigma2_openwebif $(DEPDIR)/max-enigma2_openwebif \
$(DEPDIR)/enigma2_openwebif: \
$(DEPDIR)/%enigma2_openwebif: $(DEPDIR)/enigma2_openwebif.do_prepare
	$(start_build)
	cd @DIR_enigma2_openwebif@ && \
		$(BUILDENV) \
		mkdir -p $(PKDIR)/usr/lib/enigma2/python/Plugins/Extensions && \
		cp -a plugin $(PKDIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif
	$(extra_build)
#	@DISTCLEANUP_enigma2_openwebif@
	@[ "x$*" = "x" ] && touch $@ || true

#
# enigma2-networkbrowser
#

DESCRIPTION_enigma2_networkbrowser = "networkbrowser plugin for enigma2"

$(DEPDIR)/enigma2_networkbrowser.do_prepare: @DEPENDS_enigma2_networkbrowser@
	@PREPARE_enigma2_networkbrowser@
	touch $@

$(DEPDIR)/min-enigma2_networkbrowser $(DEPDIR)/std-enigma2_networkbrowser $(DEPDIR)/max-enigma2_networkbrowser \
$(DEPDIR)/enigma2_networkbrowser: \
$(DEPDIR)/%enigma2_networkbrowser: $(DEPDIR)/enigma2_networkbrowser.do_prepare
	$(start_build)
	cd @DIR_enigma2_networkbrowser@/src/lib && \
		$(BUILDENV) \
		sh4-linux-gcc -shared -o netscan.so \
			-I $(targetprefix)/usr/include/python2.6 \
			-include Python.h \
			errors.h \
			list.c \
			list.h \
			main.c \
			nbtscan.c \
			nbtscan.h \
			range.c \
			range.h \
			showmount.c \
			showmount.h \
			smb.h \
			smbinfo.c \
			smbinfo.h \
			statusq.c \
			statusq.h \
			time_compat.h
	cd @DIR_enigma2_networkbrowser@ && \
		mkdir -p $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser && \
		cp -a po $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a meta $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a src/* $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a src/lib/netscan.so $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		rm -rf $(PKDIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/lib
	$(extra_build)
#	@DISTCLEANUP_enigma2_networkbrowser@
	[ "x$*" = "x" ] && touch $@ || true

$(DEPDIR)/%-openpli:
	$(call git_fetch_prepare,$*_openpli,git://github.com/E2OpenPlugins/e2openplugin-$*.git)
	$(eval FILES_$*_openpli += /usr/lib/enigma2/python/Plugins)
	$(start_build)
	$(get_git_version)
	cd $(DIR_$*_openpli) && \
		$(python) setup.py install --root=$(PKDIR) --install-lib=/usr/lib/enigma2/python/Plugins
	$(remove_pyo)
	$(extra_build)
	touch $@

DESCRIPTION_NewsReader_openpli = RSS reader
DESCRIPTION_AddStreamUrl_openpli = Add a stream url to your channellist

openpli_plugin_list = \
AddStreamUrl \
NewsReader

openpli-plugins: $(addprefix $(DEPDIR)/,$(addsuffix -openpli,$(openpli_plugin_list)))