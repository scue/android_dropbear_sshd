#!/bin/bash - 
#===============================================================================
#
#          FILE: dropbear_init.sh
# 
#         USAGE: ./dropbear_init.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: linkscue (scue), linkscue@gmail.com
#  ORGANIZATION: 
#       CREATED: 2014年08月23日 23时59分34秒 CST
#      REVISION:  ---
#===============================================================================

# self
self=$(readlink -f $0)
self_dir=$(dirname $self)

#-------------------------------------------------------------------------------
#  Valuables
#-------------------------------------------------------------------------------
prebuilt_dir=$self_dir/prebuilt
file_list=(${prebuilt_dir}/scp ${prebuilt_dir}/sftp-server ${self_dir}/dropbearmulti)
dropbear_home=/data/local/tmp/droidsshd
# busybox='busybox'
# busybox='/data/data/com.magicandroidapps.bettertermpro/bin/busybox.exe'
save_env_file=$self_dir/my_device_env.txt

#-------------------------------------------------------------------------------
#  Functions
#-------------------------------------------------------------------------------
# 输出信息
info(){
    echo -e "\e[0;32m==> ${@}\e[0m"
}

# 输出次级信息
infosub(){
    echo -e "\e[0;36m  --> ${@}\e[0m"
}

# 输出提示
tip(){
    echo -e "\e[0;35m==> ${@}\e[0m"
}

# 错误信息
err(){
    echo -e "\e[0;31m==> ${@}\e[0m"
}

# 次级错误信息
errsub(){
    echo -e "\e[0;31m  --> ${@}\e[0m"
}

# env
get_device_env_and_change_srv(){
    tip "use my device env.."
    adb shell $busybox env | sed '/^_/d;/adbd/d;/ADBD/d;/USER/d;/RANDOM/d' | \
        sed 's/\(.*\)=\(.*\)/       addnewvar\("\1","\2"\);/' |  tr -d '\011\015' | \
        sed -r "s|(/system/xbin)|\1:$dropbear_home|" > $save_env_file
    cat $save_env_file
    git checkout svr-chansession.c
    sed -i '889,907 d' svr-chansession.c
    sed -i "888 r $save_env_file" svr-chansession.c
    git checkout options.h >/dev/null 2>&1
    sed -ir '/DEFAULT_PATH/ s|:/bin|:/bin:'$dropbear_home'|' options.h
}

# apt-get
apt_dependences(){
    tip "Install gcc-arm-linux-gnueabi, input your passwd if need.."
    sudo apt-get install -y gcc-arm-linux-gnueabi
}

# build
configure_and_build(){
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
    export STATIC=1 MULTI=1 CC=arm-linux-eabi-gcc SCPPROGRESS=0 PROGRAMS="dropbear dropbearkey dbclient"
    make clean && make -j4 strip || return 1
}

# requirement
dropbear_install(){
    tip "Now, install dropbear .."
    adb shell rm $dropbear_home
    adb shell mkdir -p $dropbear_home
    adb shell mkdir -p $dropbear_home/etc
    adb shell mkdir -p $dropbear_home/run
    adb shell mkdir -p $dropbear_home/.ssh
    adb shell touch $dropbear_home/run/dropbear.pid
    adb shell touch $dropbear_home/.ssh/authorized_keys

    # push
    info '--- push'
    for i in ${file_list[@]}; do
        rfile=$(basename $i)
        adb push -p $i $dropbear_home/$rfile
        adb shell chmod 775 $dropbear_home/$rfile
    done

    # symlink
    adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dbclient
    adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dropbear
    adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dropbearkey

     #show
    info '--- files'
    adb shell $busybox find $dropbear_home -type f -o -type l

    # genkey
    info '--- genkey'
    adb shell $dropbear_home/dropbearkey -t rsa -f $dropbear_home/etc/dropbear_rsa_host_key
    adb shell $dropbear_home/dropbearkey -t dss -f $dropbear_home/etc/dropbear_dss_host_key

    # echo
    info '--- please run in adb shell, with root:'
cat <<-EOF
# Root
$dropbear_home/dropbear -A -I 0 -U 0 -G 0 -P 3322 -N root -C passwd \\
    -R $dropbear_home/.ssh/authorized_keys
# Non-Root
$dropbear_home/dropbear -A -I 0 -U 2000 -G 2000 -P 3322 -N shell -C passwd \\
    -R $dropbear_home/.ssh/authorized_keys
EOF
    tip "Done, enjoy!"
}
get_device_env_and_change_srv
# apt_dependences
configure_and_build || exit 1
dropbear_install
