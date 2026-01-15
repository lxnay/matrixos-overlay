# matrixOS Overlay

This is the official Gentoo overlay for **matrixOS**, providing custom ebuilds, system packages, and configuration themes specific to the distribution.

It includes the matrixOS kernel, bootloader configurations, GNOME theming, and hardware-specific utilities (like `asusctl` and `sbctl`).

## 📦 Contents

| Category | Description |
| :--- | :--- |
| **sys-kernel** | Custom matrixOS kernel sources and headers. |
| **sys-boot** | Bootloader configurations and tools. |
| **x11-themes** | `matrixos-artwork-gnome` and other visual assets. |
| **sys-power** | `asusctl` for ASUS ROG/TUF laptop management. |
| **app-crypt** | `sbctl` for Secure Boot key management. |
| **gnome-base** | Custom GNOME session and shell settings. |
| **media-libs** | Mesa builds tailored for matrixOS. |

## 🚀 Installation

You can add this overlay using `eselect-repository` or manually via `repos.conf`.

### Option 1: Using eselect-repository (Recommended)

If you haven't already, install `eselect-repository`:
```bash
emerge --ask app-eselect/eselect-repository
eselect repository add matrixos-overlay git https://github.com/lxnay/matrixos-overlay.git
emaint sync -r matrixos
```

Or manually:
```bash
[matrixos]
location = /var/db/repos/matrixos
sync-type = git
sync-uri = [https://github.com/lxnay/matrixos-overlay.git](https://github.com/lxnay/matrixos-overlay.git)
auto-sync = yes
```

To install the matrixOS artwork (still WIP):
```bash
emerge --ask x11-themes/matrixos-artwork-gnome
```

To install the coolest kernel, with ostree support and ntfsplus built in:
```bash
emerge --ask sys-kernel/matrixos-kernel
```

## 🤝 Contributing
Issues and Pull Requests are welcome. If you are submitting a new package, please ensure it follows standard Gentoo development guidelines.
