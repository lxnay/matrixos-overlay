# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build toolchain-funcs verify-sig

BASE_P=linux-${PV%.*}
PATCH_PV=${PV%_p*}
PATCHSET=linux-gentoo-patches-6.18.4
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to https://github.com/projg2/fedora-kernel-config-for-gentoo
CONFIG_VER=6.19.2-gentoo
GENTOO_CONFIG_VER=g18
SHA256SUM_DATE=20260219

DESCRIPTION="Linux kernel built for matrixOS with Gentoo patches"
HOMEPAGE="
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PATCH_PV}.xz
	https://dev.gentoo.org/~mgorny/dist/linux/${PATCHSET}.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	verify-sig? (
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/sha256sums.asc
			-> linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc
	)
	amd64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-x86_64-fedora.config
			-> kernel-x86_64-fedora.config.${CONFIG_VER}
	)
	arm64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-aarch64-fedora.config
			-> kernel-aarch64-fedora.config.${CONFIG_VER}
	)
	ppc64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-ppc64le-fedora.config
			-> kernel-ppc64le-fedora.config.${CONFIG_VER}
	)
	riscv? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-riscv64-fedora.config
			-> kernel-riscv64-fedora.config.${CONFIG_VER}
	)
	x86? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-i686-fedora.config
			-> kernel-i686-fedora.config.${CONFIG_VER}
	)
"
S=${WORKDIR}/${BASE_P}

KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="debug experimental hardened"
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
	>=virtual/dist-kernel-${PV}
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
	for patch in "${WORKDIR}/${PATCHSET}"/*.patch; do
		eapply "${patch}"
		# non-experimental patches always finish with Gentoo Kconfig
		# when ! use experimental, stop applying after it
		if [[ ${patch} == *Add-Gentoo-Linux-support-config-settings* ]] &&
			! use experimental
		then
			break
		fi
	done

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
			cp "${DISTDIR}/kernel-x86_64-fedora.config.${CONFIG_VER}" .config || die
			;;
		arm64)
			cp "${DISTDIR}/kernel-aarch64-fedora.config.${CONFIG_VER}" .config || die
			biendian=true
			;;
		ppc)
			# assume powermac/powerbook defconfig
			# we still package.use.force savedconfig
			cp "${WORKDIR}/${BASE_P}/arch/powerpc/configs/pmac32_defconfig" .config || die
			;;
		ppc64)
			cp "${DISTDIR}/kernel-ppc64le-fedora.config.${CONFIG_VER}" .config || die
			biendian=true
			;;
		riscv)
			cp "${DISTDIR}/kernel-riscv64-fedora.config.${CONFIG_VER}" .config || die
			;;
		x86)
			cp "${DISTDIR}/kernel-i686-fedora.config.${CONFIG_VER}" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	local myversion="${MATRIXOS_MYVERSION}"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

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
IUSE="${IUSE} ostree +dracut-userconf"
MATRIXOS_COMMON_DEPEND="
	~sys-kernel/matrixos-kconfig-${PV}:0
	ostree? ( initramfs? ( !generic-uki? (
		>=sys-kernel/linux-firmware-20251124
		app-crypt/tpm2-tools
		app-misc/jq
		net-fs/nfs-utils
		net-fs/cifs-utils
		net-misc/dhcp
		net-misc/networkmanager
		sys-block/nbd
		sys-apps/nvme-cli
		sys-apps/rng-tools
		sys-apps/systemd[cryptsetup]
		sys-boot/plymouth
		sys-fs/btrfs-progs
		sys-fs/dmraid
		sys-fs/mdadm
		sys-fs/multipath-tools
		dev-util/ostree[dracut]
	) ) )
"

DEPEND="${DEPEND}
	${MATRIXOS_COMMON_DEPEND}
"
BDEPEND="
	${BDEPEND}
	${MATRIXOS_COMMON_DEPEND}
"
RDEPEND="${RDEPEND}
	~sys-kernel/matrixos-kconfig-${PV}:0
"
MATRIXOS_MYVERSION="-${PN%%-*}"

_matrixos_src_prepare() {
	eapply "${FILESDIR}"/ntfsplus-v8-patches-6.19/*.patch
}

src_install() {
	kernel-build_src_install || die

	local modulesdir="${ED}/lib/modules/${KV_FULL}"
	local image="${modulesdir}/vmlinuz"
	local initramfs="${modulesdir}/initramfs"

	if use ostree && use initramfs && ! use generic-uki; then
		elog "OSTree and Initramfs support enabled (generic-uki disabled)"
		elog "Building a separate initramfs at ${initramfs}..."
	else
		return 0
	fi

	# De-fuck vmlinuz, it must be a file not a symlink in order to get
	# ostree working throughout.
	if [[ -L "${image}" ]]; then
		elog "${image} is a symlink, which is terrible for ostree. Fixing..."
		local actual_image=$(realpath "${image}")
		rm "${image}" || die
		elog "Hardlinking ${actual_image} to ${image}"
		ln "${actual_image}" "${image}" || die
	fi

	local dracut_args=()
	if ! use dracut-userconf; then
		local dracutconf="${T}"/empty-file
		local dracutconfdir="${T}"/empty-directory
		# NB: if you pass a path that does not exist or is not a regular
		# file/directory, dracut will silently ignore it and use the default
		# https://github.com/dracutdevs/dracut/issues/1136
		> "${dracutconf}" || die
		mkdir -p "${dracutconfdir}" || die

		dracut_args+=(
			--conf "${dracutconf}"
			--confdir "${dracutconfdir}"
		)
	fi

	local dracut_modules=(
		base bash btrfs cifs crypt crypt-gpg crypt-loop dbus dbus-daemon
		dm dmraid dmsquash-live dracut-systemd drm fido2 i18n fs-lib kernel-modules
		kernel-network-modules kernel-modules-extra lunmask lvm nbd
		mdraid modsign network network-manager nfs nvdimm nvmf ostree
		pkcs11 plymouth qemu qemu-net resume rngd rootfs-block shutdown
		systemd systemd-ac-power systemd-ask-password systemd-cryptsetup
		systemd-initrd systemd-integritysetup systemd-repart
		systemd-sysusers systemd-udevd systemd-veritysetup terminfo
		tpm2-tss udev-rules uefi-lib usrmount virtiofs
	)
	local _uki_specific_ignored_dracut_modules=(
		systemd-pcrphase pcsc
	)
	local dracut_drivers=(
		virtio-gpu amdgpu xe i915 nfp
	)
	# nvidia might go out of sync if we add it? Also these
	# drivers can add huge firmware files
	local dracut_omit_drivers=(
		nvidia
		# amdgpu i915 nfp nouveau nvidia xe
	)
	dracut_args+=(
		--kernel-image="${image}"
		--kmoddir="${modulesdir}"
		--kver="${KV_FULL}"
		--fwdir="/lib/firmware"
		--verbose
		--compress="zstd -19"
		--no-hostonly
		--no-hostonly-cmdline
		--no-hostonly-i18n
		--no-machineid
		--nostrip
		--no-uefi
		--early-microcode
		--reproducible
		--ro-mnt
		--modules "${dracut_modules[*]}"
		--add-drivers "${dracut_drivers[*]}"
		--omit-drivers "${dracut_omit_drivers[*]}"
	)
	addpredict /etc/ld.so.cache~
	dracut "${dracut_args[@]}" "${initramfs}" ||
		die "Failed to generate initramfs"
}
