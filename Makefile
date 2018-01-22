.PHONY: run pkgs zededa-container help

all: help

help:
	@echo zenbuild: LinuxKit-based Xen images composer
	@echo
	@echo amd64 targets:
	@echo "   'make supermicro.iso' builds a bootable ISO"
	@echo "   'make supermicro.img' builds a bootable raw disk image"
	@echo "   'make fallback.img'   builds an image with the fallback"
	@echo "                         bootloader"
	@echo

pkgs:
	make -C pkg

run:
	qemu-system-x86_64 --bios ./bios/OVMF.fd -m 4096 -cpu SandyBridge -serial mon:stdio -hda supermicro.img -redir tcp:2222::22

run-fallback:
	qemu-system-x86_64 --bios ./bios/OVMF.fd -m 4096 -cpu SandyBridge -serial mon:stdio -hda fallback.img -redir tcp:2222::22

zededa-container/Dockerfile: pkgs parse-pkgs.sh zededa-container/Dockerfile.template
	./parse-pkgs.sh zededa-container/Dockerfile.template > zededa-container/Dockerfile

zededa-container: zededa-container/Dockerfile
	linuxkit pkg build --disable-content-trust zededa-container/

images/%.yml: parse-pkgs.sh images/%.yml.in FORCE
	./parse-pkgs.sh $@.in > $@

supermicro.iso: zededa-container images/supermicro-iso.yml
	./makeiso.sh images/supermicro-iso.yml supermicro.iso

supermicro.img: zededa-container images/supermicro-img.yml
	./makeraw.sh images/supermicro-img.yml supermicro.img

rootfs.img: zededa-container images/fallback.yml
	./makerootfs.sh images/fallback.yml rootfs.img

fallback.img: rootfs.img
	tar c rootfs.img | ./makeflash.sh -C $@

.PHONY: FORCE
FORCE:
