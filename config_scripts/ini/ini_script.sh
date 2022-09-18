#!/usr/bin/env bash
# 脚本来源：https://blog.csdn.net/wanxiaoderen/article/details/82388091
# 脚本必须使用 source 命令进行结果获取，
# 结果的获取方式为 ${var} 获取，具体使用方式见 ini_example.sh
#该脚本必须用 source 命令 而且结果获取为${var}获取，不是return 如：source readIni.sh 否则变量无法外传

# 写入配置时的说明：
# 如果对应的 key 不存在，那么写入 key=value
# 如果对应的 key存在，value 不同时进行更新，value 相同则无操作。
# 写入的 value 不能是一个空！！！
 
# 参数
iniFile=$1  # ini文件路径
section=$2  # section 字段
option=$3   # key 字段

# 处理
mode="iniR"
echo $@ | grep "\-w" >/dev/null&&mode="iniW"
if [ "$#" = "5" ]&&[ "$mode" = "iniW" ];then
   iniFile=$2
   section=$3
   option=$4
   value=$5
   #echo $iniFile $section $option $value
fi

# 结果
iniValue='default'
iniOptions=()
iniSections=()
 
function checkFile()
{
    if [ "${iniFile}" = ""  ] || [ ! -f ${iniFile} ];then
        echo "[error]:file --${iniFile}-- not exist!"
    fi
}
 
function readInIfile()
{
    if [ "${section}" = "" ];then
        # 通过如下两条命令可以解析成一个数组
        allSections=$(awk -F '[][]' '/\[.*]/{print $2}' ${iniFile})
        iniSections=(${allSections// /})
        echo "[info]:iniSections size:-${#iniSections[@]}- eles:-${iniSections[@]}- "
    elif [ "${section}" != "" ] && [ "${option}" = "" ];then
        # 判断section是否存在
        allSections=$(awk -F '[][]' '/\[.*]/{print $2}' ${iniFile})
        echo $allSections|grep ${section}
        if [ "$?" = "1" ];then
            echo "[error]:section --${section}-- not exist!"
            return 0
        fi
        # 正式获取options
        # a=(获取匹配到的section之后部分|去除第一行|去除空行|去除每一行行首行尾空格|将行内空格变为@G@(后面分割时为数组时，空格会导致误拆))
        a=$(awk "/\[${section}\]/{a=1}a==1"  ${iniFile}|sed -e'1d' -e '/^$/d'  -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e 's/[ ]/@G@/g' -e '/\[/,$d' )
        b=(${a})
        for i in ${b[@]};do
          # 剔除非法字符，转换@G@为空格并添加到数组尾
          if [ -n "${i}" ]||[ "${i}" i!= "@G@" ];then
              iniOptions[${#iniOptions[@]}]=${i//@G@/ }
          fi
        done
        echo "[info]:iniOptions size:-${#iniOptions[@]}- eles:-${iniOptions[@]}-"
    elif [ "${section}" != "" ] && [ "${option}" != "" ];then
 
       # iniValue=`awk -F '=' '/\['${section}'\]/{a=1}a==1&&$1~/'${option}'/{print $2;exit}' $iniFile|sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
        iniValue=`awk -F '=' "/\[${section}\]/{a=1}a==1" ${iniFile}|sed -e '1d' -e '/^$/d' -e '/^\[.*\]/,$d' -e "/^${option}.*=.*/!d" -e "s/^${option}.*= *//"`
        echo "[info]:iniValue value:-${iniValue}-"
        fi
}
 
function writeInifile()
{
    # 检查文件
    checkFile
    allSections=$(awk -F '[][]' '/\[.*]/{print $2}' ${iniFile})
    iniSections=(${allSections// /})
    # 判断是否要新建section
    sectionFlag="0"
    for temp in ${iniSections[@]};do
        if [ "${temp}" = "${section}" ];then
            sectionFlag="1"
            break
        fi
    done
 
    if [ "$sectionFlag" = "0" ];then
        echo "[${section}]" >>${iniFile}
    fi
    # 加入或更新value
    awk "/\[${section}\]/{a=1}a==1" ${iniFile}|sed -e '1d' -e '/^$/d'  -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e '/\[/,$d'|grep "${option}.\?=">/dev/null
    if [ "$?" = "0" ];then
        # 更新
        # 找到制定section行号码
        sectionNum=$(sed -n -e "/\[${section}\]/=" ${iniFile})
        sed -i "${sectionNum},/^\[.*\]/s/\(${option}.\?=\).*/\1 ${value}/g" ${iniFile}
        echo "[success] update [$iniFile][$section][$option][$value]"
    else
        # 新增
        # echo sed -i "/^\[${section}\]/a\\${option}=${value}" ${iniFile}
        sed -i "/^\[${section}\]/a\\${option} = ${value}" ${iniFile}
        echo "[success] add [$iniFile][$section][$option][$value]"
    fi
}
 
# 入口
if [ "${mode}" = "iniR" ];then
    checkFile
    readInIfile
elif [ "${mode}" = "iniW" ];then
    writeInifile
fi