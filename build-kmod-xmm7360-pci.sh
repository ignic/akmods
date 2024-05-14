#!/bin/sh

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

curl -Lo /etc/yum.repos.d/_copr_ignic-akmods.repo "https://copr.fedorainfracloud.org/coprs/ignic/akmods/repo/fedora-${COPR_RELEASE}/ignic-akmods-fedora-${COPR_RELEASE}.repo"

### BUILD xmm7360-pci (succeed or fail-fast with debug output)
rpm-ostree install \
    "akmod-xmm7360-pci-*.fc${RELEASE}.${ARCH}"
akmods --force --kernels "${KERNEL}" --kmod xmm7360-pci
modinfo "/usr/lib/modules/${KERNEL}/extra/xmm7360-pci/xmm7360.ko.xz" > /dev/null \
|| (find /var/cache/akmods/xmm7360-pci/ -name \*.log -print -exec cat {} \; && exit 1)

rm -f /etc/yum.repos.d/_copr_ignic-akmods.repo
