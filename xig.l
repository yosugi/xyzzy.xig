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
(defvar *xig-shortlog-has-graph* nil "shortlog をグラフで表示しているか")
(defvar *xig-git-shortlog-command* "log --pretty=format:\"%h %ci %an %d %s\"" "shortlog を表示する時のコマンド")
(defvar *xig-git-shortlog-graph-command* (concat *xig-git-shortlog-command* " " "--graph"))

(defvar *xig-main-map* nil)
(unless *xig-main-map*
  (setq *xig-main-map* (copy-keymap *xig-common-map*))
  (define-key *xig-main-map* '#\R 'xig-show-shortlog)
  (define-key *xig-main-map* '#\g 'xig-toggle-shortlog-graph)
  (define-key *xig-main-map* '#\RET 'show-diff)
  (define-key *xig-main-map* '#\S 'show-status)
  (define-key *xig-main-map* '#\q 'xig-quit-mode)
  )

(defun show-version ()
  (interactive)
  (run-git "--version"))

(defun xig-show-shortlog ()
  (interactive)
  (setq buffer-read-only nil)
  (run-git *xig-git-shortlog-command*)
  (save-excursion
    (goto-char (point-max))
    (with-output-to-selected-buffer
      (format t "~%")))
  (setq buffer-read-only t)
  )

(defun xig-toggle-shortlog-graph ()
  (interactive)
  (setq buffer-read-only nil)
  (cond
   ((null *xig-shortlog-has-graph*)
    (run-git *xig-git-shortlog-graph-command*)
    (setq *xig-shortlog-has-graph* t))
   (t
    (run-git *xig-git-shortlog-command*)
    (setq *xig-shortlog-has-graph* nil)))
    (save-excursion
    (goto-char (point-max))
    (with-output-to-selected-buffer
      (format t "~%")))
  )

(defun xig-mode ()
  (interactive)
  (select-pseudo-frame
   (or (find-pseudo-frame *xig-pframe-name*)
       (new-pseudo-frame *xig-pframe-name*)))
  (switch-to-buffer "*xig-main*")
  (kill-all-local-variables)
  (setup-temp-buffer (selected-buffer))
  (set-buffer-modified-p nil)
  (setq auto-save nil)
  (setq need-not-save nil)
  (setq mode-name "xig-main")
  (setq buffer-mode 'xig-mode)
  (use-keymap *xig-main-map*)
  (xig-show-shortlog)
  (setq buffer-read-only t))

(defun xig-quit-mode ()
  (interactive)
  (when (find-buffer "*xig-diff*")
    (xig-quit-diff)
    (return-from xig-quit-mode))
  (delete-pseudo-frame)
  (mapcar #'(lambda (buffer-name)
              (if (find-buffer buffer-name)
                  (delete-buffer (find-buffer buffer-name))))
          '("*xig-main*" "*xig-commit*" "*xig-diff*" "*xig-status*")))
