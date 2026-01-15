#!/bin/bash
set -e

to_ver="${1}"

if [ -z "${to_ver}" ]; then
	echo "${0} <from_ver> <to_ver>"
	exit 1
fi

packages=(
	sys-kernel/matrixos-kernel
	sys-kernel/matrixos-kconfig
	virtual/dist-kernel
)

for pkg in "${packages[@]}"; do
	pn=$(basename "${pkg}")
	skel="${pkg}/${pn}.skel"
	to_ebuild="${pkg}/${pn}-${to_ver}.ebuild"
	cp "${skel}" "${to_ebuild}"
	git add "${to_ebuild}"
	ebuild "${to_ebuild}" manifest
	git add -u "${pkg}"
done
