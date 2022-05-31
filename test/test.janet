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

(defn run-test
  "Create the test directory, run the test and clean up."
  [test]
  (def test-directory "tmp")
  (filesystem/recreate-directories test-directory)
  (test)
  (filesystem/remove-directories test-directory))

# Check the test harness before running other tests.
# tests exists? for existent directories.
(run-test (fn []
  (aet (filesystem/exists? "tmp/"))))
(aef (filesystem/exists? "tmp/"))

# exists? for non-existent files/directories.
(aef (filesystem/exists? "does/not/exist"))

# create-file and exists? for existent files.
(run-test (fn []
  (filesystem/create-file "tmp/files/hello.txt")
  (aet (filesystem/exists? "tmp/files/hello.txt"))))

# list-all-files
(run-test (fn []
  (filesystem/create-file "tmp/files/hello.txt")
  (filesystem/create-file "tmp/files/subdir/world.txt")
  (aeq (filesystem/list-all-files "tmp/files/")
      @["tmp/files/subdir/world.txt" "tmp/files/hello.txt"])))

# create-directories
(run-test (fn []
  (def test-dirs "tmp/a/b/c")
  (filesystem/create-directories test-dirs)
  (aet (filesystem/exists? test-dirs))))

# remove-directories
(run-test (fn []
  (def test-dirs "tmp/a/b/c")
  (filesystem/create-directories test-dirs)
  (aet (filesystem/exists? test-dirs))
  (filesystem/remove-directories test-dirs)
  (aef (filesystem/exists? test-dirs))))

# recreate-directories, empty case
(run-test (fn []
  (def test-dirs "tmp/a/b/c")
  (filesystem/recreate-directories test-dirs)
  (aet (filesystem/exists? test-dirs))))

# with-file
(run-test (fn []
  (def test-file "tmp/a/b/c/foo.txt")
  (filesystem/with-file [file test-file :wb]
    (aet (filesystem/exists? test-file)))))

# create-file
(run-test (fn []
  (def new-test-file "tmp/files/new.txt")
  (filesystem/create-file new-test-file)
  (aet (filesystem/exists? new-test-file))))

# read-file and write-file
(run-test (fn []
  (def test-file "tmp/a/b/c/file.txt")
  (def test-string "Hello world!")
  (filesystem/write-file test-file test-string)
  (aeq (string (filesystem/read-file test-file)) test-string)))

# copy-file
(run-test (fn []
  (def src "tmp/a/b/c/src.txt")
  (def dst "tmp/a/b/c/dst.txt")
  (def test-string "Hello")
  (filesystem/write-file src test-string)
  (filesystem/copy-file src dst)
  (aet (filesystem/exists? dst))
  (aeq (string (filesystem/read-file dst)) test-string)))
