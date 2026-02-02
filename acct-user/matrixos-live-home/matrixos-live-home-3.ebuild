# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit tmpfiles

DESCRIPTION="Installs setup files for a /home for LiveUSB images"
HOMEPAGE="https://matrixos.org"

SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="motd"

LIVE_HOME_CONF=matrixos-live-home.conf

src_install() {
	# Install into /etc/tmpfiles.d so that it can be removed
	# during setupos.sh.
	(
		insopts -m 0644
		insinto /etc/tmpfiles.d
		newins "${FILESDIR}/tmpfiles.d-0.conf" "${LIVE_HOME_CONF}"
	)

	if use motd; then
		(
			insopts -m 0755
			insinto /etc/profile.d
			newins "${FILESDIR}/motd-profile.d.sh" "matrixos-motd.sh"
		)
	fi

	dodir /etc/sudoers.d
	insinto /etc/sudoers.d
	doins "${FILESDIR}/sudoers.d/50_matrixos"

	dodir /etc/flatpak/remotes.d
	insinto /etc/flatpak/remotes.d
	doins "${FILESDIR}/flathub.flatpakrepo"
}

pkg_postinst() {
	tmpfiles_process "${LIVE_HOME_CONF}"
}
