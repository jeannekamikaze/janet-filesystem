(import ../filesystem :as filesystem)

(defn aeq
  "assert equal"
  [x y]
  (unless (deep= x y)
    (with-dyns [:out stderr]
      (print "expected " x " to equal " y))
    (os/exit 1)))

(defn aet
  "assert true"
  [x]
  (aeq x true))

(defn aef
  "assert false"
  [x]
  (aeq x false))

(filesystem/create-file "test/files/hello.txt")
(filesystem/create-file "test/files/subdir/world.txt")

(aet (filesystem/exists? "test/files/hello.txt"))
(aef (filesystem/exists? "does/not/exist"))
(aeq (filesystem/list-all-files "test/files/")
     @["test/files/subdir/world.txt" "test/files/hello.txt"])

(def new-test-file "test/files/new.txt")
(filesystem/create-file new-test-file)
(aet (filesystem/exists? new-test-file))
(os/rm new-test-file)
(aef (filesystem/exists? new-test-file))

(filesystem/remove-directories "test/files/")
