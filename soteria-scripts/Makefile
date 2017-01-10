include $(TOPDIR)/rules.mk

PKG_NAME:=soteria-scripts
PKG_VERSION:=0.02
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=base
  CATEGORY:=Base system
  DEPENDS:=+wget
  TITLE:=Soteria scripts
  URL:=
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/
	$(INSTALL_BIN) ./files/libsoteria.sh $(1)/lib/libsoteria.sh
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/hotplug_iface.sh $(1)/etc/hotplug.d/iface/90-soteria.sh
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/soteria.sh $(1)/usr/sbin/soteria.sh
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
