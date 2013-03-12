; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/diff")
(require "xig/common")
(require "xig/xig")

(export '(*xig-diff-window-ratio*))

(defvar *xig-diff-window-ratio* 0.75 "diff ‚ðŠJ‚­”ä—¦")

(defvar *xig-diff-map* nil)
(unless *xig-diff-map*
  (setq *xig-diff-map* (copy-keymap *xig-common-map*))
  (define-key *xig-diff-map* '#\q 'quit-xig-diff)
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
    (or (string-match "[0-9a-f]+" line)
        (return-from show-diff))
    (setq commit (match-string 0))
    (pop-to-buffer (get-buffer-create "*xig-diff*")
                   (truncate (* (screen-height) *xig-diff-window-ratio* -1)) ; -1 ‚Í‰º‚É•ªŠ„‚³‚¹‚é‚½‚ß
                   nil)
    (kill-all-local-variables)
    (setq buffer-read-only nil)
    (show-diff-info commit)
    (setq buffer-read-only t)
    (setq mode-name "xig-diff")
    (use-keymap *xig-diff-map*)
    (other-window)
    )
  )

(defun quit-xig-diff ()
  (interactive)
  (switch-to-buffer "*xig-main*")
  (delete-other-windows)
  (and (find-buffer "*xig-diff*")
       (delete-buffer (find-buffer "*xig-diff*")))
  )

