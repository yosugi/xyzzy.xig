; xig-mode
; xyzzy interface for git
; author yosugi

(provide "xig/diff")

(require "xig/common")
(require "xig/xig")

(in-package "xig")

(export '(*xig-diff-window-ratio*))

(defconstant *xig-diff-buffer-name* "*xig-diff*" "diff バッファ名")
(defconstant *xig-diff-window-ratio* 0.70 "diff を開く比率")

(defvar *xig-diff-map* nil)
(unless *xig-diff-map*
  (setq *xig-diff-map* (copy-keymap *xig-common-map*))
  (define-key *xig-diff-map* '#\q 'xig-diff-quit)
  )

(defun xig-diff-commit (commit)
  (interactive)
  (xig-diff-show (format nil "log --stat -p --pretty=fuller -n 1 ~A" commit))
  )

(defun xig-diff-all (&key (cached nil))
  (let ((cmd "diff --stat -p --pretty=fuller"))
    (if cached (setq cmd (format nil "~A ~A" cmd "--cached")))
    (message cmd)
    (xig-diff-show cmd)))

(defun xig-diff-file (file &key (cached nil))
  (let ((cmd "diff"))
    (if cached (setq cmd (format nil "~A ~A" cmd "--cached")))
    (setq cmd (format nil "~A ~A" cmd file))
    (xig-diff-show cmd)))

(defun xig-diff-show (cmd)
  (pop-to-buffer (get-buffer-create *xig-diff-buffer-name*)
                 (truncate (* (screen-height) *xig-diff-window-ratio* -1)) ; -1 は下に分割させるため
                 nil)
  (kill-all-local-variables)
  (setq buffer-read-only nil)
  (xig-run-git cmd)
  (setq buffer-read-only t)
  (setq mode-name "xig-diff")
  (use-keymap *xig-diff-map*))

(defun xig-diff-quit ()
  (interactive)
  (other-window)
  (delete-other-windows)
  (if (find-buffer *xig-diff-buffer-name*)
      (delete-buffer (find-buffer *xig-diff-buffer-name*)))
  )

