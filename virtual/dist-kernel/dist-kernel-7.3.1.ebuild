# Copyright 2021-2025 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"
SLOT="0/${PVR}"
KEYWORDS="amd64"

RDEPEND="
	~sys-kernel/matrixos-kernel-${PV}
	~sys-kernel/matrixos-initramfs-${PV}
"
