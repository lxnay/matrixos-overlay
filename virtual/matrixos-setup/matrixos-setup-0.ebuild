# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to pull in all matrixOS provisioning packages"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	>=acct-user/matrixos-live-${PV}
	>=acct-user/matrixos-live-home-${PV}
"
