#!/bin/bash
set -e

to_ver="${1}"

if [ -z "${to_ver}" ]; then
	echo "${0} <to_ver>"
	exit 1
fi

packages=(
	sys-kernel/matrixos-kernel
	sys-kernel/matrixos-initramfs
	sys-kernel/matrixos-kconfig
	virtual/dist-kernel
)

for pkg in "${packages[@]}"; do
	pn=$(basename "${pkg}")
	to_ebuild="${pkg}/${pn}-${to_ver}.ebuild"
	git rm "${to_ebuild}"
	other_ebuild=$(find "${pkg}" -name *.ebuild | sort | head -n 1)
	if [ -n "${other_ebuild}" ]; then
		ebuild "${other_ebuild}" manifest
		git add -u "${pkg}/Manifest"
	else
		git rm -r "${pkg}"
	fi
done
