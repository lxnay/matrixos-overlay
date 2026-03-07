# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="matrixOS flatpak remotes config files"
HOMEPAGE="https://matrixos.org"

SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="motd"

src_install() {
	dodir /etc/flatpak/remotes.d
	insinto /etc/flatpak/remotes.d
	doins "${FILESDIR}/flathub.flatpakrepo"
}
