(in-package #:cl-user)

(defpackage #:gun-janitor
  (:local-nicknames
   (#:u #:vutils))
  (:use #:cl)
  (:export
   #:start))

(uiop:define-package #:gun-janitor.shader
  (:use #:colony.shader)
  (:export
   #:atlas-shdr
   ))

(colony.nicknames:define-nicknames
  (:gun-janitor :proj)
  (:gun-janitor.shader :proj/shd))
