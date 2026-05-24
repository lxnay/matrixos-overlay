# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build toolchain-funcs verify-sig

BASE_P=linux-${PV%.*}
PATCH_PV=${PV%_p*}
PATCHSET=linux-gentoo-patches-${PV}
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to git.gentoo.org:fork/fedora/kernel
CONFIG_VER=7.0.8-gentoo
GENTOO_CONFIG_P=gentoo-kernel-config-g18
SHA256SUM_DATE=20260517

DESCRIPTION="Linux kernel built for matrixOS with Gentoo patches"
HOMEPAGE="
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PATCH_PV}.xz
	https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/$(ver_cut 1-2)/${PATCHSET}.tar.xz
	https://gitweb.gentoo.org/proj/dist-kernel/gentoo-kernel-config.git/snapshot/${GENTOO_CONFIG_P}.tar.bz2
	https://gitweb.gentoo.org/fork/fedora/kernel.git/snapshot/kernel-${CONFIG_VER}.tar.bz2
	verify-sig? (
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/sha256sums.asc
			-> linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc
	)
"
S=${WORKDIR}/${BASE_P}

KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="debug hardened"
REQUIRED_USE="
	arm? ( savedconfig )
	hppa? ( savedconfig )
	sparc? ( savedconfig )
"

RDEPEND="
	!sys-kernel/gentoo-kernel-bin:${SLOT}
"
BDEPEND="
	debug? ( dev-util/pahole )
	verify-sig? ( >=sec-keys/openpgp-keys-kernel-20250702 )
"
PDEPEND="
	=virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kernel.org.asc

src_unpack() {
	if use verify-sig; then
		cd "${DISTDIR}" || die
		verify-sig_verify_signed_checksums \
			"linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc" \
			sha256 "${BASE_P}.tar.xz patch-${PATCH_PV}.xz"
		cd "${WORKDIR}" || die
	fi

	default
}

src_prepare() {
	_matrixos_src_prepare

	local patch
	eapply "${WORKDIR}/patch-${PATCH_PV}"
	eapply "${WORKDIR}/${PATCHSET}"

	default

	# add Gentoo patchset version
	local extraversion=${PV#${PATCH_PV}}
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion/_/-}:" Makefile || die

	local biendian=false

	# prepare the default config
	case ${ARCH} in
		arm | hppa | loong | sparc)
			> .config || die
		;;
		amd64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-x86_64-fedora.config" .config || die
			;;
		arm64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-aarch64-fedora.config" .config || die
			biendian=true
			;;
		ppc)
			# assume powermac/powerbook defconfig
			# we still package.use.force savedconfig
			cp "arch/powerpc/configs/pmac32_defconfig" .config || die
			;;
		ppc64)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-ppc64le-fedora.config" .config || die
			biendian=true
			;;
		riscv)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-riscv64-fedora.config" .config || die
			;;
		x86)
			cp "${WORKDIR}/kernel-${CONFIG_VER}/kernel-i686-fedora.config" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	local myversion="${MATRIXOS_MYVERSION}"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/${GENTOO_CONFIG_P}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	# this covers ppc64 and aarch64_be only for now
	if [[ ${biendian} == true && $(tc-endian) == big ]]; then
		merge_configs+=( "${dist_conf_path}/big-endian.config" )
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}

# matrixOS requires initramfs to be built and installed into usr/lib/modules/$kver.
# As this is the location supported by ostree.
IUSE="${IUSE} ostree"
MATRIXOS_COMMON_DEPEND="
	~sys-kernel/matrixos-kconfig-${PV}:0
"

DEPEND="${DEPEND}
	${MATRIXOS_COMMON_DEPEND}
"
BDEPEND="
	${BDEPEND}
	${MATRIXOS_COMMON_DEPEND}
"
RDEPEND="${RDEPEND}
	${MATRIXOS_COMMON_DEPEND}
"
PDEPEND="${PDEPEND}
	~sys-kernel/matrixos-initramfs-${PV}
"
MATRIXOS_MYVERSION="-${PN%%-*}"

_matrixos_src_prepare() {
	eapply "${FILESDIR}"/ntfsplus-v9-patches/*.patch
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
