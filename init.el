;; emacs configuration
(push "/usr/local/bin" exec-path)
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/utilities")
(add-to-list 'load-path "~/.emacs.d/vendor")

; handy function to load all elisp files in a directory
(load-file "~/.emacs.d/load-directory.el")
; load utility functions
(mapcar 'load-directory '("~/.emacs.d/utilities"))

(defun smart-tab-hook ()
	(require 'smart-tab)
	(global-smart-tab-mode 1)
	(setq smart-tab-using-hippie-expand nil))

(defun magit-hook ()
	(autoload 'magit-status "magit" nil t)
	(eval-after-load 'magit
	  '(setq magit-process-connection-type nil)))

(defun full-ack-hook ()
	(autoload 'ack-same "full-ack" nil t)
	(autoload 'ack "full-ack" nil t)
	(autoload 'ack-find-same-file "full-ack" nil t)
	(autoload 'ack-find-file "full-ack" nil t))

(require 'flymake)
;; Invoke ruby with '-c' to get syntax checking
(defun flymake-ruby-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
	 (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list ruby-compilation-executable (list "-c" local-file))))

(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)

(defun ruby-mode-hook ()
  (autoload 'ruby-mode "ruby-mode" nil t)
  (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-mode))
  (add-hook 'ruby-mode-hook '(lambda ()
                              (add-hook 'local-write-file-hooks
                                '(lambda()
                                   (save-excursion
                                     (untabify (point-min) (point-max)))))
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (setq c-tab-always-indent nil)
                               (require 'inf-ruby)
                               (require 'ruby-compilation)
														   (flymake-mode t)
                               (define-key ruby-mode-map "\C-m" 'ruby-reindent-then-newline-and-indent)
                               (define-key ruby-mode-map (kbd "s-r") 'run-rails-test-or-ruby-buffer))))
(defun rhtml-mode-hook ()
  (autoload 'rhtml-mode "rhtml-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . rhtml-mode))
  (add-to-list 'auto-mode-alist '("\\.rjs\\'" . rhtml-mode))
  (add-hook 'rhtml-mode '(lambda ()
                           (define-key rhtml-mode-map (kbd "M-s") 'save-buffer))))

(defun yaml-mode-hook ()
  (autoload 'yaml-mode "yaml-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode)))

(defun coffee-mode-hook ()
  (add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
  (add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))
)

(defun css-mode-hook ()
  (autoload 'css-mode "css-mode" nil t)
  (add-hook 'css-mode-hook '(lambda ()
                              (setq css-indent-level 2)
                              (setq css-indent-offset 2))))
(defun is-rails-project ()
  (when (textmate-project-root)
    (file-exists-p (expand-file-name "config/environment.rb" (textmate-project-root)))))

(defun run-rails-test-or-ruby-buffer ()
  (interactive)
  (if (is-rails-project)
      (let* ((path (buffer-file-name))
             (filename (file-name-nondirectory path))
             (test-path (expand-file-name "test" (textmate-project-root)))
             (command (list ruby-compilation-executable "-I" test-path path)))
        (pop-to-buffer (ruby-compilation-do filename command)))
    (ruby-compilation-this-buffer)))

(defun ruby-reindent-then-newline-and-indent ()
  "Reindents the current line then creates an indented newline."
  (interactive "*")
  (newline)
  (save-excursion
    (end-of-line 0)
    (indent-according-to-mode)
    (delete-region (point) (progn (skip-chars-backward " \t") (point))))
  (when (ruby-previous-line-is-comment)
      (insert "# "))
  (indent-according-to-mode))

(defun ruby-previous-line-is-comment ()
  "Returns `t' if the previous line is a Ruby comment."
  (save-excursion
    (forward-line -1)
    (ruby-line-is-comment)))

(defun ruby-line-is-comment ()
  "Returns `t' if the current line is a Ruby comment."
  (save-excursion
    (beginning-of-line)
    (search-forward "#" (point-at-eol) t)))

(require 'package)
(setq package-archives (cons '("tromey" . "http://tromey.com/elpa/") package-archives))
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/el-get")
(require 'el-get)

(setq el-get-sources
      '((:name ruby-mode
               :type elpa
               :load "ruby-mode.el"
               :after (lambda () (ruby-mode-hook)))
        (:name inf-ruby  :type elpa)
        (:name ruby-compilation :type elpa)
        (:name textmate :type elpa)
        (:name css-mode
               :type elpa
               :after (lambda () (css-mode-hook)))
        (:name rvm
               :type git
               :url "http://github.com/djwhitt/rvm.el.git"
               :load "rvm.el"
               :compile ("rvm.el")
               :after (lambda() (rvm-use-default)))
        (:name rhtml
               :type git
               :url "https://github.com/eschulte/rhtml.git"
               :features rhtml-mode
               :after (lambda () (rhtml-mode-hook)))
        (:name yaml-mode
               :type git
               :url "http://github.com/yoshiki/yaml-mode.git"
               :features yaml-mode
               :after (lambda () (yaml-mode-hook)))
        (:name coffee-mode
               :type git
               :url "https://github.com/defunkt/coffee-mode.git"
               :features coffee-mode
               :after (lambda () (coffee-mode-hook)))
        (:name full-ack
							 :type git
               :url "https://github.com/nschum/full-ack.git"
							 :after (lambda () (full-ack-hook)))
        (:name smart-tab
					     :type elpa
					     :after (lambda () (smart-tab-hook)))
        (:name magit
					     :type elpa
					     :after (lambda () (magit-hook)))
	))
(el-get 'sync)

(vendor 'peepopen)
(vendor 'browse-kill-ring)
(vendor 'dired+)
(vendor 'ruby-hacks)
(vendor 'wrap-region)
(vendor 'enclose)

;load without el-get
(add-to-list 'load-path "~/.emacs.d/vendor/js2")
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(enclose-global-mode t)
(wrap-region-global-mode t)
(textmate-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-safe-themes (quote ("9cdf9fb94f560902b567b73f65c2ed4e5cfbaafe" "b03af7ef60f7163c67e0984d0a54082d926f74ac" "538ca36fbe9aed79b0c25c920cc7e5e803f17c6e" "30a309a1ee4f7ef694a3d7aaf6ffe283f69f95c8" "15fb47d2d6174fbc121e60f8910972b7a31fa9ce" "32506acca0fec7e614b57e33479c293ccb094cb6" "1494a5822eb00d2131aae3e8d00ffb8f226cb4e7" "52cff4fb76c719ea2377a24d3735bd0392a7f23f" "13413be5555f02db1898534f146c4eceb5997261" "2dc8cbf44dbc8532764a313374230ca013b35483" "835bfbbdbaae344d72b4e4104c2dbb42a356bf64" "3645b359306b0c7faa20f214fec51b01d8a07943" "fb134a4f65583f30c0daef6c9dbdcdd77abc06cd" "4c678543155096aee21a09e05a7a22b5069b8f6c" "0f961414492755477a573f7be8d6d84b6a73d96a" "170afc082ac58caa1ba045c21bb822df3961eb31" "157c197325b7249946f056ef86617b05811c818f" "e34496468df6d75fa904e90d9d6eb838531fca2b" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:foreground "#559944"))) t)
 '(diff-context ((t nil)) t)
 '(diff-file-header ((((class color) (min-colors 88) (background dark)) (:foreground "RoyalBlue1"))) t)
 '(diff-function ((t (:foreground "#00bbdd"))) t)
 '(diff-header ((((class color) (min-colors 88) (background dark)) (:foreground "RoyalBlue1"))) t)
 '(diff-hunk-header ((t (:foreground "#fbde2d"))) t)
 '(diff-nonexistent ((t (:inherit diff-file-header :strike-through nil))) t)
 '(diff-refine-change ((((class color) (min-colors 88) (background dark)) (:background "#182042"))) t)
 '(diff-removed ((t (:foreground "#de1923"))) t)
 '(flymake-errline ((t :underline "red")))
 '(flymake-warnline ((t :underline "green"))))

; load personal customizations (keybindings, colors, etc.)
(mapcar 'load-directory '("~/.emacs.d/customizations"))
