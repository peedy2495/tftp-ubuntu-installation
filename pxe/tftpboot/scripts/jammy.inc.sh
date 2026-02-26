# prepare Ubuntu Jammy images for netboot

URL_DEFAULT="http://$NEXUS/repository/ubuntu-releases/22.04"
URL_ARCHIVE="http://$NEXUS/repository/ubuntu-releases-old/releases"

#[ -d ./grub/jammy ] || mkdir ./grub/jammy
[ -d ../../http/boot/jammy ] || mkdir ../../http/boot/jammy

declare -A IMAGES=(
    [22.04.3-server]="ubuntu-22.04.3-live-server-amd64.iso"
    [22.04.4-server]="ubuntu-22.04.4-live-server-amd64.iso"
    [22.04.5-server]="ubuntu-22.04.5-live-server-amd64.iso"
)

for VERSION in "${!IMAGES[@]}"; do
    OS_IMAGE=${IMAGES[$VERSION]}
    #[ -d ./grub/jammy/$VERSION ] || mkdir ./grub/jammy/$VERSION
    [ -d ../../http/boot/jammy/$VERSION ] || mkdir ../../http/boot/jammy/$VERSION
    
    wget -nc -P ./tmp  $URL_DEFAULT/$OS_IMAGE
    NA_DEFAULT="$?"
    [ "$NA_DEFAULT" -eq 8 ] && wget -nc -P ./tmp  $URL_ARCHIVE/$(echo $VERSION | cut -d '-' -f1)/$OS_IMAGE
    NA_ARCHIVE="$?"

    if [ "$NA_DEFAULT" -eq 0 ] || [ "$NA_ARCHIVE" -eq 0 ]; then
        mount ./tmp/$OS_IMAGE /mnt
        #cp /mnt/casper/{vmlinuz,initrd} ./grub/jammy/$VERSION/
        #chmod +r ./grub/jammy/$VERSION/{vmlinuz,initrd}
        cp /mnt/casper/{vmlinuz,initrd} ../../http/boot/jammy/$VERSION/
        chmod +r ../../http/boot/jammy/$VERSION/{vmlinuz,initrd}
        umount /mnt

        cp ./tmp/$OS_IMAGE ../../http/images/
        chmod +r ../../http/images/$OS_IMAGE
        rm ./tmp/$OS_IMAGE
    else
        echo -e "Failed to download $OS_IMAGE.\n\tThis image seems to be deprecated and is not available anymore.\n\tPlease check the URL and update the image name if necessary."
        continue
    fi
done