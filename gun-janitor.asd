;; CL gives much freedom for how to organize your project, but V requires some
;; things to be ordered in the API, so this skeleton project give a suggested
;; method of dependencies to make it easier to deal with both the required
;; dependencies and the freedom CL provides.

;; NOTE: Currently the engine requires the below dependencies due to the
;; validity checking during macro expansion time, some of that should be moved
;; to runtime which will get rid of these dependencies, but it will change in
;; the future.

(asdf:defsystem #:gun-janitor
  :description "A small shmup game."
  :author "Peter Keller <psilord@disaffectedhuman.com>"
  :maintainer "Peter Keller <psilord@disaffectedhuman.com>"
  :license "MIT"
  :version "0.1.0"
  :depends-on (#:colony)
  :pathname "src"
  :serial t
  :components
  ((:file "package")

   (:file "engine-config")

   ;; Almost all of your non-component code, generic functions, classes,
   ;; structures, macros, math / utility functions, etc goes into this
   ;; directory. A lot of your code will reside here.
   (:module "base"
    :serial t
    :components
    ((:file "math-utilities")))

   ;; Subdirectory that contains many definitions of entities in your code.
   (:module "definitions"
    :serial t
    :components
    (;; The shader definitions must exist before materials can use them.
     (:module "shaders"
      :serial t
      :components
      ((:file "sprite-shader")))

     ;; define-texture forms go in here.
     (:module "textures"
      :serial t
      :components
      ((:file "textures")))

     ;; define-material forms go in here.
     (:module "materials"
      :serial t
      :components
      ((:file "materials")))

     ;; define-component (but NOT component methods) forms go in here.
     (:module "components"
      :serial t
      :components
      ((:file "flip-material")
       (:file "direction-mover")
       (:file "tags")
       (:file "sketch")
       (:file "delayed-render")
       (:file "player-mover")
       (:file "projectile")
       (:file "gun")))))

   ;; Your component methods all go here. In general, another large chunk of
   ;; game code resides here.
   (:module "components"
    :serial t
    :components
    (;; This is support code that the component protocols will have.
     (:module "common"
      :serial t
      :components ())

     ;; Then the protocol methods of the components.
     (:file "flip-material")
     (:file "direction-mover")
     (:file "tags")
     (:file "sketch")
     (:file "delayed-render")
     (:file "player-mover")
     (:file "projectile")
     (:file "gun")))

   ;; All prefabs go in here. a prefab must be defined before it is referenced.
   ;; define-prefabs and define-model will go in here, ordered among themselves
   ;; as necessary.
   (:module "prefabs"
    :serial t
    :components
    ((:file "common")
     (:file "v-cube"))) ;; TODO and remove the auto-rotate here.

   ;; Prologue, epilogue, root level prefabs, and whatever else that needs all
   ;; the things before it as a dependency go here. Proedurally generating
   ;; something defined above will probably go here. Depending on the kind of
   ;; game you have, there might or might not be large amounts of code here.
   (:module "top"
    :serial t
    :components
    ((:file "gun-janitor")))))
