RefactorForCSP
==============

![](https://lh5.googleusercontent.com/ilgP25cM5liQtEVhS_yrFuWH5YAqPGewiFBus0vLM_HQj57sdOJEASK6FWzWSc5FqDAUGEU2gBQCijA=w1197-h605)

HTMLソース内部のscriptタグを外部JSファイル読み込み形式に変更するスクリプト

```
$ cd workspace/
$ python refactor_csp.py
```

```
#
# refactor_csp.pl
# refactor_csp.py
#
# Refactor for CSP v3
# 実行時引数のディレクトリ内の全てのHTMLファイルに対して、
# HTMLソース内部のタグ<script>を外部jsファイル読み込み形式に変更する
# 生成されるファイルの命名規則は Chrome Dev Editor に従い、以下のようにした
#
# index.html -> index.html.pre_csp (初回のみ生成されるコピーファイル)
#               index.html
#               index.html.0.js, index.html.1.js, ...
#
```
