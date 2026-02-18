mkdir -p /target/etc/save/apt/sources.list.d
mkdir /target/etc/save/apt/sources.list.save
mkdir /target/etc/apt/sources.list.save

# save major repo definition
mv /target/etc/apt/sources.list /target/etc/save/apt/sources.list.save/
mount --bind -o ro /target/etc/save/apt/sources.list.save /target/etc/apt/sources.list.save
curtin in-target --  ln -s /etc/apt/sources.list.save/sources.list /etc/apt/sources.list 
printf '/etc/save/apt/sources.list.save /etc/apt/sources.list.save     none bind,ro,nofail       0       0\n' >> /target/etc/fstab

# save custom repos
mv /target/etc/apt/sources.list.d/* /target/etc/save/apt/sources.list.d/
mount --bind -o ro /target/etc/save/apt/sources.list.d /target/etc/apt/sources.list.d
printf '/etc/save/apt/sources.list.d   /etc/apt/sources.list.d         none bind,ro,nofail       0       0\n' >> /target/etc/fstab
