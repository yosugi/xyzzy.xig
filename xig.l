; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/xig")
(in-package "editor")

(require "xig/common")
(require "xig/diff")
(require "xig/status")

(export '(xig-mode *xig-git-path*))

(defvar *xig-mode-name* "xig" "このモードの名前")
(defvar *xig-pframe-name* *xig-mode-name* "フレームの名前")

(defvar *xig-git-path* "git" "git のパス")
(defvar *xig-shortlog-is-graph* nil "shortlog をグラフで表示しているか")
(defvar *xig-git-shortlog-command* "log --pretty=format:\"%h %ci %an %d %s\"" "shortlog を表示する時のコマンド")
(defvar *xig-git-shortlog-graph-command* (concat *xig-git-shortlog-command* " " "--graph"))

(defvar *xig-main-map* nil)
(unless *xig-main-map*
  (setq *xig-main-map* (copy-keymap *xig-common-map*))
  (define-key *xig-main-map* '#\R 'show-shortlog)
  (define-key *xig-main-map* '#\g 'toggle-shortlog-graph)
  (define-key *xig-main-map* '#\RET 'show-diff)
  (define-key *xig-main-map* '#\S 'show-status)
  (define-key *xig-main-map* '#\q 'quit-xig-mode)
  )

(defun show-version ()
  (interactive)
  (run-git "--version"))

(defun show-shortlog ()
  (interactive)
  (setq buffer-read-only nil)
  (run-git *xig-git-shortlog-command*)
  (save-excursion
    (goto-char (point-max))
    (with-output-to-selected-buffer
      (format t "~%")))
  (setq buffer-read-only t)
  )

(defun toggle-shortlog-graph ()
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

(defun xig-mode ()
  (interactive)
  (new-pseudo-frame *xig-pframe-name*)
  (switch-to-buffer "*xig-main*")
  (kill-all-local-variables)
  (show-shortlog)
  (setq buffer-read-only t)
  (setq mode-name "xig-main")
  (setq buffer-mode 'xig-mode)
  (setq aut-save nil)
  (setq need-not-save nil)
  (use-keymap *xig-main-map*))

(defun quit-xig-mode ()
  (interactive)
  (when (find-buffer "*xig-diff*")
    (xig-quit-diff)
    (return-from quit-xig-mode))
  (delete-pseudo-frame)
;  (delete-other-windows)
  (and (find-buffer "*xig-main*")
       (delete-buffer (find-buffer "*xig-main*")))
  )
