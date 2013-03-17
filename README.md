# Xig: xyzzy interface for git

## 概要

xyzzy の git ブラウザです。
xyzzy で動く [tig](http://jonas.nitro.dk/tig/) を目指したものです。

### できること

* shortlog を見る
* commit の diff を見る
* stage, unstage の切り替え
* コミット

## インストール

* windows 用の git が必要です。 [git for windows](http://msysgit.github.com/) 等をインストールしてください。
* xyzzy の site-lisp に xig というディレクトリを作り、このリポジトリのファイルをコピーしてください。
* git を使って入れる場合は site-lisp に移動して以下のコマンドを実行します。
    * git clone git://github.com/yosugi/xyzzy.xig.git xig

## 設定

.xyzzy 等に以下を追記してください。
```
(load-library "xig/xig")
(setq xig::*xig-git-path* <git.exe へのパス>)
```

## 使い方

git 配下にあるファイルを開いて `M-x xig-mode` すれば
shortlog が見えるはずです。

基本的に tig と同じように使えると思います。

## キーバインド

全体的に vim っぽいキーバインドも定義しています。
また `TAB` でウィンドウ間の移動ができます。

### shortlog(main)

* `RET` コミットの diff を表示
* `R` shortlog を再描画
* `g` コミットグラフの表示 / 非表示切り換え
* `S` status 画面表示
* `q` diff を閉じる / xig-mode 終了

### diff

* `f` 下スクロール
* `SPC` 下スクロール 
* `b` 上スクロール 
* `q` diff を閉じる

### status

* `u` stage, unstage の切り替え (git add/reset)
* `!` 変更取り消し (git checkout --)
* `RET` diff を表示
* `C` コミットメッセージ編集
* `q` status を閉じる

### commit

* `C-c C-c` コミット (git commit)
* `C-g` コミットをキャンセル

## ライセンス

MIT ライセンスです。
LICENCE ファイルを参照してください。

## サポート

バグ、要望等は github の [issues](http://github.com/yosugi/xyzzy.xig/issues) 
までお願いします。

