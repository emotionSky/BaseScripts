#!/usr/bin/env bash

INI_SH=ini_script.sh
INI_FILE=./config.ini
chmod +x ${INI_SH}

##################### 写配置文件 #####################
# 终端和文件使用方式一样
source ${INI_SH} -w ${INI_FILE} product key False


##################### 读配置文件 #####################

if [ -f ${INI_FILE} ]; then
    echo "${INI_FILE} exist!"
fi

# 终端直接打印结果：
source ${INI_SH} ${INI_FILE} product key 
echo ${iniValue}

# 在其他脚本中调用
VALUE=$(source ${INI_SH} ${INI_FILE} product key > /dev/null 2>&1 && echo ${iniValue})
ehco ${VALUE}