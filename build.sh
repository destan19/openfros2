
CONFIG_PATH="configs"
#芯片方案目录名称，在$CONFIG_PATH目录中，可以指定编译哪个方案
#arch_list="x86 mt7621 rock bcm53xx ipq40xx mt7620 mt7628"
arch_list="x86"
#指定编译的产品（不指定会编译$arch_list中的所有产品），不指定需要设置为""
#产品名称加入config文件的名称即可，也可以添加部分字符串，支持模糊匹配
#配置名称如下
#01-config.newifi3  config.gi_inet_mt1300  config.jcg_y2        config.thunder_cloud  config.xiaomi_4       config.xiaomi_cr660x  config.xiaoyu_c5      config.youku_L2
#02-config.k2p      config.hiwifi_5962     config.redmi_ac2100  config.xiaomi_3gpro   config.xiaomi_ac2100  config.xiaomi_r3gv2   config.youhua_1200js
#编译指定文件就可以设置以上配置名字，也可以自定义加入其他产品配置
#config_product="x86_64"
config_product=""
last_product="config"
enable_last=0
SRC_DISK="/dev/sdb"
fros_ipk=0
found_last=0

rlog(){
    echo "$1" >>./build.log
}

check_disk(){
    local free_bytes=`df $SRC_DISK | grep sdb | awk '{print $4}'`
    rlog "free bytes $free_bytes"
    if [ $free_bytes -lt 8000000 ];then
        return 1
    else
        return 0
    fi
}

build_product()
{
    local arch=$1
    local product=$2
    test -z $product && return 1
    echo "--------------begin build product $product"
    echo "begin build product $product" >>./run.log
    rm tmp/* -fr
    echo "clean tmp dir ....ok"
    cp ${CONFIG_PATH}/${arch}/${product} .config
    if [ $fros_ipk -eq 1 ];then
		echo "CONFIG_PACKAGE_apid=y" >>.config
		echo "CONFIG_PACKAGE_appfilter=y" >>.config
		echo "CONFIG_PACKAGE_kmod-app_delay=y" >>.config
		echo "CONFIG_PACKAGE_kmod-oaf=y" >>.config
		echo "CONFIG_PACKAGE_libfros_status=y" >>.config
		echo "CONFIG_PACKAGE_libfros_uci=y" >>.config
		echo "CONFIG_PACKAGE_libfros_util=y" >>.config
		echo "CONFIG_PACKAGE_libuci_config=y" >>.config
		echo "CONFIG_PACKAGE_license=y" >>.config
		echo "CONFIG_PACKAGE_web_cgi=y" >>.config
		echo "CONFIG_PACKAGE_luci-app-app_delay=y" >>.config
		echo "CONFIG_PACKAGE_luci-app-fros=y" >>.config
		echo "CONFIG_PACKAGE_luci-app-parent_manage=y" >>.config
		echo "CONFIG_PACKAGE_luci-app-stats=y" >>.config
		echo "CONFIG_PACKAGE_luci-i18n-fros-zh-cn=y" >>.config
		echo "CONFIG_PACKAGE_luci-i18n-parent_manage-zh-cn=y" >>.config
		if [ $arch != "mt7620" -a $arch != "mt7628" ];then
		echo "CONFIG_PACKAGE_portald=y" >>.config
		echo "CONFIG_PACKAGE_iperf3=y">>.config
		echo "CONFIG_PACKAGE_luci-i18n-portal-zh-cn=y" >>.config
		echo "CONFIG_PACKAGE_luci-app-portal=y" >>.config
		echo "CONFIG_PACKAGE_kmod-portal=y" >>.config
		fi
	fi
    echo "clean  $product"
    make -j2 V=s
    if [ $? -ne 0 ];then
        echo "build.............$product failed\n"
        exit
    fi
    find bin/ -name "*sysup*" |xargs -i cp  {} ./release
    find bin/ -name "*tar.gz*" |xargs -i cp  {} ./release
    find bin/ -name "*img.gz*" |xargs -i cp  {} ./release
    find bin/ -name "*vmdk*" |xargs -i cp  {} ./release
    find bin/ -name "*trx*" |xargs -i cp  {} ./release
}

build_arch_products()
{
    local arch=$1
    test -z $arch && return 1
    rlog "--------------------------------------------------------------------------------------------"
    rlog  "begin build arch $arch"
    local build_ok=1
    
    for product in `ls ${CONFIG_PATH}/${arch}/ -a`;do
        if [ $product == "." -o $product == ".." ];then
            continue
        fi
        
        if [ x"" != x"$config_product" ];then
            echo $product |grep $config_product >/dev/null
            if [ $? -ne 0 ];then
                rlog "continue $product"
                continue
            fi
        fi
        
        if [ $enable_last -eq 1 ];then
            echo $product |grep $last_product >/dev/null
            if [ $? -eq 0 ];then
                rlog "found last product $product"
                found_last=1
				continue
            fi
            
            if [ $found_last -ne 1 ];then
                continue
            fi
        fi
        
        local date_str=`date`
        rlog "$date_str --------begin build $arch $product"
        
        build_product $arch $product
        date_str=`date`
        rlog "$date_str --------end build $arch $product"
        
        echo $product |grep "7620" >/dev/null
        if [ $? -eq 0 ];then
            echo ""
            make clean
        fi
        rlog "=======build $product ok================"
        build_ok=1
        rlog ""
    done
    if [ $build_ok -eq 1 ];then
        check_disk
        if [ $? -eq 0 ];then
            rlog "##########after make $arch ,make clean"
        else
            rlog "#########after make $arch , rm build_dir & staging dir,exit"
            rm build_dir -fr
            #rm staging_dir -fr
        fi
        rlog "--------------------------------------------------------------------------------------------"
        rlog ""
        rlog ""
        rlog ""
        rlog ""
    fi
}

release_ipks()
{
    local arch=$1
    rm release/$arch -fr >/dev/null 2>&1
    mkdir release/$arch
    search_str="fros oaf parent oafd apid licence stats portal app_delay appfilter uci_config"
    for str in $search_str
    do
        find bin -name "*${str}*" |xargs -i  cp {} release/$arch
    done
    cp install.sh release/$arch/
    cp remove.sh release/$arch/
}


arch_count=0
mkdir release >/dev/null 2>&1
rm run.log >/dev/null 2>&1

for arch in $arch_list; do
    if [ $arch_count -gt 1 ];then
        echo "exec exec make clean, $arch"
     #   make clean
    fi
    build_arch_products $arch
    if [ $fros_ipk -eq 1 ];then
        release_ipks $arch
        rm bin -fr
    fi
    
    arch_count=`expr $arch_count + 1`
done
