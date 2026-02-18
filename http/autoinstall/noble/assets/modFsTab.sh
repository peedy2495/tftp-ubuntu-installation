printf 'tmpfs        /var/crash        tmpfs     rw,relatime,nodev,noexec,nosuid,size=100M      0       0\n' >> /target/etc/fstab
printf 'tmpfs        /dev/shm          tmpfs     rw,relatime,nodev,noexec,nosuid,size=512M      0       0\n' >> /target/etc/fstab
printf 'tmpfs        /run              tmpfs     rw,relatime,nodev,noexec,nosuid,size=100M      0       0\n' >> /target/etc/fstab
printf 'proc         /proc             proc      rw,relatime,nodev,noexec,nosuid,hidepid=2      0       0\n' >> /target/etc/fstab
printf 'tmpfs        /media            tmpfs     rw,relatime,nodev,noexec,nosuid,size=4K        0       0\n' >> /target/etc/fstab