# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module optfeature verify-sig

DESCRIPTION="matrixOS management toolking"
HOMEPAGE="https://github.com/lxnay/matrixos.git"
SRC_URI="https://github.com/lxnay/matrixos/archive/refs/tags/${P}.tar.gz
	http://data.matrixos.org/vector/${P}-vendor.tar.xz"
S="${WORKDIR}/matrixos-${P}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
BDEPEND=""


src_unpack() {
	default
	# TODO:
	# - add CI pipeline runner that creates the vendor pkg.
	# - automate the process of creating new releases
	# - do not hardcode matrixos.clean
	mv "${WORKDIR}/matrixos.clean/vendor" "${S}" || die
}

src_compile() {
	mkdir "${S}/bin" || die
	ego build -ldflags "-X main.Version=${PV}" -o bin/ ./...
}

src_install() {
	exeinto /usr/bin
	doexe "${S}/bin/vector"
}
