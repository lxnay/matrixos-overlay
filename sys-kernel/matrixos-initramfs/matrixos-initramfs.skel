# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Linux kernel initramfs built for matrixOS with Gentoo patches"
HOMEPAGE="https://matrixos.org"
SRC_URI=""

KEYWORDS="~amd64"
# matrixOS requires initramfs to be built and installed into usr/lib/modules/$kver.
# As this is the location supported by ostree.
IUSE="${IUSE} ostree +dracut-userconf generic-uki initramfs slim-initramfs"

KV_FULL="${PV}-matrixos"
SLOT="${PV}"
S="${WORKDIR}"

CDEPEND="
	~sys-kernel/matrixos-kconfig-${PV}[slim-initramfs=]
	~sys-kernel/matrixos-kernel-${PV}[ostree=,generic-uki=,initramfs=]
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
RDEPEND="${CDEPEND}"
BDEPEND="${CDEPEND}"
PDEPEND="=virtual/dist-kernel-${PV}"

src_unpack() {
	default
}

src_prepare() {
	default
}

src_install() {
	local modulesdir="${ROOT}/lib/modules/${KV_FULL}"
	local image="${modulesdir}/vmlinuz"

	local srcmodulesdir="${ED}/lib/modules/${KV_FULL}"
	local initramfs="${srcmodulesdir}/initramfs"

	if use ostree && use initramfs && ! use generic-uki; then
		elog "OSTree and Initramfs support enabled (generic-uki disabled)"
		elog "Building ${initramfs}..."
	else
		elog "OSTree and Initramfs support disabled, not building initramfs"
		return 0
	fi

	einfo "Creating ${srcmodulesdir} ..."
	mkdir -p "${srcmodulesdir}" || die

	# For posterity
	dodir /etc/dracut.conf.d

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
	local dracut_omit_drivers=()
	if use slim-initramfs; then
		dracut_omit_drivers+=(
			nvidia
			nvidia_drm
			nvidia_modeset
			nouveau
			# TODO: test and add "amdgpu i915 nfp xe" here.
		)
	fi
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
		--strip
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
