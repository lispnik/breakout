(in-package #:breakout)

(defclass sprite ()
  ((texture :initarg :texture :reader sprite-texture)
   (rect :initarg :rect :reader sprite-rect)
   width
   height))

(defmethod initialize-instance :after ((sprite sprite) &key &allow-other-keys)
  (with-slots (width height texture)
      sprite
    (setf width (sdl2:texture-width texture)
	  height (sdl2:texture-height texture))))

(defgeneric draw (sprite renderer rect))

(defmethod draw ((sprite sprite) renderer rect)
  (sdl2:render-copy renderer
		    (sprite-texture sprite)
		    :source-rect (sprite-rect sprite)
		    :dest-rect rect))

(defvar *sprites* (make-hash-table))

(defun load-textures (renderer)
  (let* ((surface (sdl2:load-bmp "resources.bmp"))
	 (texture (sdl2:create-texture-from-surface renderer surface)))
    (with-open-file (stream #p"resources.sexp")
      (let ((*read-eval* nil))
	(mapcar #'(lambda (resource)
		    (setf (gethash (getf resource :name) *sprites*)
			  (make-instance 'sprite
					 :texture texture
					 :rect (apply #'sdl2:make-rect (getf resource :rect)))))
		(read stream))))))

(defun breakout ()
  (sdl2:with-init (:everything)
    (sdl2:with-window (window :title "Breakout" :w 1680 :h 1050)
      (sdl2:with-renderer (renderer window :flags '(:accelerated :presentvsync))
	(load-textures renderer)
	(sdl2:with-event-loop (:method :poll)
	  (:keydown (:keysym keysym)
		    (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
		      (sdl2:push-event :quit)))
	  (:idle
	   ()
	   (sdl2:render-clear renderer)
	   ;; (sdl2:render-copy renderer texture
	   ;; 		     :source-rect (sdl2:make-rect 0 0 90 40)
	   ;; 		     :dest-rect (sdl2:make-rect 0 0 90 40))
	   ;; (sdl2:render-copy renderer texture
	   ;; 		     :source-rect (sdl2:make-rect 90 0 90 40)
	   ;; 		     :dest-rect (sdl2:make-rect 100 0 90 40))
	   ;; (sdl2:render-copy renderer texture
	   ;; 		     :source-rect (sdl2:make-rect 0 41 128 24)
	   ;; 		     :dest-rect
	   ;; 		     (sdl2:make-rect 0 60 128 24))
	   ;; (sdl2:render-copy renderer texture
	   ;; 		     :source-rect (sdl2:make-rect 0 65 43 45)
	   ;; 		     :dest-rect
	   ;; 		     (sdl2:make-rect 0 200 45 45)
	   ;; 		     )
	   (draw renderer (sprite-texture (gethash :brick *sprites*)) nil)
	   (sdl2:render-present renderer)
	   (sdl2:delay 32))
	  (:quit () t))))))
