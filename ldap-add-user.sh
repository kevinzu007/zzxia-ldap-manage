#!/bin/bash

# sh
SH_NAME=${0##*/}
SH_PATH=$( cd "$( dirname "$0" )" && pwd )
cd ${SH_PATH}


# 默认：
DC="dc=hb,dc=lan"
ADMIN_DN="cn=Manager,dc=hb,dc=lan"
DEFAULT_USER_PASSWD='1234567890'
USER_PASSWD=${DEFAULT_USER_PASSWD}
USER_U_OU='People'
USER_G_OU='Group'
NEXT_NUMBER_DB="${SH_PATH}/next-number.db"



F_HELP()
{
    echo "
    用途：
    依赖：
    注意：
    用法：
        $0  [-h|--help]
        $0  [-n|--name {姓名}]  <-p|--password {用户密码}>
    参数说明：
        \$0   : 代表脚本本身
        []   : 代表是必选项
        <>   : 代表是可选项
        |    : 代表左右选其一
        {}   : 代表参数值，请替换为具体参数值
        %    : 代表通配符，非精确值，可以被包含
        #
        -h|--help      此帮助
        -n|--name      中文姓名
        -p|--password  用户密码
    示例:
        #
        $0  -h
        #
        $0  -n 猪猪侠
        $0  -n 猪猪侠  -p 1234567
"
}


F_USER_LDIF()
{
    echo "
# new user
dn: uid=${USER_UID},ou=${USER_U_OU},${DC}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: ${USER_CN}
sn: ${USER_SN}
userPassword: ${USER_PASSWD_SSHA}
loginShell: /bin/bash
uidNumber: ${USER_UID_NUMBER}
gidNumber: ${USER_GID_NUMBER}
homeDirectory: /home/${USER_UID}

# new group
dn: cn=${GROUP_CN},ou=${USER_G_OU},${DC}
objectClass: posixGroup
cn: ${GROUP_CN}
gidNumber: ${USER_GID_NUMBER}
memberUid: ${USER_UID}
"
}



# 参数检查
TEMP=`getopt -o hn:p:  -l help,name:,password: -- "$@"`
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
    -p|--password)
        USER_PASSWD=$2
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
USER_SN=${NAME:0:1}                          #--- 姓sn
USER_GN=${NAME:1}                            #--- 名gn，Givename
USER_CN=${NAME}                              #--- 通用名Common Name，可作为姓名
#
USER_UID=`${SH_PATH}/hanzi-to-pinyin.py  -c py  -z ${NAME}`       #--- 用户名uid
GROUP_CN=${USER_UID}                         #--- 与uid同名
#
USER_UID_NUMBER=`cat  ${NEXT_NUMBER_DB}`
USER_GID_NUMBER=${USER_UID_NUMBER}
#
USER_PASSWD_SSHA=`slappasswd -s ${USER_PASSWD}`
#
if [ ! -d "${SH_PATH}/my_ldif" ]; then
    mkdir ${SH_PATH}/my_ldif
fi
#
F_USER_LDIF > ${SH_PATH}/my_ldif/${USER_UID}.ldif
#
#ldapadd  -x -D ${ADMIN_DN} -W  -f ${SH_PATH}/my_ldif/${USER_UID}.ldif  -c -S skiped.ldif
ldapadd  -x -D ${ADMIN_DN} -W  -f ${SH_PATH}/my_ldif/${USER_UID}.ldif
if [ $? -eq 0 ]; then
    let NEW_NUMBER=${USER_UID_NUMBER}+1
    echo ${NEW_NUMBER} > ${NEXT_NUMBER_DB}
fi


