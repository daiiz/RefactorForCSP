# -*- coding: utf-8 -*-

import os.path
import shutil
import glob
import urllib
from bs4 import BeautifulSoup

# ビール
created_marc = "🍺"
# 寿司
completed_marc = "🍣"

def main():
    pass

def refactor_csp_main():
    # 対象のHTMLファイル名を格納
    htmlfile = "sample.html"
    html = open(htmlfile, "rw")
    soup = BeautifulSoup(html)
    # 対応すべきスクリプトタグのリストを取得する
    scripts = getEmbedScriptTags(soup)
    if len(scripts) > 0:
        # 元データのコピーを生成する
        createHtmlCopy(htmlfile)
        # スクリプトを外部化する
        generated_js_names = createScriptFiles(scripts, htmlfile)
        # HTML内のスクリプトパスを編集する
        editHtmlScriptTag(generated_js_names, scripts, soup, htmlfile)
    # HTMLを閉じる
    html.close()
    print completed_marc

def getEmbedScriptTags(soup):
    '''
    HTMLファイル内に埋め込みScriptタグがあるか否かを調べる関数
    ・ある場合： Scriptタグの中身の配列を返す
    ・ない場合： 空の配列を返す
    '''
    scripts = soup.find_all("script")
    embed_scripts = []
    for script in scripts:
        src = script.get('src')
        if src == None:
            embed_scripts.append(script)
    return embed_scripts

def createHtmlCopy(filename):
    '''
    元データHTMLファイルのコピーを生成する関数
    命名規則： index.html.pre_csp
    '''
    copyfile = "{}.pre_csp".format(filename)
    #has_copy = os.path.exists(copyfile)
    #if(has_copy is False):
    shutil.copy(filename, copyfile)
    print "{}  {}".format(created_marc, copyfile)
    return 1

def createScriptFiles(scripts, filename):
    '''
    埋め込みScriptの内容を外部ファイルとして出力する関数
    命名規則： index.html.0.js, index.html.1.js, ..., index.html.N.js
    '''
    reg = "{}.*.js".format(filename)
    jss = glob.glob(reg)
    # 最大の N を求める
    maxN = -1
    for js in jss:
        js = js.split('.')
        n = int(js[-2])
        if n > maxN:
            maxN = n
    # 外部スクリプトを生成する
    # 生成したファイル名の配列を返す
    nextN = maxN + 1
    created_js_name = []
    for script in scripts:
        js_name = "{}.{}.js".format(filename, nextN)
        f = open(js_name, "w")
        f.write(script.string.encode('utf8'))
        f.close()
        created_js_name.append(js_name)
        print "{}  {}".format(created_marc, js_name)
        nextN += 1
    return created_js_name

def editHtmlScriptTag(generated_jss, scripts_soup, soup, filename):
    '''
    Scriptタグを編集してsrc属性を追加しパスを張る関数
    '''
    for i, script in enumerate(scripts_soup):
        script['src'] = generated_jss[i]
        script.string = ''
    # HTMLファイルを上書きする
    f = open(filename, "w")
    f.write((soup.prettify()).encode('utf8'))
    print "{}  {}".format(created_marc, filename)
    f.close()
    return scripts_soup

if __name__ == '__main__':
    main()
