; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/common")

(defvar *xig-common-map* nil)
(unless *xig-common-map*
  (setq *xig-common-map* (make-sparse-keymap))
  (define-key *xig-common-map* '#\h 'backward-char)
  (define-key *xig-common-map* '#\j 'next-line)
  (define-key *xig-common-map* '#\k 'previous-line)
  (define-key *xig-common-map* '#\l 'forward-char)
  (define-key *xig-common-map* '#\0 #'(lambda () (interactive) (goto-bol)))
  (define-key *xig-common-map* '#\$ #'(lambda () (interactive) (goto-eol)))
  (define-key *xig-common-map* '#\g #'(lambda () (interactive) (goto-char (point-min))))
  (define-key *xig-common-map* '#\G #'(lambda () (interactive) (goto-char (point-max)) (goto-bol)))
  (define-key *xig-common-map* '#\TAB 'other-window)
  )

(defun run-git (command &optional (buffer (selected-buffer)))
  (execute-shell-command
   (concat (map-slash-to-backslash (get-short-path-name *xig-git-path*)) " " command)
   nil
   buffer))
