#!/bin/sh
ipk_name_list="luci-i18n-fros-zh-cn
luci-i18n-portal-zh-cn
luci-i18n-parent_manage-zh-cn
luci-app-stats
luci-app-portal
luci-app-fros
luci-app-app_delay
luci-app-parent_manage
portald
apid
appfilter
libuci_config
appfilter
kmod-portal
kmod-app_delay
kmod-oaf
libfros_status
libfros_util
libfros_uci"


for ipk in $ipk_name_list
do
    find ./ -name "${ipk}*" |xargs opkg remove
done

