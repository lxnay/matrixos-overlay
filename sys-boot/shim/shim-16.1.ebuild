# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm secureboot

FEDORA_PR=5
DESCRIPTION="Fedora's signed UEFI shim"
HOMEPAGE="https://src.fedoraproject.org/rpms/shim"
SRC_URI="amd64? ( https://kojipkgs.fedoraproject.org/packages/shim/${PV}/${FEDORA_PR}/x86_64/shim-x64-${PV}-${FEDORA_PR}.x86_64.rpm
				https://kojipkgs.fedoraproject.org/packages/shim/${PV}/${FEDORA_PR}/x86_64/shim-ia32-${PV}-${FEDORA_PR}.x86_64.rpm )
		x86? ( https://kojipkgs.fedoraproject.org/packages/shim/${PV}/${FEDORA_PR}/x86_64/shim-x64-${PV}-${FEDORA_PR}.x86_64.rpm
				https://kojipkgs.fedoraproject.org/packages/shim/${PV}/${FEDORA_PR}/x86_64/shim-ia32-${PV}-${FEDORA_PR}.x86_64.rpm )
		arm64? ( https://kojipkgs.fedoraproject.org/packages/shim/${PV}/${FEDORA_PR}/aarch64/shim-aa64-${PV}-${FEDORA_PR}.aarch64.rpm )"
S="${WORKDIR}/usr/lib/efi/shim/${PV}-${FEDORA_PR}/EFI"

DEPEND=">=sys-boot/grub-2.14[sbat4]"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

src_install() {
	insinto /usr/share/${PN}
	doins BOOT/BOOT*.EFI
	doins fedora/mm*.efi

	# Shim is already signed with Microsoft keys, but MokManager still needs
	# signing with our key otherwise we have to enrol the Fedora key in Mok list
	secureboot_auto_sign --in-place
}
