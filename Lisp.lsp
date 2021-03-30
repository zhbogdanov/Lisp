(defun change (A)
(cond   ((eq A '#\A) 'A)
        ((eq A '#\B) 'B)
        ((eq A '#\C) 'C)
        ((eq A '#\D) 'D)
        ((eq A '#\E) 'E)
        ((eq A '#\F) 'F)
        ((eq A '#\G) 'G)
        ((eq A '#\H) 'H)
        ((eq A '#\I) 'I)
        ((eq A '#\J) 'J)
        ((eq A '#\K) 'K)
        ((eq A '#\L) 'L)
        ((eq A '#\M) 'M)
        ((eq A '#\N) 'N)
        ((eq A '#\O) 'O)
        ((eq A '#\P) 'P)
        ((eq A '#\Q) 'Q)
        ((eq A '#\R) 'R)
        ((eq A '#\S) 'S)
        ((eq A '#\T) 'T)
        ((eq A '#\U) 'U)
        ((eq A '#\V) 'V)
        ((eq A '#\W) 'W)
        ((eq A '#\X) 'X)
        ((eq A '#\Y) 'Y)
        ((eq A '#\Z) 'Z)
        ((eq A '#\~) '~)
        ((eq A '#\^) '^)
        ((eq A '#\&) '&)
        ((eq A NIL) A)
        (T "Wrong Symbol")
))

(defun readStr (L)
(cond   ((null L) NIL)
        ((eq (change (car L)) "Wrong Symbol") "Wrong Symbol")
        (T (cons (change (car L)) (readStr (cdr L))))
))

(defun handleAtom(A)
(cond   ((eq (car A) '~) (cons (list (cadr A)) (cddr A)))
        ((eq (car A) '&) (handleAtom (cdr A)))
        (T (cons (car A) (cdr A)))
))

(defun readDNF(L Acc)
(cond   ((null (car L))  (cons Acc NIL))
        ((eq (car L) '^) (cons Acc (readDNF (cdr L) NIL)))
        (T (readDNF (cdr (handleAtom L)) (cons (car (handleAtom L)) Acc)))
))

(defun postRead (L)
(cond   ((null (cdr L)) L)
        (T (preMorgan (delDupl (del (ProdDec L) NIL))))
))

(defun postReadStr (L)
(cond   ((null L) NIL)
        ((eq L "Wrong Symbol") "Wrong Symbol")
        (T (createKNF (postRead (readDNF L NIL))))
))

(defun mapappend(F L)
(cond   ((null L) NIL)
        (T (append (funcall F (car L))
                   (mapappend F (cdr L))))
))

(defun Decart (L M)
    (reduce 'append
            (mapcar #'(lambda (X)
                        (mapcar #'(lambda (Y) (list X Y))
                                  M))
                        L))
)

(defun NewDecart(M Sk)
(cond   ((mapappend #'(lambda (X)
            (mapcar #'(lambda (Y)
                (cons X Y))
            Sk))
        M))
))

(defun ProdDec(L)
(cond   ((null (cddr L)) (Decart (car L) (cadr L)))
        (T (NewDecart (car L) (ProdDec(cdr L))))
        
))

(defun findList(A L)
(cond   ((null L) NIL)
        ((listp (car L)) (cond ((eq A (caar L)) T)
                               (T (findList A (cdr L)))
                         ))
        (T (findList A (cdr L)))
))

(defun findAtom(A L)
(cond   ((null L) NIL)
        ((atom (car L)) (cond ((eq (car A) (car L)) T)
                              (T (findAtom A (cdr L)))
                        ))
        (T (findAtom A (cdr L)))
))

(defun findOtrp(L)
(cond   ((null L) NIL)
        ((atom (car L))  (cond ((findList (car L) (cdr L)))
                               (T (findOtrp (cdr L)))
                         ))
        ((listp (car L)) (cond ((findAtom (car L) (cdr L)))
                               (T (findOtrp (cdr L)))
                         ))
))

(defun del (L Res)
(cond   ((null L) Res)
        ((findOtrp (car L)) (del (cdr L) Res))
        (T (del (cdr L) (cons (car L) Res)))
))

(defun memberP (A L)
(cond   ((null L) NIL)
        ((atom A) (cond ((atom (car L)) (cond ((eq A (car L)))
                                              (T (memberP A (cdr L)))
                                        ))
                        (T (memberP A (cdr L)))
                  ))
        ((listp A) (cond ((listp (car L)) (cond ((eq (car A) (caar L)))
                                                (T (memberP A (cdr L)))
                                          ))
                         (T (memberP A (cdr L)))
                   ))
        (T (memberP A (cdr L)))
))

(defun makeSet(L Res)
(cond   ((null L) Res)
        ((memberP (car L) Res) (makeSet (cdr L) Res))
        (T (makeSet (cdr L) (cons (car L) Res)))
))

(defun delDupl (L)
(cond   ((null L) NIL)
        (T (cons (makeSet (car L) NIL) (delDupl (cdr L))))
))

(defun in (L0 L1)
(cond   ((null L1) NIL)
        ((equal L0 (car L1)) T)
        (T (in L0 (cdr L1)))
))

(defun searchMorgan(L0 L1)
(cond   ((null L0) T)
        ((memberP (car L0) L1) (searchMorgan (cdr L0) L1))
        (T NIL)
))

(defun searchMorganList(L0 L Res)
(cond   ((null L) Res)
        ((searchMorgan L0 (car L)) (searchMorganList L0 (cdr L) Res))
        (T (searchMorganList L0 (cdr L) (cons (car L) Res)))
))

(defun morgan(L0 L)
(cond   ((null L0) L)
        ((in (car L0) L) (morgan (cdr L0) (searchMorganList (car L0) L (list (car L0)))))
        (T (morgan (cdr L0) L))
))

(defun preMorgan (L) (morgan L L ))

(defun transOtr (L)
(cond   
        ((listp L) (list '~ (car L)))
        (T L)
))

(defun disjun (L)
(cond   ((null L) T)
        ((null (cdr L)) (cond ((listp (transOtr(car L))) (list (car (transOtr(car L))) (cadr (transOtr(car L)))))
                              (T (list (car L)))
                        ))
        (T (append (append (cond ((listp (transOtr(car L))) (list (car (transOtr(car L))) (cadr (transOtr(car L)))))
                                 (T (list (car L)))
                           ) '(^)) (disjun (cdr L))))
))

(defun createKNF (L) 
(cond   ((null (cdr L)) (list (disjun (car L))))
        (T (append (cons (disjun (car L)) '(&)) (createKNF (cdr L))))
))

(print (postReadStr (readStr (coerce (read) 'list))))

