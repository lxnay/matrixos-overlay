# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="matrixOS dconf base config for GNOME"
HOMEPAGE="https://matrixos.org"

SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_install() {
	dodir /etc/dconf/profile
	insinto /etc/dconf/profile
	newins "${FILESDIR}/dconf-profile-user" "user"
}
