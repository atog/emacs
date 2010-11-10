; enable Common Lisp support
(require 'cl)

; some modes need to call stuff on the exec-path
(push "/usr/local/bin" exec-path)

; add directories to the load path
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/customizations")
(add-to-list 'load-path "~/.emacs.d/utilities")
(add-to-list 'load-path "~/.emacs.d/vendor")

; handy function to load all elisp files in a directory
(load-file "~/.emacs.d/load-directory.el")

; load utility functions
(mapcar 'load-directory '("~/.emacs.d/utilities"))

; load third-party modes
; note: these are configured in customizations/my-modes.el
(vendor 'color-theme)
(vendor 'textmate)
(vendor 'peepopen)
(vendor 'centered-cursor-mode)
(vendor 'browse-kill-ring)
(vendor 'yaml-mode)
(vendor 'full-ack)
(vendor 'magit)
(vendor 'dired+)
(vendor 'minimap)
(vendor 'smart-tab)
(vendor 'inf-ruby)
(vendor 'ruby-hacks)
(vendor 'wrap-region)
(vendor 'enclose)

; load third-party modes that the vendor function can't handle
(add-to-list 'load-path "~/.emacs.d/vendor/js2")

; rhtml
(add-to-list 'load-path "~/.emacs.d/vendor/rhtml")
(require 'rhtml-mode)

; load personal customizations (keybindings, colors, etc.)
(mapcar 'load-directory '("~/.emacs.d/customizations"))
