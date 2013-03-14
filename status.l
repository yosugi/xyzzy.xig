; xig-mode
; xyzzy interface for git
; written by yosugi

(provide "xig/status")
(in-package "editor")

(require "xig/common")
(require "xig/commit")

(defvar *xig-status-branch-message* "On branch")
(defvar *xig-status-staged-message* "Changes to be committed:")
(defvar *xig-status-unstaged-message* "Changed but not updated:")
(defvar *xig-status-untracked-message* "Untracked files:")
(defvar *xig-status-nofiles-message* "(no files)")

(defvar *xig-status-map* nil)
(unless *xig-status-map*
  (setq *xig-status-map* (copy-keymap *xig-common-map*))
  (define-key *xig-status-map* '#\u 'toggle-stage-file)
  (define-key *xig-status-map* '#\! 'xig-revert-file)
  (define-key *xig-status-map* '#\C 'xig-edit-commit-message)
  (define-key *xig-status-map* '#\q 'xig-quit-status)
  )

(defun show-status-info ()
  (run-git "status --short --branch"))

(defun draw-status ()
  (show-status-info)
  (let (line status file branch-name
             (staged-lines nil)
             (unstaged-lines nil)
             (untracked-lines nil))
    (with-input-from-selected-buffer
      ;; ここでブランチ名取得
      (while (null branch-name)
        (setq line (read-line *standard-input* nil))
        (if (string-match "^##" line)
            (setq branch-name (substring line 3)))
        )
      (while (setq line (read-line *standard-input* nil))
        (when (and (> (length line) 3)
                   (string-match "^[ MARCDU?!]\\{2\\} " line))
          (setq status (substring line 0 2))
          (setq file (substring line 3))
          ;; stage されてる場合
          (unless (or (eq (char status 0) #\SPC)
                      (eq (char status 0) #\?))
            (setq staged-lines
                  (concat staged-lines (format nil "~C   ~A~%" (char status 0) file)))
            )
          ;; stage されない場合
          (unless (or (eq (char status 1) #\SPC)
                      (eq (char status 1) #\?))
            (setq unstaged-lines
                  (concat unstaged-lines (format nil "~C   ~A~%" (char status 1) file)))
            )
          ;; untracked な場合
          (when (eq (char status 0) #\?)
            (setq untracked-lines
                  (concat untracked-lines (format nil "?   ~A~%" file)))
            )
          )
        )
      )
    ;; ここで出力する
    (erase-buffer (selected-buffer))
    (with-output-to-selected-buffer
      (format t "~A ~A~%" *xig-status-branch-message* branch-name) ;; ブランチ名
      (format t "~A~%" *xig-status-staged-message*)
      (format t "~A" (or staged-lines (concat "  " *xig-status-nofiles-message* "\n"))) ;; staed
      (format t "~A~%" *xig-status-unstaged-message*)
      (format t "~A" (or unstaged-lines (concat "  " *xig-status-nofiles-message* "\n"))) ;; unstaged
      (format t "~A~%" *xig-status-untracked-message*)
      (format t "~A" (or untracked-lines (concat "  " *xig-status-nofiles-message* "\n"))) ;; untracked
      )
    (goto-char (point-min))
    )
  )

(defun show-status ()
  (interactive)
  (switch-to-buffer "*xig-status*")
  (delete-other-windows)
  (setup-temp-buffer (selected-buffer))
  (kill-all-local-variables)
  (setq buffer-read-only nil)
  (draw-status)
  (setq buffer-read-only t)
  (setq mode-name "xig-status")
  (use-keymap *xig-status-map*)
  )

;; todo common に移動
(defun get-current-line ()
  (let (from to)
    (save-excursion
      (goto-bol)
      (setq from (point))
      (goto-eol)
      (setq to (point))
      (buffer-substring from to))))

(defun between (x min max)
  (and (>= x min) (<= x max)))

(defun xig-revert-file ()
  (interactive)
  (let ((line (get-current-line))
        file)
    (and (< (length line) 3) (return-from toggle-stage-file))
    (and (eq (char line 0) #\SPC) (return-from toggle-stage-file))
    (or (eq (char line 1) #\SPC) (return-from toggle-stage-file))
    (setq file (substring line 4))

    (let (begin-staged-point begin-unstaged-point begin-untracked-point)
      (save-excursion
        ;; 必ずブランチ名、staged エリア、unstaged エリア、untracked エリアの順なので
        ;; いちいち (goto-char (point-min)) しなくてよい
        (goto-char (point-min))
        (scan-buffer *xig-status-staged-message*)
        (setq begin-staged-point (point))
        (scan-buffer *xig-status-unstaged-message*)
        (setq begin-unstaged-point (point))
        (scan-buffer *xig-status-untracked-message*)
        (setq begin-untracked-point (point))
        )
      (cond
       ((between (point) begin-staged-point begin-unstaged-point)
        (msgbox "Cannot revert changes to staged files"))
       ((between (point) begin-unstaged-point begin-untracked-point)
        (when (yes-no-or-cancel-p "~A" "Are you sure you want to revert changes?")
          (setq buffer-read-only nil)
          (run-git (format nil "checkout -- ~A" file))
          (show-status)
          )
        )
       ((between (point) begin-untracked-point (point-max))
        (msgbox "Cannot revert changes to untracked files"))
       )
      ))
  )

; toggle stage and unstage (or add)
(defun toggle-stage-file ()
  (interactive)
  (let ((line (get-current-line))
        status file)
    (and (< (length line) 3) (return-from toggle-stage-file))
    (and (eq (char line 0) #\SPC) (return-from toggle-stage-file))
    (or (eq (char line 1) #\SPC) (return-from toggle-stage-file))

    ;; 1. ファイル名取得
    (setq file (substring line 4))
    
    ;; 2. ステータス取得
    ;; 2.1 現在のポイントがどこか調査 (point)
    (let (begin-staged-point begin-unstaged-point begin-untracked-point)
      (save-excursion
        ;; 必ずブランチ名、staged エリア、unstaged エリア、untracked エリアの順なので
        ;; いちいち (goto-char (point-min)) しなくてよい
        (goto-char (point-min))
        (scan-buffer *xig-status-staged-message*)
        (setq begin-staged-point (point))
        (scan-buffer *xig-status-unstaged-message*)
        (setq begin-unstaged-point (point))
        (scan-buffer *xig-status-untracked-message*)
        (setq begin-untracked-point (point))
        )
      (cond
       ((between (point) begin-staged-point begin-unstaged-point)
        (setq buffer-read-only nil)
        (call-git (format nil "reset HEAD ~A" file))
        (show-status)
        (scan-buffer file)
        )
       ((between (point) begin-unstaged-point (point-max))
        (setq buffer-read-only nil)
        (if (eq (char line 0) #\D)
            (call-git (format nil "rm ~A" file))
          (call-git (format nil "add ~A" file)))
        (show-status)
        (scan-buffer file)
        )
       )
      )
    ))

(defun xig-quit-status ()
  (interactive)
  (switch-to-buffer "*xig-main*")
  (delete-other-windows)
  (and (find-buffer "*xig-status*")
       (delete-buffer (find-buffer "*xig-status*")))
  )

