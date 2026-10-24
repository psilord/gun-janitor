(in-package #:gun-janitor)

(c:define-texture v-letter (:texture-2d x:clamp-all-edges)
  ;; TODO: TMAP Fix this to use the texture-map name.
  (:data #((textures v-letter))))

;; TODO: Why is it that when I added the bkgnd-test.png to the
;; data/textures directory, created this form, the material form, and
;; updated the define-prefab to use it, then C-c C-c everything in the
;; right order, the asset system could not find the image until I had
;; _restarted the image_.
;;
;; I suspect it is because I needed to C-c C-c the define-asset-pool
;; form for the textures pool so it can re-read the files. Can I do
;; better here and have Colony notice when a texture changes to find the
;; asset pool that it is using and rebuild the asset-pool definition
;; during live coding?
(c:define-texture bkgnd-test (:texture-2d x:clamp-all-edges)
  (:texture-min-filter :nearest)
  (:texture-mag-filter :nearest)
  ;; (:use-mipmaps nil)
  (:data #((textures bkgnd-test))))

(c:define-texture level-0 (:texture-2d x:clamp-all-edges)
  (:texture-min-filter :nearest)
  (:texture-mag-filter :nearest)
  ;; (:use-mipmaps nil)
  (:data #((textures level-0))))

(c:define-texture sprite-atlas (:texture-2d)
  (:texture-min-filter :nearest)
  (:texture-mag-filter :nearest)
  (:data #((textures atlas))))
