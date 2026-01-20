# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to pull in all matrixOS development packages"
SLOT="0"
KEYWORDS="amd64"

# From matrixos-overlay:
# >=app-crypt/sbctl-0.18
# sys-boot/grub
# sys-boot/plymouth
# >=sys-boot/shim-16.1

RDEPEND="
	app-arch/zstd
	>=app-crypt/sbctl-0.18
	app-eselect/eselect-repository
	app-portage/gentoolkit
	dev-vcs/git
	dev-util/ostree
	sys-apps/gptfdisk
	sys-boot/grub
	sys-boot/matrixos-artwork-grub
	sys-boot/matrixos-artwork-plymouth
	sys-boot/plymouth
	>=sys-boot/shim-16.1
	sys-fs/btrfs-progs
	sys-fs/compsize
	sys-fs/dosfstools
	sys-fs/xfsdump
	virtual/matrixos-setup
"
