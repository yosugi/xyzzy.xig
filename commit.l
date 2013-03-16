; xig-mode
; xyzzy interface for git
; author yosugi

(provide "xig/commit")

(require "xig/common")

(in-package "xig")

(defvar *xig-commit-message* "# Please enter the commit message for your changes. Lines starting\n# with '#' will be ignored, and an empty message aborts the commit.")

(defvar *xig-commit-map* nil)
(unless *xig-commit-map*
  (setq *xig-commit-map* (make-keymap))
  (define-key *xig-commit-map* '(#\C-c #\C-c) 'xig-commit-execute)
  (define-key *xig-commit-map* '#\C-g 'xig-commit-cancel))

(defun xig-commit-edit-message ()
  (interactive)
  (switch-to-buffer "*xig-commit*")
  (kill-all-local-variables)
  (setq need-not-save t)
  (setq auto-save nil)
  (set-buffer-modified-p nil)
  (xig-run-git "commit --dry-run")
  (replace-buffer "^\\([^#].*\n\\)" "## \\1" :regexp t) ; ワーニングが出たら ## の後に表示しとく
  (goto-char (point-min))
  (save-excursion
    (with-output-to-selected-buffer
      (format t "~%")
      (format t "~A~%" *xig-commit-message*)))
  (setq mode-name "xig-commit")
  (use-keymap *xig-commit-map*)
  )

(defun xig-commit-execute ()
  (interactive)
  (let ((tempfile (make-temp-file-name)))
    (save-excursion
      (replace-buffer "^#.*\n"  "" :regexp  t) ;; コメント行の削除
      (write-region (point-min) (point-max)
                    tempfile
                    nil
                    *encoding-utf8n*))
    (unwind-protect
        (xig-run-git (format nil "commit -F ~A" tempfile))
      (delete-file tempfile))
    (read-string "Press Enter to continue: ")
    (xig-status-show)))

(defun xig-commit-cancel ()
  (interactive)
  (when (yes-or-no-p "cancel commit?")
    (switch-to-buffer "*xig-status*")
    (delete-other-windows)
    (and (find-buffer "*xig-commit*")
         (delete-buffer (find-buffer "*xig-commit*")))))

