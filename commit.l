; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/commit")
(in-package "editor")

(require "xig/common")

(defvar *xig-commit-message* "# Please enter the commit message for your changes. Lines starting\n# with '#' will be ignored, and an empty message aborts the commit.")

(defvar *xig-commit-map* nil)
(unless *xig-commit-map*
  (setq *xig-commit-map* (make-keymap))
  (define-key *xig-commit-map* '(#\C-c #\C-c) 'xig-do-commit)
  (define-key *xig-commit-map* '#\C-g 'xig-cancel-commit))

(defun draw-commit-message ()
  (run-git "commit --dry-run"))

(defun xig-edit-commit-message ()
  (interactive)
  (switch-to-buffer "*xig-commit*")
;  (delete-other-windows)
  (kill-all-local-variables)
  (setq need-not-save t)
  (setq auto-save nil)
  (set-buffer-modified-p nil)
  (draw-commit-message)
  (replace-buffer "^\\([^#].*\n\\)" "## \\1" :regexp t) ; ワーニングが出たら ## の後に表示しとく
  (goto-char (point-min))
  (save-excursion
    (with-output-to-selected-buffer
      (format t "~%")
      (format t "~A~%" *xig-commit-message*)))
  (setq mode-name "xig-commit")
  (use-keymap *xig-commit-map*)
  )

(defun xig-do-commit ()
  (interactive)
  (let ((tempfile (make-temp-file-name)))
    (save-excursion
      (replace-buffer "^#.*\n"  "" :regexp  t) ;; コメント行の削除
      (write-region (point-min) (point-max)
                    tempfile
                    nil
                    *encoding-utf8n*))
    (unwind-protect
        (run-git (format nil "commit -F ~A" tempfile))
      (delete-file tempfile))
    (read-string "Press Enter to continue: ")
    (show-status)))

(defun xig-cancel-commit ()
  (interactive)
  (when (yes-or-no-p "cancel commit?")
    (switch-to-buffer "*xig-status*")
    (delete-other-windows)
    (and (find-buffer "*xig-commit*")
         (delete-buffer (find-buffer "*xig-commit*")))))

