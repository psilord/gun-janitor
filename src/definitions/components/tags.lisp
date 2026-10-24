(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: Tags (candidate component for core FL)
;;
;; This component is a registration system for tag symbols that we can insert
;; into this component. This allows us to locate all actors with a certain tag,
;; or query if an actor currently has a certain tag.
;;
;; ;;;;;;;;;

(c:define-component tags ()
  (;; TODO: Technically, this is for initialization only.  I should rename it.
   ;; Also the tags only are present if this component is attached to something.
   ;; So, when looking for "does this component have this tag" I shouldn't just
   ;; MEMBER it out of this list, cause that isn't the point.
   (%tags :accessor tags
          :initarg :tags
          :initform nil))
  ;; In this storage, we keep an association between a tag and the actor set
  ;; which uses it, and form each actor to the tag set it has. This allows
  ;; extremely fast lookups in either direction.
  ((:db eq)))
