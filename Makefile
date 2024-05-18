MODULES = quic quic_unit_test quic_sample_test
KERNEL_EXTRA = /lib/modules/$(shell uname -r)/extra
KERNEL_BUILD = /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KERNEL_BUILD) M=$(CURDIR)/net/quic modules \
		ROOTDIR=$(CURDIR) CONFIG_IP_QUIC=m CONFIG_IP_QUIC_TEST=m

install: install_headers install_modules depmod

uninstall: uninstall_modules uninstall_headers depmod

clean:
	$(MAKE) -C $(KERNEL_BUILD) M=$(CURDIR)/net/quic clean

install_headers:
	install -m 644 include/uapi/linux/quic.h /usr/include/linux

install_modules: all $(KERNEL_EXTRA)
	$(foreach module, $(MODULES), \
		! [ -f net/quic/$(module).ko ] || \
		install -m 644 net/quic/$(module).ko $(KERNEL_EXTRA);)

uninstall_modules:
	$(foreach module, $(MODULES), \
		! [ -d /sys/module/$(module) ] || rmmod $(module); \
		rm -f $(KERNEL_EXTRA)/$(module).ko;)

uninstall_headers:
	rm -f /usr/include/linux/quic.h

$(KERNEL_EXTRA):
	mkdir -p $@

depmod:
	depmod -a
