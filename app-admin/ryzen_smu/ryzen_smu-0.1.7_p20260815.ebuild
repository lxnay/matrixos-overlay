# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Kernel driver for AMD Ryzen's System Management Unit"
HOMEPAGE="https://github.com/amkillam/ryzen_smu"

# Upstream (leogx9r/ryzen_smu, GitLab) is unmaintained since 2023 and the
# released 0.1.5 fails to build against kernel 7.2 (cpuid_eax/cpuid_ebx no
# longer transitively included). This is the actively maintained fork:
#   - MODULE_VERSION 0.1.7, required by RyzenAdj >= 0.19.0
#   - kernel 7.2+ support: "Fix cpuid include on 7.2+ kernels" (2026-08-15)
#   - new CPU families (Strix Point, Strix Halo, Ryzen AI 7/9 HX 370)
# The fork has no release tags, hence the pinned commit below.
COMMIT="d2983668300dd2a598e5a7dc40e71ce0678cc270"
SRC_URI="https://github.com/amkillam/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

S="${WORKDIR}/${PN}-${COMMIT}"

src_compile() {
	local modlist=( ryzen_smu )
	local modargs=( KERNEL_BUILD="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	insinto /usr/lib/modules-load.d
	doins "${FILESDIR}"/ryzen_smu.conf
}
