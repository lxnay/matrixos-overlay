# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="matrixOS management toolking"
HOMEPAGE="https://github.com/lxnay/matrixos.git"
SRC_URI="https://github.com/lxnay/matrixos/archive/refs/tags/${P}.tar.gz
	https://github.com/lxnay/matrixos/releases/download/${P}/matrixos-${P}-vendor.tar.gz"
S="${WORKDIR}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
BDEPEND=""


src_unpack() {
	default
}

src_compile() {
	mkdir "${T}/bin" || die
	ego build -ldflags "-X main.Version=${PV}" -o "${T}"/bin/ ./...
}

src_install() {
	exeinto /usr/bin
	doexe "${T}/bin/vector"

	dodir /etc/matrixos/conf
	insinto /etc/matrixos/conf
	doins "${S}"/conf/*.conf

	dodir /etc/matrixos/conf/matrixos.conf.d
	insinto /etc/matrixos/conf/matrixos.conf.d
	echo "# Use this directory for adding overrides on top of matrixos.conf" > "${T}"/README
	doins "${T}/README"

	mv "${S}/conf/matrixos.conf" "${S}/conf/matrixos.conf.example" || die
	rm -rf "${S}/vendor"

	dodir /usr/lib/matrixos
	insinto /usr/lib/matrixos
	cd "${S}"
	doins -r .
}
