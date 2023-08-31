# tftp-ubuntu-installation

## a complete netboot-server-rollout for deploying ubuntu installations over pxe

Prerequisites:
- running dnsmasq; refer configs/dnsmasq/pxe.conf for configuration your custom config in /etc/dnsmasq.d/yourconf.conf
- running http server pointing to the http-folder, or it's symbolic link; I'm using a goStatic docker container for this. A compose sample is placed in configs/compose/
- if you have a lot of deployments, it's recommended to use a cached proxy like nesus3 like this repo. Peek into configs/compose for a docker deployment. The nexus-setup ist documented in  configs/nexus-config.yaml

Recommendations:
- link via `ln -s` the folders http an tftp to your favourite server folder; here: /srv
- be aware of struggling with existing DHCP-servers and dnsmasq in the same network. This is not a part of this topic: simply search online for this. 
Just run getRequirements.sh to fullify all required structures and files to make a netboot for ubuntu jammy happen.

Run tftp/getRequirements.sh to fullyfy all directories and files in the project folder after initial clone

Target directory structure: 

```
/srv
├── http -> /srv/tftp-ubuntu-installation/http
├── tftp -> /srv/tftp-ubuntu-installation/tftp
└── tftp-ubuntu-installation
    ├── LICENSE
    ├── README.md
    ├── configs
    │   ├── compose
    │   │   ├── gostatic.yml
    │   │   └── nexus.yaml
    │   ├── dnsmasq
    │   │   └── pxe.conf
    │   └── nexus-config.yaml
    ├── http
    │   ├── autoinstall
    │   │   └── jammy
    │   │       ├── assets
    │   │       │   ├── lockRepos.sh
    │   │       │   ├── modFsTab.sh
    │   │       │   └── rmSnap.sh
    │   │       ├── ubuntu2204_desktop.yaml
    │   │       └── ubuntu2204_desktop_efi_hardened.yaml
    │   └── images
    │       └── ubuntu-22.04.3-live-server-amd64.iso
    └── tftp
        ├── README.md
        ├── boot
        │   ├── grub
        │   │   ├── grub.cfg
        │   │   ├── unicode.pf2
        │   │   └── x86_64-efi
        │   │       ├── command.lst
        │   │       ├── crypto.lst
        │   │       ├── fs.lst
        │   │       └── terminal.lst
        │   └── jammy
        │       ├── initrd
        │       └── vmlinuz
        ├── getReqirements.sh
        ├── grub -> boot/grub
        ├── grubnetx64.efi
        ├── grubnetx64.efi.signed
        ├── ldlinux.c32 -> syslinux/bios/ldlinux.c32
        ├── libutil.c32 -> syslinux/bios/libutil.c32
        ├── menu.c32 -> syslinux/bios/menu.c32
        ├── pxelinux.0
        ├── pxelinux.cfg
        │   └── default
        └── syslinux
            └── bios
                ├── ldlinux.c32
                ├── libutil.c32
                └── menu.c32

```
