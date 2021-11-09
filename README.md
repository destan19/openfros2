fros固件openwrt框架源码，通过该源码编译出来的固件可以安装应用过滤、上网审计、上网认证、游戏管控等fros插件  

## 如何编译
> 编译方法和openwrt编译方法一样

1. clone源码
```
git clone https://github.com/destan19/openfros.git
```
2. 下载安装第三方包(feeds)
```
./scripts/feeds  update -a
./scripts/feeds  install -a
```
如果这一步报错，切换网络或者搭建梯子后编译  

3. 选择产品并编译固件  
可以通过make menuconfig选择，也可以用我提供的一键编译脚本进行编译  
默认是都是编译x86固件   

**方法1:**
```
make V=s 
```
**方法2**
```
./build.sh
```
如果用一键编译脚本，并且需要修改产品，可以编辑build.sh中的配置设置想要编译的产品  

## 源码说明
该源码基于lean 的lede源码，仓库地址  
https://github.com/coolsnowwolf/lede.git 

### 特性
- 内核版本较少变动  
保持内核版本稳定不变，主要是为了方便安装一些内核模块插件，  
因为内核模块依赖内核版本，内核版本没必要追新，稳定够用就可以了。  
并且商用固件内核版本一般还是3.x，所以不要过度关注内核版本。  
- 加入内核补丁  
用于支持内核模块的开发，需要增加一些内核patch  

## 插件安装
在release中会定期发布fros ipk文件，可以选择安装，也可以用一键脚本安装





