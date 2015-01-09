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

prebuilt_dir=$self_dir/prebuilt
file_list=(${prebuilt_dir}/scp ${prebuilt_dir}/sftp-server ${self_dir}/dropbearmulti)
dropbear_home=/data/local/tmp/droidsshd

busybox='busybox'
# busybox='/data/data/com.magicandroidapps.bettertermpro/bin/busybox.exe'

# requirement
adb shell mkdir -p $dropbear_home
adb shell mkdir -p $dropbear_home/etc
adb shell mkdir -p $dropbear_home/run
adb shell mkdir -p $dropbear_home/.ssh
adb shell touch $dropbear_home/run/dropbear.pid
adb shell touch $dropbear_home/.ssh/authorized_keys

# push
echo '--- push'
for i in ${file_list[@]}; do
    rfile=$(basename $i)
    adb push -p $i $dropbear_home/$rfile
    adb shell $busybox chmod a+x $dropbear_home/$rfile
done

# symlink
adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dbclient
adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dropbear
adb shell ln -s $dropbear_home/dropbearmulti $dropbear_home/dropbearkey

 #show
echo '--- files'
adb shell $busybox find $dropbear_home -type f -o -type l

# genkey
echo '--- genkey'
adb shell $dropbear_home/dropbearkey -t rsa -f $dropbear_home/etc/dropbear_rsa_host_key
adb shell $dropbear_home/dropbearkey -t dss -f $dropbear_home/etc/dropbear_dss_host_key

# echo
echo '--- please run in adb shell, with root:'
cat <<-EOF
$dropbear_home/dropbear -A -I 0 -U 0 -G 0 -N root -C passwd \\
    -R $dropbear_home/.ssh/authorized_keys
EOF
