# Copyright 2020-2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit kernel-build toolchain-funcs verify-sig

PATCH_PV=${PV%_p*}

DESCRIPTION="Linux kernel built for matrixOS with Gentoo patches"
HOMEPAGE="
	https://github.com/lxnay/matrixos-kernel
	https://www.kernel.org/
"
SRC_URI+="
    https://github.com/lxnay/matrixos-kernel/archive/refs/tags/matrixos-${PV}.tar.gz
"
S="${WORKDIR}/${PN}-matrixos-${PV}"

KEYWORDS="amd64"
IUSE="debug ostree"

MATRIXOS_COMMON_DEPEND="
	~sys-kernel/matrixos-kconfig-${PV}:0
"
DEPEND="${DEPEND} ${MATRIXOS_COMMON_DEPEND}"
RDEPEND="
	!sys-kernel/gentoo-kernel-bin:${SLOT}
    ${MATRIXOS_COMMON_DEPEND}
"
BDEPEND="
	debug? ( dev-util/pahole )
    ${MATRIXOS_COMMON_DEPEND}
"
PDEPEND="
    ~sys-kernel/matrixos-initramfs-${PV}
	=virtual/dist-kernel-${PV}
    ${MATRIXOS_COMMON_DEPEND}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

src_unpack() {
	default
}

src_prepare() {
	default

	# add matrixOS patchset version
	local extraversion=${PV#${PATCH_PV}}
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion/_/-}:" Makefile || die

	# prepare the default config
	case ${ARCH} in
		amd64)
			cp "${S}/matrixos/configs/amd64.config" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	local merge_configs=()
	kernel-build_merge_configs "${merge_configs[@]}"
}

src_install() {
	kernel-build_src_install || die

	local modulesdir="${ED}/lib/modules/${KV_FULL}"
	local image="${modulesdir}/vmlinuz"

	# De-fuck vmlinuz, it must be a file not a symlink in order to get
	# ostree working throughout.
	if use ostree; then
		if [[ -L "${image}" ]]; then
			elog "${image} is a symlink, which is terrible for ostree. Fixing..."
			local actual_image=$(realpath "${image}")
			rm "${image}" || die
			elog "Hardlinking ${actual_image} to ${image}"
			ln "${actual_image}" "${image}" || die
		fi
	fi
}
