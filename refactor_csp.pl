#!/usr/bin/perl -w

#
# refactor_csp.pl
#
# Refactor for CSP v2
# 実行時引数のディレクトリ内の全てのHTMLファイルに対して、
# HTMLソース内部のタグ<script>を外部jsファイル読み込み形式に変更する 
# 生成されるファイルの命名規則は Chrome Dev Editor に従い、以下のようにした
# 
# index.html -> index.html.pre_csp (初回のみ生成されるコピーファイル)
#               index.html
#               index.html.0.js, index.html.1.js, ...
#

use strict;
use warnings;
use utf8;
use File::Copy;

my $dir = '.'; # 対象ディレクトリ
if(scalar @ARGV == 1) {
    $dir = $ARGV[0];
}
chdir $dir; # ディレクトリを移動する

$dir = '.';

sub main {
  refactor_csp();
}

sub refactor_csp {
  opendir my $dh, $dir or die "$dir:$!";
  # 外部スクリプ名の規則は html.num.js
  my $num = -1;

  while (my $file = readdir $dh) {
    next if $file =~ /^\.{1,2}$/;
    if($file =~ /.html$/) {
      # .pre_cspファイルがなければ生成する
      my $pre_csp_file = $file.'.pre_csp';
      if(-f $pre_csp_file) {
          # 何もしない
      }else {
          copy $file, $pre_csp_file or die $!;
          print 'created '.$pre_csp_file;
          print "\n";
      }
      
      # ファイルを開く
      open(IN, "<$file");
      local $/ = undef;
      my $html = <IN>;
      my $flag = 1;

      # refactor_csp による既存の呼び出しjsの管理番号最大値を求める
      my @our_scripts = ($html =~ /$file\.[0-9]+\.js/mg);
      my @our_numbers = ($num);
      my $i;
      for($i = 0; $i < scalar @our_scripts; $i++) {
        $our_scripts[$i] =~ /[0-9]+/;
        $our_numbers[$i] = $&;
      }
      my $max = $our_numbers[0];
      for($i = 0; $i < scalar @our_numbers; $i++) {
        if($our_numbers[$i] > $max) {
          $max = $our_numbers[$i];
        }
      }
      $num = $max + 1;

      # 閉じられていない script タグの総数
      my $open = 0;
      while ($flag) {
        # 外部ファイル化するべき script タグを把握する
        # このwhileブロック終了後に
        # <script0>タグで囲まれている内容を外部ファイル化すれば良い。
        if ($html =~ /<script|<\/script/im){
          # scriptタグがある間は実行する
          # 次回の検索でヒットしないようにタグ名を更新する
          # <script> → <{$open}script> | </script> → <{$open}/script>
          if($& eq '<script') {  #$& eq '<script'
            my $replace_tag = '<'.$open.'script';
            $html =~ s/\Q$&/$replace_tag/m;
            $open++;
          }elsif($& eq '</script'){
            $open--;
            my $replace_tag = '<'.$open.'/script';
            $html =~ s/\Q$&/$replace_tag/m;
          }
        }else {
          $flag = 0;
        }
      }
      close(IN);

      # 外部ファイル化作業
      $flag = 1;
      while($flag) {
        if ($html =~ /<0script>(.+?)<0\/script>/s){ 
          my $tag = $&;
          my $js = $1;
          my $outer_file = $file.'.'.$num.'.js';
          my $replace_tag = '<script src="'.$outer_file.'"></script>';
          $num++;
          $html =~ s/\Q$tag/$replace_tag/m;
          # scriptタグから管理用の数字を外す
          $js =~ s/<[0-9]+script/<script/gm;
          $js =~ s/<[0-9]+\/script/<\/script/gm;
          # 外部ファイルを生成する
          open (OUT, "> $outer_file") or die "$!";
          print OUT $js;
          close (OUT);
          print 'created '.$outer_file;
          print "\n";
        }else {
          $flag = 0;
        }
      }

      # <0script src=...><0/script> から管理用の数字0を外す
      $html =~ s/<[0-9]+script/<script/gm; 
      $html =~ s/<[0-9]+\/script/<\/script/gm;

      # HTMLファイルを更新する
      open (OUT, "> $file") or die "$!";
      print OUT $html;
      close (OUT);
    }

    # 1つぶんのファイルの処理が完了
    $num = -1;
  }
  closedir $dh;
}

main();
