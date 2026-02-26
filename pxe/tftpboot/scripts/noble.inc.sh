# prepare Ubuntu Noble images for netboot

URL_DEFAULT="http://$NEXUS/repository/ubuntu-releases/24.04"
URL_ARCHIVE="http://$NEXUS/repository/ubuntu-releases-old/releases"

#[ -d ./grub/noble ] || mkdir ./grub/noble
[ -d ../../http/boot/noble ] || mkdir ../../http/boot/noble

declare -A IMAGES=(
    [24.04.2-desktop]="ubuntu-24.04.2-desktop-amd64.iso"
    [24.04.2-server]="ubuntu-24.04.2-live-server-amd64.iso"
    [24.04.4-desktop]="ubuntu-24.04.4-desktop-amd64.iso"
    [24.04.4-server]="ubuntu-24.04.4-live-server-amd64.iso"
)

for VERSION in "${!IMAGES[@]}"; do
    OS_IMAGE=${IMAGES[$VERSION]}
    #[ -d ./grub/noble/$VERSION ] || mkdir ./grub/noble/$VERSION
    [ -d ../../http/boot/noble/$VERSION ] || mkdir ../../http/boot/noble/$VERSION
    
    wget -nc -P ./tmp  $URL_DEFAULT/$OS_IMAGE
    NA_DEFAULT="$?"
    [ "$NA_DEFAULT" -eq 8 ] && wget -nc -P ./tmp  $URL_ARCHIVE/$(echo $VERSION | cut -d '-' -f1)/$OS_IMAGE
    NA_ARCHIVE="$?"

    if [ "$NA_DEFAULT" -eq 0 ] || [ "$NA_ARCHIVE" -eq 0 ]; then
        mount ./tmp/$OS_IMAGE /mnt
        #cp /mnt/casper/{vmlinuz,initrd} ./grub/noble/$VERSION/
        #chmod +r ./grub/noble/$VERSION/{vmlinuz,initrd}
        cp /mnt/casper/{vmlinuz,initrd} ../../http/boot/noble/$VERSION/
        chmod +r ../../http/boot/noble/$VERSION/{vmlinuz,initrd}
        umount /mnt

        cp ./tmp/$OS_IMAGE ../../http/images/
        chmod +r ../../http/images/$OS_IMAGE
        rm ./tmp/$OS_IMAGE
    else
        echo -e "Failed to download $OS_IMAGE.\n\tThis image seems to be deprecated and is not available anymore.\n\tPlease check the URL and update the image name if necessary."
        continue
    fi
done