# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit udev

DESCRIPTION="Installs a custom kernel configuration into /etc/kernel/config.d"
HOMEPAGE="https://matrixos.org"

SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="+ntfsplus"
RDEPEND="
	ntfsplus? ( sys-fs/ntfs3g[-mount-ntfs] )
"

src_install() {
	# 1. Create the destination directory
	insinto /etc/kernel/config.d
	doins "${FILESDIR}/00-matrixos.config"
	doins "${FILESDIR}/90-virt.config"

	if use ntfsplus; then
		doins "${FILESDIR}/00-matrixos-ntfsplus.config"
		udev_dorules "${FILESDIR}"/*.rules

		dodir /etc/modprobe.d
		insinto /etc/modprobe.d
		newins "${FILESDIR}/ntfsplus-modprobe.d.conf" "ntfsplus.conf"

		dodir /etc/modules-load.d
		insinto /etc/modules-load.d
		newins "${FILESDIR}/ntfsplus-modules-load.d.conf" "ntfsplus.conf"
	fi

	dodir /etc/repart.d
	insinto /etc/repart.d
	doins "${FILESDIR}/50-matrixos-rootfs.conf"

	# Disable hiberation as we do not support encrypted swap
	dodir /etc/systemd/sleep.conf.d
	insinto /etc/systemd/sleep.conf.d
	doins "${FILESDIR}/50-matrixos-no-hibernate.conf"

	# Enable growfs on first boot
	dodir /etc/systemd/system/systemd-growfs-root.service.d
	insinto /etc/systemd/system/systemd-growfs-root.service.d
	doins "${FILESDIR}/systemd-growfs-root.service.d.override.conf"
}
