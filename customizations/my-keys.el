; magit
(global-set-key (kbd "C-c i") 'magit-status)

; Make yes-or-no questions answerable with 'y' or 'n'
(fset 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "C-x p") 'defunkt-ido-find-project)

; Full screen mode
(global-set-key [f5] 'ns-toggle-fullscreen)

(setq default-input-method "MacOSX")

; option/alt is meta key
(setq mac-command-key-is-meta nil)

; switch to shell
(global-set-key (kbd "s-0") 'ansi-term)

; search with ack
(global-set-key (kbd "s-F") 'ack)

; open file
(global-set-key [(super o)] 'find-file)

; buffer switching
(global-set-key [(super {)] 'previous-buffer)
(global-set-key [(super })] 'next-buffer)

; window switching
(global-set-key (kbd "s-`") 'other-window)

; close window
(global-set-key [(super w)] (lambda ()
  (interactive)
  (kill-buffer (current-buffer)
)))

; navigating through errors
(global-set-key [(meta n)] 'next-error)
(global-set-key [(meta p)] 'previous-error)
