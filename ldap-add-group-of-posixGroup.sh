#!/bin/bash

# sh
SH_NAME=${0##*/}
SH_PATH=$( cd "$( dirname "$0" )" && pwd )
cd ${SH_PATH}


# 默认：
DC="dc=hb,dc=lan"
ADMIN_DN="cn=Manager,dc=hb,dc=lan"
OU='OtherGroup'
NEXT_NUMBER_DB_OTHER="${SH_PATH}/next-number-for-other-posixgroup.db"



F_HELP()
{
    echo "
    用途：
    依赖：
    注意：
    用法：
        $0  [-h|--help]
        $0  [-n|--name {组名}]  <-d|--description {备注}>
    参数说明：
        \$0   : 代表脚本本身
        []   : 代表是必选项
        <>   : 代表是可选项
        |    : 代表左右选其一
        {}   : 代表参数值，请替换为具体参数值
        %    : 代表通配符，非精确值，可以被包含
        #
        -h|--help      此帮助
        -n|--name      组名。 建议【pg-：代表posix组；ug-：代表uniqueNames组】
        -d|--description  备注描述
    示例:
        #
        $0  -h
        #
        $0  -n pg-op
        $0  -n pg-op  -d 运维组
"
}



F_USER_LDIF()
{
    echo "
# create new
dn: cn=${GROUP_CN},ou=${OU},${DC}
objectClass: posixGroup
cn: ${GROUP_CN}
gidNumber: ${GID_NUMBER_OTHER}
description: ${DESCRIPTION}
#memberUid:
"
}



# 参数检查
TEMP=`getopt -o hn:d:  -l help,name:,description: -- "$@"`
if [ $? != 0 ]; then
    echo "参数不合法，退出！【请查看帮助：\$0 --help】"
    exit 1
fi
#
eval set -- "${TEMP}"



case $1 in
    -h|--help)
        shift
        F_HELP
        exit
        ;;
    -n|--name)
        NAME=$2
        shift 2
        ;;
    -d|--description)
        DESCRIPTION=$2
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo -e "\n峰哥说：内部参数错误！\n"
        exit 1
        ;;
esac


if [ -z "${NAME}" ]; then
    echo -e "\n峰哥说：请提供必要运行参数【-n|--name】！\n"
    exit 1
fi


#
GROUP_CN=${NAME}
DESCRIPTION=${DESCRIPTION}
#
GID_NUMBER_OTHER=`cat  ${NEXT_NUMBER_DB_OTHER}`
#
#
if [ ! -d "${SH_PATH}/my_ldif" ]; then
    mkdir ${SH_PATH}/my_ldif
fi
#
F_USER_LDIF > ${SH_PATH}/my_ldif/${GROUP_CN}.ldif
#
#ldapadd  -x -D ${ADMIN_DN} -W  -f ${SH_PATH}/my_ldif/${GROUP_CN}.ldif  -c -S skiped.ldif
ldapadd  -x -D ${ADMIN_DN} -W  -f ${SH_PATH}/my_ldif/${GROUP_CN}.ldif
if [ $? -eq 0 ]; then
    let NEW_NUMBER_OTHER=${GID_NUMBER_OTHER}+1
    echo ${NEW_NUMBER_OTHER} > ${NEXT_NUMBER_DB_OTHER}
fi


