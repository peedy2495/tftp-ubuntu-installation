# tftp-ubuntu-installation

## a complete netboot-server-rollout for deploying ubuntu installations over pxe

Prerequisites:
- running dnsmasq - refer configs/dnsmasq/pxe.conf for configuration your custom config in /etc/dnsmasq.d/yourconf.conf

Just run getRequirements.sh to fullify all required structures and files to make a netboot for ubuntu jammy happen.

Target directory structure: 

```
tftp
├── boot
│   ├── grub
│   │   ├── grub.cfg
│   │   ├── unicode.pf2
│   │   └── x86_64-efi
│   │       ├── command.lst
│   │       ├── crypto.lst
│   │       ├── fs.lst
│   │       └── terminal.lst
│   └── jammy
│       ├── initrd
│       └── vmlinuz
├── grub -> boot/grub
├── grubnetx64.efi
├── grubnetx64.efi.signed
├── ldlinux.c32 -> syslinux/bios/ldlinux.c32
├── libutil.c32 -> syslinux/bios/libutil.c32
├── menu.c32 -> syslinux/bios/menu.c32
├── pxelinux.0
├── pxelinux.cfg
│   └── default
└── syslinux
    └── bios
        ├── ldlinux.c32
        ├── libutil.c32
        └── menu.c32
```
