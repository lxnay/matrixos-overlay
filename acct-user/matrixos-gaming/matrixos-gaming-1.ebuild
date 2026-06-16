# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Setup files for better gaming integration"
KEYWORDS="amd64"
SLOT=0
S="${WORKDIR}"

RDEPEND="
	dev-libs/wayland
	games-util/steam-launcher
	gui-wm/gamescope
"

src_install() {
	dodir /usr/share/wayland-sessions
	insinto /usr/share/wayland-sessions
	doins "${FILESDIR}/steam-big-picture.desktop"
}
