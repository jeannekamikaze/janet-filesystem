# janet-filesystem

A library for working with the file system.

```clojure
# Common

(filesystem/exists? "some/directory")
(filesystem/exists? "some/file.txt")

# Directories

(filesystem/list-all-files "some/directory")
(filesystem/create-directories "creates/all/subdirectories")
(filesystem/remove-directories "removes/the/directory/recursively")
(filesystem/recreate-directories "removes/recursively/and/creates/again")

# Files

(filesystem/with-file [file "path/to/file.txt" :wb]
    (file/write file "Like 'with', but creates the file and all directories in its path."))

(filesystem/create-file "creates/all/directories/and/the/file.txt")
(filesystem/read-file "reads/the/entire/file.txt")
(filesystem/write-file "file.txt" "Conveniently creates all directories too.")
(filesystem/copy-file "source.txt" "destination.txt")
```

## Installation

```
[sudo] jpm install filesystem
```

## License

Licensed under the MIT License.
See LICENSE for details.
