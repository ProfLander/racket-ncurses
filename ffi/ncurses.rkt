#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/cvector)

(provide (all-defined-out))

;;; Basic definitions

(define _chtype  _ulong)
(define _wint _int32)
(define _chstr   _cvector)
(define _mmask_t _ulong)
(define _attr_t  _ulong)
(define _pair_t  _short)

(define _wstring
  (if (eq? (system-type) 'windows)
      _string/utf-16
      _string/ucs-4))

(define (chlist->chstr chars) 
  (list->cvector (append chars '(0)) _chtype))

(define _SCREEN-pointer (_cpointer 'SCREEN))
(define _WINDOW-pointer (_cpointer 'WINDOW))

;;; Libc definitions

(define _FILE-pointer (_cpointer 'FILE))

(define libc (ffi-lib #f))

(define stdout
  (get-ffi-obj "stdout" libc _FILE-pointer))

(define stdin
  (get-ffi-obj "stdin" libc _FILE-pointer))

;;; Curses definitions

(define libncursesw (ffi-lib "libncursesw" '("6" #f)))

(define-ffi-definer define-curses libncursesw)

;; Structs

; Styled wide character

(define-cstruct _cchar_t ([attr _attr_t] 
                          [wchar (make-array-type _wchar 5)]
                          [ext_color _int]))

(define-curses getcchar (_fun (cchar : (_ptr i _cchar_t-pointer))
                              (wchar : (_ptr o _wchar))
                              (attr : (_ptr o _attr_t))
                              (pair : (_ptr o _pair_t))
                              (ptr : (_ptr o _pointer))
                              -> _int -> (values wchar attr pair ptr)))

(define-curses setcchar (_fun (cchar : (_ptr o _cchar_t))
                              (wchar : (_ptr i _wchar))
                              (attr : _attr_t)
                              (pair : _pair_t)
                              (ptr : (_ptr i _pointer))
                              -> _int -> cchar))

; Mouse event

(define-cstruct _MEVENT ([id _short]
                         [x _int]
                         [y _int]
                         [z _int]
                         [bstate _mmask_t]))

;; Globals

(define (stdscr)
  (get-ffi-obj "stdscr" libncursesw _WINDOW-pointer))

(define (curscr)
  (get-ffi-obj "curscr" libncursesw _WINDOW-pointer))

(define (newscr)
  (get-ffi-obj "newscr" libncursesw _WINDOW-pointer))

(define (ttytype)
  (get-ffi-obj "ttytype" libncursesw _string))

(define (COLORS)
  (get-ffi-obj "COLORS" libncursesw _int))

(define (COLOR_PAIRS)
  (get-ffi-obj "COLOR_PAIRS" libncursesw _int))

(define (COLS)
  (get-ffi-obj "COLS" libncursesw _int))

(define (ESCDELAY)
  (get-ffi-obj "ESCDELAY" libncursesw _int))

(define (LINES)
  (get-ffi-obj "LINES" libncursesw _int))

(define (TABSIZE)
  (get-ffi-obj "TABSIZE" libncursesw _int))

(define-curses COLOR_PAIR (_fun _int -> _int))

(define-curses newterm (_fun (type : _string)
                             (outfd : _FILE-pointer)
                             (infd : _FILE-pointer)
                             -> _SCREEN-pointer))

;; Screen

; Constructors

(define-curses newwin_sp (_fun _SCREEN-pointer _int _int _int _int -> _WINDOW-pointer))
(define-curses newpad_sp (_fun _SCREEN-pointer _int _int -> _WINDOW-pointer))

; Predicates

(define-curses has_colors_sp (_fun _SCREEN-pointer -> _bool))
(define-curses has_mouse_sp (_fun _SCREEN-pointer -> _bool))
(define-curses can_change_color_sp (_fun _SCREEN-pointer -> _bool))

; State

(define-curses set_term (_fun _SCREEN-pointer
                              -> _SCREEN-pointer))

(define-curses echo_sp (_fun _SCREEN-pointer -> _int))
(define-curses noecho_sp (_fun _SCREEN-pointer -> _int))

(define-curses cbreak_sp (_fun _SCREEN-pointer -> _int))
(define-curses nocbreak_sp (_fun _SCREEN-pointer -> _int))

(define-curses curs_set_sp (_fun _SCREEN-pointer _int -> _int))

(define-curses napms_sp (_fun _SCREEN-pointer _int -> _int))

(define-curses baudrate_sp (_fun _SCREEN-pointer -> _int))

; Mouse

(define-curses mousemask_sp (_fun _SCREEN-pointer
                                  (newmask : _mmask_t)
                                  (oldmask : (_ptr o _mmask_t))
                                  -> (outmask : _mmask_t) 
                                  -> (values outmask oldmask)))

(define-curses mouseinterval_sp (_fun _SCREEN-pointer _int -> _int))

(define-curses getmouse_sp (_fun _SCREEN-pointer
                                 (event : (_ptr o _MEVENT)) 
                                 -> (result : _int)
                                 -> (values (MEVENT-id event) 
                                            (MEVENT-x event) 
                                            (MEVENT-y event)
                                            (MEVENT-z event)
                                            (MEVENT-bstate event))))

(define-curses ungetmouse_sp (_fun _SCREEN-pointer 
                                   _MEVENT-pointer 
                                   -> _int))

; Styling

(define-curses start_color_sp (_fun _SCREEN-pointer -> _int))
(define-curses init_pair_sp (_fun _SCREEN-pointer _short _short _short -> _int))
(define-curses assume_default_colors_sp (_fun _SCREEN-pointer _int _int -> _int))
(define-curses color_content_sp (_fun _SCREEN-pointer _short _short _short _short -> _int))

; Effects

(define-curses doupdate_sp (_fun _SCREEN-pointer -> _void))
(define-curses endwin_sp (_fun _SCREEN-pointer -> _int))
(define-curses beep_sp (_fun _SCREEN-pointer -> _int))

;; Window

; Constructors

(define-curses copywin (_fun _WINDOW-pointer _WINDOW-pointer
                             _int _int _int _int _int _int _int
                             -> _int))

(define-curses subwin (_fun _WINDOW-pointer
                            _int _int _int _int
                            -> _WINDOW-pointer))

(define-curses derwin (_fun _WINDOW-pointer
                            _int _int _int _int
                            -> _WINDOW-pointer))

; Destructor

(define-curses delwin (_fun _WINDOW-pointer -> _int))

; State

(define-curses keypad (_fun _WINDOW-pointer _bool -> _int))
(define-curses nodelay (_fun _WINDOW-pointer _bool -> _int))

(define-curses getbegx (_fun _WINDOW-pointer -> _int))
(define-curses getbegy (_fun _WINDOW-pointer -> _int))

(define-curses getmaxx (_fun _WINDOW-pointer -> _int))
(define-curses getmaxy (_fun _WINDOW-pointer -> _int))

(define-curses getparx (_fun _WINDOW-pointer -> _int))
(define-curses getpary (_fun _WINDOW-pointer -> _int))

; Styling

(define-curses wcolor_set (_fun _WINDOW-pointer _short -> _int))

(define-curses wattr_get (_fun _WINDOW-pointer
                               (a : (_ptr o _attr_t))
                               (c : (_ptr o _pair_t))
                               (o : (_ptr o _pointer))
                               -> _int 
                               -> (values a c o)))

(define-curses wattrset (_fun _WINDOW-pointer _attr_t -> _int))
(define-curses wattroff (_fun _WINDOW-pointer _int -> _int))
(define-curses wattron (_fun _WINDOW-pointer _int -> _int))

(define-curses wbkgd (_fun _WINDOW-pointer _long -> _int))
(define-curses wbkgdset (_fun _WINDOW-pointer _long -> _int))

(define-curses wchgat (_fun _WINDOW-pointer _int _long _short -> _int))

; Input

(define-curses wgetch (_fun _WINDOW-pointer -> _int))

(define-curses wget_wch (_fun _WINDOW-pointer 
                              (ch : (_ptr o _wint))
                              -> _int
                              -> ch))

; Output

(define-curses waddch (_fun _WINDOW-pointer _chtype -> _int))
(define-curses waddchstr (_fun _WINDOW-pointer _chstr -> _int))

(define-curses waddwstr (_fun _WINDOW-pointer _wstring -> _int))

(define-curses wborder (_fun _WINDOW-pointer 
                             _chtype _chtype _chtype _chtype 
                             _chtype _chtype _chtype _chtype 
                             -> _int))

(define-curses wborder_set (_fun _WINDOW-pointer 
                                 _cchar_t-pointer _cchar_t-pointer _cchar_t-pointer _cchar_t-pointer
                                 _cchar_t-pointer _cchar_t-pointer _cchar_t-pointer _cchar_t-pointer
                                 -> _int))

(define-curses box (_fun _WINDOW-pointer _long _long -> _int))

; Effects

(define-curses wclear (_fun _WINDOW-pointer -> _int))
(define-curses wnoutrefresh (_fun _WINDOW-pointer -> _int))
(define-curses wrefresh (_fun _WINDOW-pointer -> _int))
(define-curses leaveok (_fun _WINDOW-pointer _bool -> _int))
(define-curses clearok (_fun _WINDOW-pointer _bool -> _int))
(define-curses wclrtobot (_fun _WINDOW-pointer -> _int))
(define-curses wclrtoeol (_fun _WINDOW-pointer -> _int))

; Cursor

(define-curses getcurx (_fun _WINDOW-pointer -> _int))
(define-curses getcury (_fun _WINDOW-pointer -> _int))

(define-curses wmove (_fun _WINDOW-pointer _int _int -> _int))

; Mouse

(define-curses wenclose (_fun _WINDOW-pointer _int _int -> _bool))

(define-curses wmouse_trafo (_fun (win : _WINDOW-pointer)
                                  (y : (_ptr io _int))
                                  (x : (_ptr io _int))
                                  (to-screen? : _bool)
                                  -> (enclosed : _bool) 
                                  -> (values enclosed x y)))
