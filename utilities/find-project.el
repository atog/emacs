(defun defunkt-ido-find-project ()
  (interactive)
  (find-file
   (concat "~/Working/rails/" (ido-completing-read "Project: "
                           (directory-files "~/Working/rails/" nil "^[^.]")))))