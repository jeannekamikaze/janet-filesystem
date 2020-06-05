### filesystem.janet
###
### A library for working with the file system.

(import path)

# ------------------------------------------------------------------------------
# Common.
# ------------------------------------------------------------------------------

(defn exists?
  "Check if the given file or directory exists."
  [path]
  (if (os/stat path) true false))

(defn each-subpath
  "Apply a function on each subpath leading to the given path."
  [path func]
  (def indices (string/find-all path/sep path))
  (each idx indices
    (def subpath (string/slice path 0 idx))
    (func subpath))
  (func path))

# ------------------------------------------------------------------------------
# Directories.
# ------------------------------------------------------------------------------

(defn scan-directory
  "Scan a directory recursively, applying the given function on all files and
  directories in a depth-first manner. This function has no effect if the
  directory does not exist."
  [dir func]
  (def names (map (fn [name] (path/join dir name))
    (try (os/dir dir) ([err] @[]))))
  (defn filter-names [mode]
    (filter
      (fn [name] (= mode (os/stat name :mode)))
      names))
  (def files (filter-names :file))
  (def dirs (filter-names :directory))
  (each dir dirs
    (scan-directory dir func))
  (each file files
    (func file))
  (each dir dirs
    (func dir)))

(defn list-all-files
  "List the files in the given directory recursively. Return the paths to all
  files found, relative to the given directory."
  [dir]
  (def files @[])
  (scan-directory dir (fn [file]
    (when (= :file (os/stat file :mode))
      (array/push files file))))
  files)

(defn create-directories
  "Create all directories in the path to the given directory."
  [dir]
  (each-subpath dir
    (fn [subpath]
      (when (not (exists? subpath))
        (os/mkdir subpath)))))

(defn recreate-directory
  "Remove the directory if it exists, then create it again."
  [dir]
  (scan-directory dir (fn [file] (os/rm file)))
  (try (os/rm dir) ([err] nil))
  (os/mkdir dir))

# ------------------------------------------------------------------------------
# Files.
# ------------------------------------------------------------------------------

(defn create-file
  "Create and open a file, creating all the directories leading to the file if
  they do not exist. It is the caller's responsibility to close the file
  afterwards."
  [path &opt mode]
  (def parent-path (path/dirname path))
  (when (and (not (exists? path)) (not (exists? parent-path)))
    (create-directories parent-path))
  (file/open path mode))

(defn read-file
  "Read the entire file into a buffer."
  [path]
  (with [file (file/open path :rb)]
    (if (= file nil)
      ""
      (file/read file :all))))

(defn write-file
  "Write a buffer to a file."
  [path buf]
  (with [file (create-file path :wb)]
    (file/write file buf)))

(defn copy-file
  "Copy a file from source to destination. Creates all directories in the path
  to the destination file if they do not exist."
  [src-path dst-path]
  (def buf-size 4096)
  (def buf (buffer/new buf-size))
  (with [src (file/open src-path :rb)]
    (with [dst (create-file dst-path :wb)]
      (while (def bytes (file/read src buf-size buf))
        (file/write dst bytes)
        (buffer/clear buf)))))