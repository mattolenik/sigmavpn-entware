HOST = mipsel-linux
export PATH := $(realpath asuswrt-merlin/tools/brcm/hndtools-mipsel-linux/bin):$(PATH)

export AR    = $(HOST)-ar
export AS    = $(HOST)-as
export CC    = $(HOST)-gcc
export CPP   = $(HOST)-cpp
export GCC   = $(HOST)-gcc
export LD    = $(HOST)-ld
export NM    = $(HOST)-nm
export STRIP = $(HOST)-strip

BUILD     = $(realpath .)/build/
BUILDROOT = $(BUILD)/root
DISTROOT  = $(BUILD)/dist
OPT       = $(DISTROOT)/opt

all: directories configure sodium vpn ipk

directories:
	mkdir -p $(BUILDROOT)
	mkdir -p $(DISTROOT)

configure:
	cd libsodium && ./autogen.sh && ./configure --prefix=$(BUILDROOT) --host=$(HOST) --disable-ssp

sodium:
	make -C libsodium && make -C libsodium install

vpn:
	INSTALLDIR=$(BUILDROOT) SODIUMDIR=$(BUILDROOT) make -C sigmavpn && INSTALLDIR=$(BUILDROOT) make -C sigmavpn install

ipk:
	mkdir -p $(OPT)
	cp -aR ipk-src/* $(DISTROOT)
	cp -aR $(BUILDROOT)/bin $(OPT)
	sed s/\_DATE_/`date -u +%m%d%Y`/ $(DISTROOT)/CONTROL/control.src > $(DISTROOT)/CONTROL/control
	fakeroot chown -R root:root build/dist
	fakeroot ./ipkg-build $(DISTROOT) $(BUILD)

clean:
	rm -rf $(BUILD)
	make -C libsodium clean
	make -C sigmavpn clean
