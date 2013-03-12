; xig-mode
; xyzzy interface for git
; written by yosugi

;; TODO モード毎にファイル分ける
;; TODO *xig-mail* が開いたファイルのバッファに書き込まれている
;; TODO *xig-diff* 選択されるたびにバッファをクリア
;; TODO キーバインド / で検索
;; TODO main 画面 g でグラフのありなし
;; TODO main 画面に q を作る
;; TODO diff スペースでスクロール
;; 今の状態でファイル分けたら公開するか
;; 最初の設定も外出しにしよう
;; * xig, xig/common, xig/diff
;
; .xyzzy の設定
; (load-library "xig/xig")
; (setq *xig-git-path* "C:/Program Files (x86)/Git/bin/git.exe")

(provide "xig/xig")
(require "xig/common")
(require "xig/diff")

(export '(xig-mode *xig-git-path*))

(defvar *xig-git-path* "git" "git のパス")
(defvar *xig-shortlog-is-graph* nil "shortlog をグラフで表示しているか")
(defvar *xig-git-shortlog-command* "log --pretty=format:\"%h %ci %an %d %s\"" "shortlog を表示する時のコマンド")
(defvar *xig-git-shortlog-graph-command* (concat *xig-git-shortlog-command* " " "--graph"))

(defvar *xig-main-map* nil)
(unless *xig-main-map*
  (setq *xig-main-map* (copy-keymap *xig-common-map*))
  (define-key *xig-main-map* '#\r 'show-shortlog)
  (define-key *xig-main-map* '#\g 'toggle-shortlog)
  (define-key *xig-main-map* '#\RET 'show-diff)
  )

(defun show-version ()
  (interactive)
  (run-git "--version"))

; git log --pretty=format:"%h - %an, %ar : %s"
;git log --pretty=format:"%h%x09%an%x09%ad%x09%s"
;git log --pretty=format:"%cd %an %s"
;git log --pretty=format:"%cd %an %s" --graph
;git log --pretty=format:"%ci %an %s"
;git log --pretty=format:"%ci %an %d %s" --graph
;git log --pretty=format:"%h %d %s" --graph
;git log --pretty=format:"%h %ci %an %d %s" --graph
; ref. http://blog.toshimaru.net/git-log-graph
; ref. https://www.kernel.org/pub/software/scm/git/docs/git-log.html

(defun show-shortlog ()
  (interactive)
  (setq buffer-read-only nil)
  (run-git *xig-git-shortlog-command*)
  (setq buffer-read-only t)
  )

(defun toggle-shortlog ()
  (interactive)
  (setq buffer-read-only nil)
  (cond
   ((null *xig-shortlog-is-graph*)
    (run-git *xig-git-shortlog-graph-command*)
    (setq *xig-shortlog-is-graph* t))
   (t
    (run-git *xig-git-shortlog-command*)
    (setq *xig-shortlog-is-graph* nil)))
  (setq buffer-read-only t))

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
;   ("^\\*+" t (:color 3 9 :bold) nil 0 0) ; 箇条書き
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

(defun xig-mode ()
  (interactive)
  (kill-all-local-variables)
  (with-output-to-temp-buffer ("*xig-main*" nil)
    (switch-to-buffer "*xig-main*")
    (show-shortlog)
    (setq buffer-read-only t)
    (setq mode-name "xig-main")
    (setq buffer-mode 'xig-mode)
    (setq aut-save nil)
    (setq need-not-save nil)
    ; TODO *window-flag-cursor-line* でカーソルの状態を保存。終了時に元に戻しとく
    ;    (toggle-cursor-line t)
    ;    (toggle-eof nil)
    (use-keymap *xig-main-map*))
  )

