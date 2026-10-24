(in-package #:gun-janitor)

;; private API (probably)
(defun tags-refs (context)
  ;; Create the DB if not present.
  (c:with-storage
      (context context)
      ((tag->actors tag->actors/present-p ('tags :db :tag->actors)
                    ;; key: tag, Value: hash table of actor -> actor
                    (u:dict #'eq))
       (actor->tags actor->tags/present-p ('tags :db :actor->tags)
                    ;; Key: actor, Value: hash table of tag -> tag
                    (u:dict #'eq)))
    (values tag->actors actor->tags)))

(defmethod c:on-component-initialize ((self tags))
  ;; Seed the storage cache. We're modifying the tags list, so copy-seq it to
  ;; ensure it isn't a quoted list.
  (setf (tags self) (copy-seq (tags self)))
  (tags-refs (c:context self)))

;; private API
(defun %tags-add (self &rest adding-tags)
  (with-accessors ((context c:context) (actor c:actor)) self
    (u:mvlet ((tag->actors actor->tags (tags-refs context)))
      (dolist (tag adding-tags)
        ;; Add a tag -> actor set link
        (unless (u:href tag->actors tag)
          (setf (u:href tag->actors tag) (u:dict #'eq)))
        (setf (u:href tag->actors tag actor) actor)
        ;; Add an actor -> tag set link
        (unless (u:href actor->tags actor)
          (setf (u:href actor->tags actor) (u:dict #'eq)))
        (setf (u:href actor->tags actor tag) tag)))))

;; public API
(defun tags-add (self &rest tags)
  "Uniquely add a set of TAGS to the current tags in the SELF instance which
must be a TAGS component."
  (dolist (tag tags)
    (pushnew tag (tags self)))
  (apply #'%tags-add tags))

;; private API
(defun %tags-remove (self &rest removing-tags)
  (with-accessors ((context c:context) (actor c:actor)) self
    (u:mvlet ((tag->actors actor->tags (tags-refs context)))
      (dolist (tag removing-tags)
        ;; Remove the tag -> actor set link
        (remhash tag (u:href actor->tags actor))
        (when (zerop (hash-table-count (u:href actor->tags actor)))
          (remhash actor actor->tags))
        ;; Remove the actor -> tag set link
        (remhash actor (u:href tag->actors tag))
        (when (zerop (hash-table-count (u:href tag->actors tag)))
          (remhash tag tag->actors))))))

;; public API
(defun tags-remove (self &rest tags)
  "Remove all specified tags from the set of TAGS from the current tags in the
SELF instance which must be a TAGS component."
  (dolist (tag tags)
    (setf (tags self) (remove tag (tags self))))
  (apply #'%tags-remove tags))

;; public API
(defmethod tags-has-tag-p ((self tags) query-tag)
  "Return T if the SELF tags component contains the QUERY-TAG."
  (with-accessors ((context c:context) (actor c:actor)) self
    (u:mvlet ((tag->actors actor->tags (tags-refs context)))
      (u:href actor->tags actor query-tag))))

;; public API
(defmethod tags-has-tag-p ((self c:actor) query-tag)
  "Return T if there is a tags component on the SELF actor and it also
contains the QUERY-TAG."
  (u:when-let ((tags-component (c:component-by-type self 'tags)))
    (tags-has-tag-p tags-component query-tag)))

;; public API
(defun tags-find-actors-with-tag (context query-tag)
  "Return a list of actors that are tagged with the QUERY-TAG. Return
NIL if no such list exists."
  (u:mvlet ((tag->actors actor->tags (tags-refs context)))
    (u:when-let ((actors (u:href tag->actors query-tag)))
      (u:hash-keys actors))))

(defmethod c:on-component-attach ((self tags) actor)
  (with-accessors ((context c:context) (actor c:actor) (tags tags)) self
    (dolist (tag tags)
      (%tags-add self tag))))

(defmethod c:on-component-detach ((self tags) actor)
  ;; NOTE: all components are detached before they are destroyed.
  (with-accessors ((context c:context) (actor c:actor) (tags tags)) self
    (dolist (tag tags)
      (%tags-remove self tag))))
