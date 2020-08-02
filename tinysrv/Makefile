include $(TOPDIR)/rules.mk

PKG_NAME:=tinysrv
PKG_VERSION:=2020-07-26
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/jaka/tinysrv.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=57b1fd330fb15cfd29474c5f9dd1894692876ebb
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Tinysrv
  DEPENDS:=+librt
endef

define Package/$(PKG_NAME)/description
  Tinysrv is small single process webserver (with support for TLS) that responds with empty content of proper content-type if requested file is not found.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tinysrv $(1)/usr/bin/tinysrv
endef

$(eval $(call BuildPackage,$(PKG_NAME)))