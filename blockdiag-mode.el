;;; blockdiag-mode.el --- Mode for the diag file used by blockdiag.
;; 
;; blockdiag-mode.el is based on graphviz-dot.el from below.
;; http://users.skynet.be/ppareit/projects/graphviz-dot-mode/graphviz-dot-mode.html
;; Thank Pieter Pareit very much!!
;; Copyright (C) 2011 - 2011 fortunan on twitter.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;;; Code:

(defconst blockdiag-mode-version "0.3.6"
  "Version of `blockdiag-mode.el'.")

(defgroup blockdiag nil
  "Major mode for editing Blockdiag Dot files"
  :group 'tools)

(defun blockdiag-dot-customize ()
  "Run \\[customize-group] for the `blockdiag' group."
  (interactive)
  (customize-group 'blockdiag))

(defvar blockdiag-mode-abbrev-table nil
  "Abbrev table in use in Blockdiag Dot mode buffers.")
(define-abbrev-table 'blockdiag-mode-abbrev-table ())

(defcustom blockdiag-dot-program "blockdiag"
  "*Location of the blockdiag program. This is used by `compile'."
  :type 'string
  :group 'blockdiag)

(defcustom blockdiag-dot-view-command "doted %s"
  "*External program to run on the buffer. You can use `%s' in this string,
and it will be substituted by the buffer name."
  :type 'string
  :group 'blockdiag)

(defcustom blockdiag-dot-view-edit-command nil
  "*Whether to allow the user to edit the command to run an external
viewer."
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-save-before-view t
  "*If not nil, M-x blockdiag-dot-view saves the current buffer before running
the command."
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-auto-indent-on-newline t
  "*If not nil, `electric-blockdiag-dot-terminate-line' is executed in a line is terminated."
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-indent-width default-tab-width
  "*Indentation width in Blockdiag Dot mode buffers."
  :type 'integer
  :group 'blockdiag)

(defcustom blockdiag-dot-auto-indent-on-braces nil
  "*If not nil, `electric-blockdiag-dot-open-brace' and `electric-blockdiag-dot-close-brace' are executed when { or } are typed"
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-auto-indent-on-semi t
  "*If not nil, `electric-blockdiag-dot-semi' is executed when semicolon is typed"
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-preview-extension "png"
  "*The extension to use for the compilation and preview commands. The format
for the compilation command is 
`dot -T<extension> file.dot > file.<extension>'."
  :type 'string
  :group 'blockdiag)

(defcustom blockdiag-dot-toggle-completions nil
  "*Non-nil means that repeated use of \
\\<blockdiag-mode-map>\\[blockdiag-dot-complete-word] will toggle the possible
completions in the minibuffer.  Normally, when there is more than one possible
completion, a buffer will display all completions."
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-delete-completions nil
  "*Non-nil means that the completion buffer is automatically deleted when a
key is pressed."
  :type 'boolean
  :group 'blockdiag)

(defcustom blockdiag-dot-attr-keywords 
  '("graph" "digraph" "subgraph" "node" "edge" "strict" "rankdir"
    "size" "page" "Damping" "Epsilon" "URL" "arrowhead" "arrowsize"
    "arrowtail" "bb" "bgcolor" "bottomlabel" "center" "clusterrank"
    "color" "comment" "compound" "concentrate" "constraint" "decorate"
    "dim" "dir" "distortion" "fillcolor" "fixedsize" "fontcolor"
    "fontname" "fontpath" "fontsize" "group" "headURL" "headlabel"
    "headport" "height" "label" "labelangle" "labeldistance" "labelfloat"
    "labelfontcolor" "labelfontname" "labelfontsize" "labeljust"
    "labelloc" "layer" "layers" "len" "lhead" "lp" "ltail" "margin"
    "maxiter" "mclimit" "minlen" "model" "nodesep" "normalize" "nslimit"
    "nslimit1" "ordering" "orientation" "overlap" "pack" "pagedir"
    "pencolor" "peripheries" "pin" "pos" "quantum" "rank" "ranksep"
    "ratio" "rects" "regular" "remincross" "rotate" "samehead" "sametail"
    "samplepoint" "searchsize" "sep" "shape" "shapefile" "showboxes"
    "sides" "skew" "splines" "start" "style" "stylesheet" "tailURL"
    "taillabel" "tailport" "toplabel" "vertices" "voro_margin" "weight"
    "z" "width" "penwidth" "mindist" "scale" "patch" "root" "numbered" "background")
  "*Keywords for attribute names in a graph. This is used by the auto
completion code. The actual completion tables are built when the mode
is loaded, so changes to this are not immediately visible.
Check http://www.graphviz.org/doc/schema/attributes.xml on new releases."
  :type '(repeat (string :tag "Keyword"))
  :group 'blockdiag)

(defcustom blockdiag-dot-value-keywords 
  '("true" "false" "normal" "inv" "dot" "invdot" "odot" "invodot"
    "none" "tee" "empty" "invempty" "diamond" "odiamond" "box" "obox"
    "open" "crow" "halfopen" "local" "global" "none" "forward" "back"
    "both" "none" "BL" "BR" "TL" "TR" "RB" "RT" "LB" "LT" ":n" ":ne" ":e"
    ":se" ":s" ":sw" ":w" ":nw" "same" "min" "source" "max" "sink" "LR"
    "box" "polygon" "ellipse" "circle" "point" "egg" "triangle"
    "plaintext" "diamond" "trapezium" "parallelogram" "house" "hexagon"
    "octagon" "doublecircle" "doubleoctagon" "tripleoctagon" "invtriangle"
    "invtrapezium" "invhouse" "Mdiamond" "Msquare" "Mcircle" "record"
    "Mrecord" "dashed" "dotted" "solid" "invis" "bold" "filled"
    "diagonals" "rounded" "mail" "input" "beginpoint" "endpoint" "note" "cloud"
    "portrait" "landscape" "roundedbox") 
  "*Keywords for attribute values. This is used by the auto completion
code. The actual completion tables are built when the mode is loaded,
so changes to this are not immediately visible."
  :type '(repeat (string :tag "Keyword")) 
  :group 'blockdiag)

;;; Font-locking:
(defvar blockdiag-dot-colors-list
  '(aliceblue antiquewhite antiquewhite1 antiquewhite2
        antiquewhite3 antiquewhite4 aquamarine aquamarine1
        aquamarine2 aquamarine3 aquamarine4 azure azure1
        azure2 azure3 azure4 beige bisque bisque1 bisque2
        bisque3 bisque4 black blanchedalmond blue blue1
        blue2 blue3 blue4 blueviolet brown brown1 brown2
        brown3 brown4 burlywood burlywood1 burlywood2
        burlywood3 burlywood4 cadetblue cadetblue1
        cadetblue2 cadetblue3 cadetblue4 chartreuse
        chartreuse1 chartreuse2 chartreuse3 chartreuse4
        chocolate chocolate1 chocolate2 chocolate3 chocolate4
        coral coral1 coral2 coral3 coral4 cornflowerblue
        cornsilk cornsilk1 cornsilk2 cornsilk3 cornsilk4
        crimson cyan cyan1 cyan2 cyan3 cyan4 darkgoldenrod
        darkgoldenrod1 darkgoldenrod2 darkgoldenrod3
        darkgoldenrod4 darkgreen darkkhaki darkolivegreen
        darkolivegreen1 darkolivegreen2 darkolivegreen3
        darkolivegreen4 darkorange darkorange1 darkorange2
        darkorange3 darkorange4 darkorchid darkorchid1
        darkorchid2 darkorchid3 darkorchid4 darksalmon
        darkseagreen darkseagreen1 darkseagreen2
        darkseagreen3 darkseagreen4 darkslateblue
        darkslategray darkslategray1 darkslategray2
        darkslategray3  darkslategray4 darkslategrey
        darkturquoise darkviolet deeppink deeppink1
        deeppink2 deeppink3 deeppink4 deepskyblue
        deepskyblue1 deepskyblue2 deepskyblue3 deepskyblue4
        dimgray dimgrey  dodgerblue dodgerblue1 dodgerblue2
        dodgerblue3  dodgerblue4 firebrick firebrick1
        firebrick2 firebrick3 firebrick4 floralwhite
        forestgreen gainsboro ghostwhite gold gold1 gold2
        gold3 gold4 goldenrod goldenrod1 goldenrod2
        goldenrod3 goldenrod4 gray gray0 gray1 gray10 gray100
        gray11 gray12 gray13 gray14 gray15 gray16 gray17
        gray18 gray19 gray2 gray20 gray21 gray22 gray23
        gray24 gray25 gray26 gray27 gray28 gray29 gray3
        gray30 gray31 gray32 gray33 gray34 gray35 gray36
        gray37 gray38 gray39 gray4 gray40 gray41 gray42
        gray43 gray44 gray45 gray46 gray47 gray48 gray49
        gray5 gray50 gray51 gray52 gray53 gray54 gray55
        gray56 gray57 gray58 gray59 gray6 gray60 gray61
        gray62 gray63 gray64 gray65 gray66 gray67 gray68
        gray69 gray7 gray70 gray71 gray72 gray73 gray74
        gray75 gray76 gray77 gray78 gray79 gray8 gray80
        gray81 gray82 gray83 gray84 gray85 gray86 gray87
        gray88 gray89 gray9 gray90 gray91 gray92 gray93
        gray94 gray95 gray96 gray97 gray98 gray99 green
        green1 green2 green3 green4 greenyellow grey grey0
        grey1 grey10 grey100 grey11 grey12 grey13 grey14
        grey15 grey16 grey17 grey18 grey19 grey2 grey20
        grey21 grey22 grey23 grey24 grey25 grey26 grey27
        grey28 grey29 grey3 grey30 grey31 grey32 grey33
        grey34 grey35 grey36 grey37 grey38 grey39 grey4
        grey40 grey41 grey42 grey43 grey44 grey45 grey46
        grey47 grey48 grey49 grey5 grey50 grey51 grey52
        grey53 grey54 grey55 grey56 grey57 grey58 grey59
        grey6 grey60 grey61 grey62 grey63 grey64 grey65
        grey66 grey67 grey68 grey69 grey7 grey70 grey71
        grey72 grey73 grey74 grey75 grey76 grey77 grey78
        grey79 grey8 grey80 grey81 grey82 grey83 grey84
        grey85 grey86 grey87 grey88 grey89 grey9 grey90
        grey91 grey92 grey93 grey94 grey95 grey96 grey97
        grey98 grey99 honeydew honeydew1 honeydew2 honeydew3
        honeydew4 hotpink hotpink1 hotpink2 hotpink3 hotpink4
        indianred indianred1 indianred2 indianred3 indianred4
        indigo ivory ivory1 ivory2 ivory3 ivory4 khaki khaki1
        khaki2 khaki3 khaki4 lavender lavenderblush
        lavenderblush1 lavenderblush2 lavenderblush3
        lavenderblush4 lawngreen lemonchiffon lemonchiffon1
        lemonchiffon2 lemonchiffon3 lemonchiffon4 lightblue
        lightblue1 lightblue2 lightblue3 lightblue4
        lightcoral lightcyan lightcyan1 lightcyan2 lightcyan3
        lightcyan4 lightgoldenrod lightgoldenrod1
        lightgoldenrod2 lightgoldenrod3 lightgoldenrod4
        lightgoldenrodyellow lightgray lightgrey lightpink
        lightpink1 lightpink2 lightpink3 lightpink4
        lightsalmon lightsalmon1 lightsalmon2 lightsalmon3
        lightsalmon4 lightseagreen lightskyblue lightskyblue1
        lightskyblue2 lightskyblue3 lightskyblue4
        lightslateblue lightslategray lightslategrey
        lightsteelblue lightsteelblue1 lightsteelblue2
        lightsteelblue3 lightsteelblue4 lightyellow
        lightyellow1 lightyellow2 lightyellow3 lightyellow4
        limegreen linen magenta magenta1 magenta2 magenta3
        magenta4 maroon maroon1 maroon2 maroon3 maroon4
        mediumaquamarine mediumblue  mediumorchid
        mediumorchid1 mediumorchid2 mediumorchid3
        mediumorchid4 mediumpurple mediumpurple1
        mediumpurple2 mediumpurple3 mediumpurple4
        mediumseagreen mediumslateblue mediumspringgreen
        mediumturquoise mediumvioletred midnightblue
        mintcream mistyrose mistyrose1 mistyrose2 mistyrose3
        mistyrose4 moccasin navajowhite navajowhite1
        navajowhite2 navajowhite3 navajowhite4 navy navyblue
        oldlace olivedrab olivedrap olivedrab1 olivedrab2
        olivedrap3 oragne palegoldenrod palegreen palegreen1
        palegreen2 palegreen3 palegreen4 paleturquoise
        paleturquoise1 paleturquoise2 paleturquoise3
        paleturquoise4 palevioletred palevioletred1
        palevioletred2 palevioletred3 palevioletred4
        papayawhip peachpuff peachpuff1 peachpuff2
        peachpuff3 peachpuff4 peru pink pink1 pink2 pink3
        pink4 plum plum1 plum2 plum3 plum4 powderblue
        purple purple1 purple2 purple3 purple4 red red1 red2
        red3 red4 rosybrown rosybrown1 rosybrown2 rosybrown3
        rosybrown4 royalblue royalblue1 royalblue2 royalblue3
        royalblue4 saddlebrown salmon salmon1 salmon2 salmon3
        salmon4 sandybrown seagreen seagreen1 seagreen2
        seagreen3 seagreen4 seashell seashell1 seashell2
        seashell3 seashell4 sienna sienna1 sienna2 sienna3
        sienna4 skyblue skyblue1 skyblue2 skyblue3 skyblue4
        slateblue slateblue1 slateblue2 slateblue3 slateblue4
        slategray slategray1 slategray2 slategray3 slategray4
        slategrey snow snow1 snow2 snow3 snow4 springgreen
        springgreen1 springgreen2 springgreen3 springgreen4
        steelblue steelblue1 steelblue2 steelblue3 steelblue4
        tan tan1 tan2 tan3 tan4 thistle thistle1 thistle2
        thistle3 thistle4 tomato tomato1 tomato2 tomato3
        tomato4 transparent turquoise turquoise1 turquoise2
        turquoise3 turquoise4 violet violetred violetred1
        violetred2 violetred3 violetred4 wheat wheat1 wheat2
        wheat3 wheat4 white whitesmoke yellow yellow1 yellow2
        yellow3 yellow4 yellowgreen)
  "Possible color constants in the dot language.
The list of constant is available at http://www.research.att.com/~erg/graphviz\
/info/colors.html")


(defvar blockdiag-dot-color-keywords
  (mapcar 'symbol-name blockdiag-dot-colors-list))

(defvar blockdiag-attr-keywords
  (mapcar '(lambda (elm) (cons elm 0)) blockdiag-dot-attr-keywords))

(defvar blockdiag-value-keywords
  (mapcar '(lambda (elm) (cons elm 0)) blockdiag-dot-value-keywords))

(defvar blockdiag-color-keywords
  (mapcar '(lambda (elm) (cons elm 0)) blockdiag-dot-color-keywords))

;;; Key map
(defvar blockdiag-mode-map ()
  "Keymap used in Blockdiag mode.")

(if blockdiag-mode-map
    ()
  (let ((map (make-sparse-keymap)))
    (define-key map "\r"       'electric-blockdiag-dot-terminate-line)
    (define-key map "{"        'electric-blockdiag-dot-open-brace)
    (define-key map "}"        'electric-blockdiag-dot-close-brace)
    (define-key map ";"        'electric-blockdiag-dot-semi)
    (define-key map "\M-\t"    'blockdiag-dot-complete-word)
    (define-key map "\C-\M-q"  'blockdiag-dot-indent-graph)
    (define-key map "\C-cp"    'blockdiag-dot-preview)
    (define-key map "\C-cc"    'compile)
    (define-key map "\C-cv"    'blockdiag-dot-view)
    (define-key map "\C-c\C-c" 'comment-region)
    (define-key map "\C-c\C-u" 'blockdiag-dot-uncomment-region)
    (setq blockdiag-mode-map map)
    ))

;;; Syntax table
(defvar blockdiag-mode-syntax-table nil
  "Syntax table for `blockdiag-mode'.")

(if blockdiag-mode-syntax-table
    ()
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/  ". 124b" st)
    (modify-syntax-entry ?*  ". 23"   st)
    (modify-syntax-entry ?\n "> b"    st)
    (modify-syntax-entry ?=  "."      st)
    (modify-syntax-entry ?_  "_"      st)
    (modify-syntax-entry ?-  "_"      st)
    (modify-syntax-entry ?>  "."      st)
    (modify-syntax-entry ?[  "("      st)
    (modify-syntax-entry ?]  ")"      st)
    (modify-syntax-entry ?\" "\""     st)
    (setq blockdiag-mode-syntax-table st)
  ))

(defvar blockdiag-dot-font-lock-keywords
  `(("\\(:?di\\|sub\\)?graph \\(\\sw+\\)"
     (2 font-lock-function-name-face))
    (,(regexp-opt blockdiag-dot-value-keywords 'words)
     . font-lock-reference-face)
    ;; to build the font-locking for the colors,
    ;; we need more room for max-specpdl-size,
    ;; after that we take the list of symbols,
    ;; convert them to a list of strings, and make
    ;; an optimized regexp from them
    (,(let ((max-specpdl-size (max max-specpdl-size 1200)))
  (regexp-opt blockdiag-dot-color-keywords))
     . font-lock-string-face)
    (,(concat
       (regexp-opt blockdiag-dot-attr-keywords 'words)
       "[ \\t\\n]*=")
     ;; RR - ugly, really, but I dont know why xemacs does not work
     ;; if I change the next car to "1"...
     (0 font-lock-variable-name-face)))
  "Keyword highlighting specification for `blockdiag-mode'.")

;;;###autoload
(defun blockdiag-mode ()
  "Major mode for the dot language. \\<blockdiag-mode-map> 
TAB indents for graph lines. 

\\[blockdiag-dot-indent-graph]\t- Indentaion function.
\\[blockdiag-dot-preview]\t- Previews graph in a buffer.
\\[blockdiag-dot-view]\t- Views graph in an external viewer.
\\[blockdiag-dot-indent-line]\t- Indents current line of code.
\\[blockdiag-dot-complete-word]\t- Completes the current word.
\\[electric-blockdiag-dot-terminate-line]\t- Electric newline.
\\[electric-blockdiag-dot-open-brace]\t- Electric open braces.
\\[electric-blockdiag-dot-close-brace]\t- Electric close braces.
\\[electric-blockdiag-dot-semi]\t- Electric semi colons.

Variables specific to this mode:

  blockdiag-dot-program            (default `blockdiag')
       Location of the dot program.
  blockdiag-dot-view-command           (default `doted %s')
       Command to run when `blockdiag-dot-view' is executed.
  blockdiag-dot-view-edit-command      (default nil)
       If the user should be asked to edit the view command.
  blockdiag-dot-save-before-view       (default t)
       Automatically save current buffer berore `blockdiag-dot-view'.
  blockdiag-dot-preview-extension      (default `png')
       File type to use for `blockdiag-dot-preview'.
  blockdiag-dot-auto-indent-on-newline (default t)
       Whether to run `electric-blockdiag-dot-terminate-line' when 
       newline is entered.
  blockdiag-dot-auto-indent-on-braces (default t)
       Whether to run `electric-blockdiag-dot-open-brace' and
       `electric-blockdiag-dot-close-brace' when braces are 
       entered.
  blockdiag-dot-auto-indent-on-semi (default t)
       Whether to run `electric-blockdiag-dot-semi' when semi colon
       is typed.
  blockdiag-dot-toggle-completions  (default nil)
       If completions should be displayed in the buffer instead of a
       completion buffer when \\[blockdiag-dot-complete-word] is
       pressed repeatedly.

This mode can be customized by running \\[blockdiag-dot-customize].

Turning on Blockdiag Dot mode calls the value of the variable 
`blockdiag-mode-hook' with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map blockdiag-mode-map)
  (setq major-mode 'blockdiag-mode)
  (setq mode-name "diag")
  (setq local-abbrev-table blockdiag-mode-abbrev-table)
  (set-syntax-table blockdiag-mode-syntax-table)
  (set (make-local-variable 'indent-line-function) 'blockdiag-dot-indent-line)
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-start-skip) "/\\*+ *\\|//+ *")
  (modify-syntax-entry ?# "< b" blockdiag-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" blockdiag-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults) 
       '(blockdiag-dot-font-lock-keywords))
  ;; RR - If user is running this in the scratch buffer, there is no
  ;; buffer file name...
  (if (buffer-file-name)
      (set (make-local-variable 'compile-command) 
       (concat blockdiag-dot-program
               " -T" blockdiag-dot-preview-extension " "
               "\"" buffer-file-name "\""
               " -o \""
               (file-name-sans-extension
                buffer-file-name)
               "." blockdiag-dot-preview-extension "\""))) 
  (set (make-local-variable 'compilation-parse-errors-function)
       'blockdiag-dot-compilation-parse-errors)
  (if dot-menu
      (easy-menu-add dot-menu))
  (run-hooks 'blockdiag-mode-hook)
  )

;;;; Menu definitions

(defvar dot-menu nil
  "Menu for Blockdiag Dot Mode.
This menu will get created automatically if you have the `easymenu'
package. Note that the latest X/Emacs releases contain this package.")

(and (condition-case nil
         (require 'easymenu)
       (error nil))
     (easy-menu-define
      dot-menu blockdiag-mode-map "Blockdiag Mode menu"
      '("Blockdiag"
        ["Indent Graph"       blockdiag-dot-indent-graph     t]
        ["Comment Out Region" comment-region                (mark)]
        ["Uncomment Region"   blockdiag-dot-uncomment-region (mark)]
        "-"
        ["Compile"            compile                       t]
        ["Preview"            blockdiag-dot-preview        
         (and (buffer-file-name)
              (not (buffer-modified-p)))]
        ["External Viewer"    blockdiag-dot-view             (buffer-file-name)]
        "-"
        ["Customize..."       blockdiag-dot-customize        t]
        )))

;;;; Compilation

;; note on blockdiag-dot-compilation-parse-errors:
;;  It would nicer if we could just use compilation-error-regexp-alist
;;  to do that, 3 options:
;;   - still write dot-compilation-parse-errors, don't build
;;     a return list, but modify the *compilation* buffer
;;     in a way compilation-error-regexp-alist recognizes the
;;     format.
;;     to do that, I should globally change compilation-parse-function
;;     to this function, and call the old value of comp..-parse-fun..
;;     to provide the return value.
;;     two drawbacks are that, every compilation would be run through
;;     this function (performance) and that in autoload there would
;;     be a chance that this function would not yet be known.
;;   - let the compilation run through a filter that would
;;     modify the output of dot or neato:
;;     dot -Tpng input.dot | filter
;;     drawback: ugly, extra work for user, extra decency ...
;;               no-option
;;   - modify dot and neato !!! (PP:15/02/2005 seems to have happend,
;;                                       so version 0.4.0 should clean this mess up!)
(defun blockdiag-dot-compilation-parse-errors (limit-search find-at-least)
  "Parse the current buffer for dot errors.
See variable `compilation-parse-errors-functions' for interface."
  (interactive)
  (save-excursion
    (set-buffer "*compilation*")
    (goto-char (point-min))
    (setq compilation-error-list nil)
    (let (buffer-of-error)
      (while (not (eobp))
  (cond
   ((looking-at "^dot\\( -[^ ]+\\)* \\(.*\\)")
    (setq buffer-of-error (find-file-noselect
         (buffer-substring-no-properties
          (nth 4 (match-data t))
          (nth 5 (match-data t))))))
   ((looking-at ".*:.*line \\([0-9]+\\)")
    (let ((line-of-error
     (string-to-number (buffer-substring-no-properties
            (nth 2 (match-data t))
            (nth 3 (match-data t))))))
      (setq compilation-error-list
      (cons
       (cons
        (point-marker)
        (save-excursion
          (set-buffer buffer-of-error)
          (goto-line line-of-error)
          (beginning-of-line)
          (point-marker)))
       compilation-error-list))))
    (t t))
  (forward-line 1)) )))

;;;;
;;;; Indentation
;;;;
(defun blockdiag-dot-uncomment-region (begin end)
	"Uncomments a region of code."
	(interactive "r")
	(comment-region begin end '(4)))

(defun blockdiag-dot-indent-line ()
  "Indent current line of dot code."
  (interactive)
  (if (bolp)
      (blockdiag-dot-real-indent-line)
    (save-excursion
      (blockdiag-dot-real-indent-line))))

(defun blockdiag-dot-get-indendation()
  "Return current line's indentation"
  (interactive)
  (message "Current indentation is %d." 
	   (current-indentation))
  (current-indentation))
        
(defun blockdiag-dot-real-indent-line ()
  "Indent current line of dot code."
  (beginning-of-line)
  (cond
   ((bobp)
    ;; simple case, indent to 0
    (indent-line-to 0))
   ((looking-at "^[ \t]*}[ \t]*$")
    ;; block closing, deindent relative to previous line
    (indent-line-to (save-excursion
                      (forward-line -1)
                      (max 0 (- (current-indentation) blockdiag-dot-indent-width)))))
   ;; other cases need to look at previous lines
   (t
    (indent-line-to (save-excursion
                      (forward-line -1)
                      (cond
                       ((looking-at "\\(^.*{[^}]*$\\)")
                        ;; previous line opened a block
                        ;; indent to that line
                        (+ (current-indentation) blockdiag-dot-indent-width))
                       ((and (not (looking-at ".*\\[.*\\].*"))
                             (looking-at ".*\\[.*")) ; TODO:PP : can be 1 regex
                        ;; previous line started filling
                        ;; attributes, intend to that start
                        (search-forward "[")
                        (current-column))
                       ((and (not (looking-at ".*\\[.*\\].*"))
                             (looking-at ".*\\].*")) ; TODO:PP : "
                        ;; previous line stopped filling
                        ;; attributes, find the line that started
                        ;; filling them and indent to that line
                        (while (or (looking-at ".*\\[.*\\].*")
                                   (not (looking-at ".*\\[.*"))) ; TODO:PP : "
                          (forward-line -1))
                        (current-indentation))
                       (t			
                        ;; default case, indent the
                        ;; same as previous NON-BLANK line
			;; (or the first line, if there are no previous non-blank lines)
			(while (and (< (point-min) (point))
				    (looking-at "^\[ \t\]*$"))
			  (forward-line -1))
                        (current-indentation)) ))) )))

(defun blockdiag-dot-indent-graph ()
  "Indent the graph/digraph/subgraph where point is at.
This will first teach the beginning of the graph were point is at, and
then indent this and each subgraph in it."
  (interactive)
  (save-excursion
    ;; position point at start of graph
    (while (not (or (looking-at "\\(^.*{[^}]*$\\)") (bobp)))
      (forward-line -1))
    ;; bracket { one +; bracket } one -
    (let ((bracket-count 0))
      (while
          (progn
            (cond
             ;; update bracket-count
             ((looking-at "\\(^.*{[^}]*$\\)")
              (setq bracket-count (+ bracket-count 1)))
             ;; update bracket-count
             ((looking-at "^[ \t]*}[ \t]*$")
              (setq bracket-count (- bracket-count 1))))
            ;; indent this line and move on
            (blockdiag-dot-indent-line)
            (forward-line 1)
            ;; as long as we are not completed or at end of buffer
            (and (> bracket-count 0) (not (eobp))))))))
     
;;;;
;;;; Electric indentation
;;;;
(defun blockdiag-dot-comment-or-string-p ()
  (let ((state (parse-partial-sexp (point-min) (point))))
     (or (nth 4 state) (nth 3 state))))

(defun blockdiag-dot-newline-and-indent ()
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward " \t")
    (blockdiag-dot-indent-line))
  (delete-horizontal-space)
  (newline)
  (blockdiag-dot-indent-line))

(defun electric-blockdiag-dot-terminate-line ()
  "Terminate line and indent next line."
  (interactive)
  (if blockdiag-dot-auto-indent-on-newline
      (blockdiag-dot-newline-and-indent)
    (newline)))

(defun electric-blockdiag-dot-open-brace ()
  "Terminate line and indent next line."
  (interactive)
  (insert "{")
  (if (and blockdiag-dot-auto-indent-on-braces
           (not (blockdiag-dot-comment-or-string-p)))
      (blockdiag-dot-newline-and-indent)))

(defun electric-blockdiag-dot-close-brace ()
  "Terminate line and indent next line."
  (interactive)
  (insert "}")
  (if (and blockdiag-dot-auto-indent-on-braces
           (not (blockdiag-dot-comment-or-string-p)))
      (progn
        (save-excursion
          (beginning-of-line)
          (skip-chars-forward " \t")
          (blockdiag-dot-indent-line))
        (newline)
        (blockdiag-dot-indent-line))))

(defun electric-blockdiag-dot-semi ()
  "Terminate line and indent next line."
  (interactive)
  (insert ";")
  (if (and blockdiag-dot-auto-indent-on-semi
           (not (blockdiag-dot-comment-or-string-p)))
      (blockdiag-dot-newline-and-indent)))

;;;;
;;;; Preview
;;;;
(defun blockdiag-dot-preview ()
  "Shows an example of the current dot file in an emacs buffer.
This assumes that we are running GNU Emacs or XEmacs under a windowing system.
See `image-file-name-extensions' for customizing the files that can be
loaded in GNU Emacs, and `image-formats-alist' for XEmacs."
  (interactive)
  ;; unsafe to compile ourself, ask it to the user
  (if (buffer-modified-p)
      (message "Buffer needs to be compiled.")
    (if (string-match "XEmacs" emacs-version)
        ;; things are easier in XEmacs...
        (find-file-other-window (concat (file-name-sans-extension
					 buffer-file-name)
					"." blockdiag-dot-preview-extension))
      ;; run through all the extensions for images
      (let ((l image-file-name-extensions))
        (while
            (let ((f (concat (file-name-sans-extension (buffer-file-name))
                             "."
                             (car l))))
              ;; see if a file matches, might be best also to check
              ;; if file is up to date TODO:PP
              (if (file-exists-p f)
                  (progn (auto-image-file-mode 1)
                         ;; OK, this is ugly, I would need to 
                         ;; know how I can reload a file in an existing buffer
                         (if (get-buffer "*preview*")
                             (kill-buffer "*preview*"))
                         (set-buffer (find-file-noselect f))
                         (rename-buffer "*preview*")
                         (display-buffer (get-buffer "*preview*"))
                         ;; stop iterating
                         '())
                ;; will stop iterating when l is nil
                (setq l (cdr l)))))
      ;; each extension tested and nothing found, let user know
      (when (eq l '())
        (message "No image found."))))))

;;;;
;;;; View
;;;;
(defun blockdiag-dot-view ()
  "Runs an external viewer. This creates an external process every time it
is executed. If `blockdiag-dot-save-before-view' is set, the current
buffer is saved before the command is executed."
  (interactive)
  (let ((cmd (if blockdiag-dot-view-edit-command
                 (if (string-match "XEmacs" emacs-version)
                     (read-shell-command "View command: " 
                                         (format blockdiag-dot-view-command
                                                 (buffer-file-name)))
                   (read-from-minibuffer "View command: " 
                                         (format blockdiag-dot-view-command
                                                 (buffer-file-name))))
               (format blockdiag-dot-view-command (buffer-file-name)))))
    (if blockdiag-dot-save-before-view 
        (save-buffer))
    (setq novaproc (start-process-shell-command
                    (downcase mode-name) nil cmd))
    (message (format "Executing `%s'..." cmd))))

;;;;
;;;; Completion
;;;;
(defvar blockdiag-dot-str nil)
(defvar blockdiag-dot-all nil)
(defvar blockdiag-dot-pred nil)
(defvar blockdiag-dot-buffer-to-use nil)
(defvar blockdiag-dot-flag nil)

(defun blockdiag-dot-get-state ()
  "Returns the syntax state of the current point."
  (let ((state (parse-partial-sexp (point-min) (point))))
    (cond
     ((nth 4 state) 'comment)
     ((nth 3 state) 'string)
     ((not (nth 1 state)) 'out)
     (t (save-excursion
          (skip-chars-backward "^[,=\\[]{};")
          (backward-char)
          (cond 
           ((looking-at "[\\[,]{};") 'attribute)
           ((looking-at "=") (progn
                               (backward-word 1)
                               (if (looking-at "[a-zA-Z]*color")
                                   'color
                                 'value)))
           (t 'other)))))))

(defun blockdiag-dot-get-keywords ()
  "Return possible completions for a word"
  (let ((state (blockdiag-dot-get-state)))
    (cond
     ((equal state 'comment)   ())
     ((equal state 'string)    ())
     ((equal state 'out)       blockdiag-attr-keywords)
     ((equal state 'value)     blockdiag-value-keywords)
     ((equal state 'color)     blockdiag-color-keywords)
     ((equal state 'attribute) blockdiag-attr-keywords)
     (t                        blockdiag-attr-keywords))))

(defvar blockdiag-dot-last-word-numb 0)
(defvar blockdiag-dot-last-word-shown nil)
(defvar blockdiag-dot-last-completions nil)

(defun blockdiag-dot-complete-word ()
  "Complete word at current point."
  (interactive)
  (let* ((b (save-excursion (skip-chars-backward "a-zA-Z0-9_") (point)))
         (e (save-excursion (skip-chars-forward "a-zA-Z0-9_") (point)))
         (blockdiag-dot-str (buffer-substring b e))
         (allcomp (if (and blockdiag-dot-toggle-completions
                           (string= blockdiag-dot-last-word-shown 
                                    blockdiag-dot-str))
                      blockdiag-dot-last-completions
                    (all-completions blockdiag-dot-str 
                                     (blockdiag-dot-get-keywords))))
         (match (if blockdiag-dot-toggle-completions
                    "" (try-completion
                        blockdiag-dot-str (mapcar '(lambda (elm)
                                                    (cons elm 0)) allcomp)))))
    ;; Delete old string
    (delete-region b e)
    
    ;; Toggle-completions inserts whole labels
    (if blockdiag-dot-toggle-completions
        (progn
          ;; Update entry number in list
          (setq blockdiag-dot-last-completions allcomp
                blockdiag-dot-last-word-numb 
                (if (>= blockdiag-dot-last-word-numb (1- (length allcomp)))
                    0
                  (1+ blockdiag-dot-last-word-numb)))
          (setq blockdiag-dot-last-word-shown 
                (elt allcomp blockdiag-dot-last-word-numb))
          ;; Display next match or same string if no match was found
          (if (not (null allcomp))
              (insert "" blockdiag-dot-last-word-shown)
            (insert "" blockdiag-dot-str)
            (message "(No match)")))
      ;; The other form of completion does not necessarily do that.
      
      ;; Insert match if found, or the original string if no match
      (if (or (null match) (equal match 't))
          (progn (insert "" blockdiag-dot-str)
                 (message "(No match)"))
        (insert "" match))
      ;; Give message about current status of completion
      (cond ((equal match 't)
             (if (not (null (cdr allcomp)))
                 (message "(Complete but not unique)")
               (message "(Sole completion)")))
            ;; Display buffer if the current completion didn't help 
            ;; on completing the label.
            ((and (not (null (cdr allcomp))) (= (length blockdiag-dot-str)
                                                (length match)))
             (with-output-to-temp-buffer "*Completions*"
               (display-completion-list allcomp))
             ;; Wait for a keypress. Then delete *Completion*  window
             (momentary-string-display "" (point))
             (if blockdiag-dot-delete-completions
                 (delete-window 
                  (get-buffer-window (get-buffer "*Completions*"))))
             )))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.diag\\'" . blockdiag-mode))


(provide 'blockdiag-mode)
;;; blockdiag-mode.el ends here

