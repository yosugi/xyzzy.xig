; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/diff")
(require "xig/common")
(require "xig/xig")

(defvar *xig-diff-map* nil)
(unless *xig-diff-map*
  (setq *xig-diff-map* (copy-keymap *xig-common-map*))
  (define-key *xig-diff-map* '#\q 'delete-window)
  )

(defun show-diff-info (commit)
  (run-git (format nil "log --stat -p --pretty=fuller -n 1 ~A" commit)))

(defun show-diff ()
  (interactive)
  (let (commit line from to)
    (save-excursion
      (goto-bol)
      (setq from (point))
      (goto-eol)
      (setq to (point))
      (setq line (buffer-substring from to)))
    (if (null (string-match "[0-9a-f]\\{7\\}" line))
        (return-from show-diff))
    (setq commit (match-string 0))
;    (switch-to-buffer "*xig-diff*")
    (pop-to-buffer (get-buffer-create "*xig-diff*")
                   (truncate (* (screen-height) 0.75 -1)) ; -1 ‚Í‰º‚É•ªŠ„‚³‚¹‚é‚½‚ß
                   nil)
    (setq buffer-read-only nil)
    (show-diff-info commit)
    (setq buffer-read-only t)
    (setq mode-name "xig-diff")
    (use-keymap *xig-diff-map*)
    )
  )


