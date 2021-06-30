#!/usr/bin/python3
# -*- coding: utf-8 -*-

import pypinyin
import sys
import getopt


def usage():
    print('    用途：转换汉字为连体拼音或带音节的拼音')
    print('    用法：')
    print('        $0  [-h|--help]')
    print('        $0  [-c|--convert [py|pyj]] | [-z|--hanzi {汉字}]')
    print('    参数说明：')
    print('        -h|--help      帮助')
    print('        -c|--convert   转换方式，py代表不带音节的连体拼音，pyj代表带音节的拼音')
    print('        -z|--hanzi     指定汉字')
    print('    示例：')
    print('        $0  -c py   -z 我是谁')
    print('        $0  -c pyj  -z 我是谁')


# 不带声调的(style=pypinyin.NORMAL)
def pinyin(word):
    s = ''
    for i in pypinyin.pinyin(word, style=pypinyin.NORMAL):
        s += ''.join(i)
    return s

# 带声调的(默认)
def pinyinjie(word):
    s = ''
    # heteronym=True开启多音字
    for i in pypinyin.pinyin(word, heteronym=True):
        s = s + ''.join(i) + " "
    return s

if __name__ == "__main__":
    #print(pinyin("自强不息"))
    #print(yinjie("厚德载物"))
    CONVERT=''
    HANZI=''
    opts,args = getopt.getopt(sys.argv[1:],shortopts='hc:z:',longopts=['help','convert=','hanzi='])
    for opt,value in opts:
        if opt in ('-h','--help'):
           usage()
           sys.exit(0)
        elif opt in ('-c','--convert'):
           CONVERT = value
        elif opt in ('-z','--hanzi'):
           HANZI = value

    if not HANZI:
        print('峰哥说：参数【-z|--hanzi】是必选项，且值不能为空')
        sys.exit(1)

    if CONVERT:
        if CONVERT == 'py':
            print(pinyin(HANZI))
        elif CONVERT == 'pyj':
            print(pinyinjie(HANZI))
        else:
            print('峰哥说：参数【-c|--convert】是必选项，且值只能是【py或pyj】')
    else:
        print('峰哥说：参数【-c|--convert】是必选项')



