# env
xiaomienv.txt: for xiaomi adb shell env

# equipment
sudo apt-get install gcc-arm-linux-gnueabi

# configure
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
    CC=arm-linux-gnueabi-gcc

# build
export STATIC=1 MULTI=1 CC=arm-linux-eabi-gcc SCPPROGRESS=0 PROGRAMS="dropbear dropbearkey scp dbclient"
make clean && make -j4 strip
