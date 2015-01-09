# about
the ssh/sshd alternative for android.

# env
```
env.txt: for android adb shell env
```
you can get your device env:
```
adb shell busybox env
```
then, remove `USER`,`RANDOM` and `_` avaluables
the end, you should update these to `svr-chansession.c` by using `addnewvar()`

# requirement
```
sudo apt-get install gcc-arm-linux-gnueabi
```

# configure
```
./configure --host=arm-linux-eabi \
    --disable-zlib \
    --disable-largefile \
    --disable-loginfunc \
    --disable-shadow \
    --disable-utmp \
    --disable-utmpx \
    --disable-wtmp \
    --disable-wtmpx \
    --disable-pututline \
    --disable-pututxline \
    --disable-lastlog \
    CC=arm-linux-gnueabi-gcc \
    STRIP=arm-linux-gnueabi-strip
```

# build
```
export STATIC=1 MULTI=1 CC=arm-linux-gnueabi-gcc SCPPROGRESS=0 PROGRAMS="dropbear dropbearkey dbclient"
make clean && make -j4 strip
```

# files

`scp`: copy file over ssh

`sftp-server`: ftp server over ssh

`dropbear_install.sh`: install dropbear to android

# notes
maybe you want to custom!
1. for ssh-copy-id: [commit](http://200.200.0.36/28120/emm_droid_sshd/commit/84b51fb8557f522640368ffc1350a27092a20197)
2. for shell env: [commit](http://200.200.0.36/28120/emm_droid_sshd/commit/54d8ed8b25e2a21497905b67d89e0e421e1c5fe1)
3. for options: [commit](http://200.200.0.36/28120/emm_droid_sshd/commit/ade0deea924ad4fe0c9809f9e822e6d21168cc09)
4. for scp: [commit](http://200.200.0.36/28120/emm_droid_sshd/commit/9666248660094adab092552eb42734b47d964e08)
