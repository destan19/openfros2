#!/bin/sh

ipk_name_list="
libfros_uci
libfros_util
libuci_config 
libfros_status
kmod-oaf
kmod-app_delay
portald
kmod-portal
appfilter
apid
luci-app-parent_manage
luci-app-app_delay
luci-app-stats
luci-app-fros
luci-app-portal
luci-i18n-fros-zh-cn
luci-i18n-portal-zh-cn
luci-i18n-parent_manage-zh-cn"

for ipk in $ipk_name_list
do
    find ./ -name "${ipk}*" |xargs opkg install
done

