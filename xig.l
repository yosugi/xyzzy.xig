; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig")
(in-package "editor")

(export '(xig-mode *xig-git-path*))

;(defvar *xig-git-path* "C:/Program Files (x86)/Git/bin/git.exe" "git のパス")
(defvar *xig-git-path* "git" "git のパス")
(defvar *xig-git-shortlog-command* "log --pretty=format:\"%h %ci %an %d %s\"" "shortlog を表示する時のコマンド")

(defun run-git (command)
  "git 起動用"
  (with-output-to-temp-buffer ("*result*") t
    (execute-shell-command
     (concat (map-slash-to-backslash (get-short-path-name *xig-git-path*)) " " command)
     nil
     (selected-buffer)))
  )

(defun git-version ()
  (interactive)
  (run-git "--version"))

; git log --pretty=format:"%h - %an, %ar : %s"
;git log --pretty=format:"%h%x09%an%x09%ad%x09%s"
;git log --pretty=format:"%cd %an %s"
;git log --pretty=format:"%cd %an %s" --graph
;git log --pretty=format:"%ci %an %s"
;git log --pretty=format:"%ci %an %d %s" --graph
;git log --pretty=format:"%h %d %s" --graph
; ref. http://blog.toshimaru.net/git-log-graph
; ref. https://www.kernel.org/pub/software/scm/git/docs/git-log.html

(defun git-shortlog ()
  (interactive)
  (run-git *xig-git-shortlog-command*))

; git log --stat -p
; git log --stat -p --pretty=full
; git log --stat -p --pretty=fuller
; ↑でほぼ OK だが Refs だけ表示されない。まぁいいか。
(defun git-commit-info (commit)
  (run-git (format nil "log --stat -p --pretty=fuller ~A" commit)))

;(reduce (lambda (a b) (concat a " " b))
;        '("aa" "bb" "cc" "dd"))
;"aa bb cc dd"

; TODO
; * M-x xig-mode で shortlog 出す
; * shortlog を選択すると下に commit info が出る
; * shortlog で S 押すと status mode に
; * status mode で選択して U で追加、削除
; * status mode で C で commit
;     * git commit -m でやればいけるか?
;     * git commit -F でファイル指定できるみたいなので OK
; * ファイルとしては以下
;     * xig.l
;     * diff.l
;     * status.l
; * 色付けは後でいいや。やり方知らんし
; * グラフも後だなー
;   * magit は空行も気にせずグラフ出してるから、それでもいいかも。
; * tig で h 打つとヘルプが出るが全部はちょっとねー
; * commit は nippo-mode と同じで C-x C-s, C-x C-c かなー
; * sha-1 に一致する 正規表現 \b[0-9a-f]{5,40}\b

; 色分けはこんなんでできるのかなー
; http://d.hatena.ne.jp/chimachimagic/20101018/1287414692
; 正規表現で色付け
;(defvar *tw-mode-regexp-keyword-list*
;  (compile-regexp-keyword-list
;   '(("^!+.*$" t (:keyword 3 :bold :line) nil 0 0) ; 見出し
;     ("^>+\\(.*\\)$" t (:color 5) nil 1 1) ; 引用
;	 ("^\\*+" t (:color 3 9 :bold) nil 0 0) ; 箇条書き
;	 ("^#+" t (:color 3 9 :bold) nil 0 0) ; 数字箇条書き
;	 ("^----$" t (:color 0 10 :line) nil 0 0) ; 水平線
;	 ("\\[\\(img\\)?\\[.*?\\]\\]" t (:keyword 2) nil 0 0) ; Wikiリンク/イメージ
;	 ("<<.*?>>" t (:color 4) nil 0 0) ; マクロ
;	 ("</?[A-Za-z ]+?>" t (:color 4) nil 0 0) ; htmlタグ
;	 ("[^~]\\<\\([A-Z]+[a-z0-9_]+[A-Z]+[A-Za-z0-9_]*\\|[A-Z]\\{2\\}[a-z0-9_]+\\)\\>" nil (:keyword 2 :bold) nil 1 1) ; WikiWord
;	 ("''\\(.+?\\)''" t (:color 1 0 :bold) nil 1 1) ; 太字
;	 ("__\\(.+?\\)__" t (:color 1 0 :underline) nil 1 1) ; アンダーライン
;	 ("--\\(.+?\\)--" t (:color 1 0 :strike-out) nil 1 1) ; 取り消し線
;	 ("@@\\(.+?\\)@@" t (:color 8 3 :bold) nil 1 1) ; 強調(@@～@@)
;	 ("{{\\(\\w+\\)?{" t (:color 6 12 :bold) nil 0 0) ; {{{
;	 ("}}}" t (:color 6 12 :bold) nil 0 0) ; }}}
;     )))

; 文字列は sring-match で取れる
; http://www.geocities.jp/m_hiroi/xyzzy_lisp/abclisp16.html
