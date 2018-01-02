
[smv - safe mv](./smv_logo2.png)

-----
[![codecov](https://codecov.io/gh/capt8bit/smv/branch/master/graph/badge.svg)](https://codecov.io/gh/capt8bit/smv)

`smv` (safe mv) is a simple safety wrapper around `mv(1)`.

Sorting through backup files can be nerve-racking. You may have different files
with the same name and the same file with different names. Dupe-finding tools
are great, but you still have the problem of sorting through your 20
`Untitled.docx` files.

With `smv` you can safely organize your files into directories without
overwriting files of the same name.

`smv` behaves exactly like `mv(1)`, with the following exceptions:

1. If the source is a duplicate of the target, the source file will be deleted.
1. If the source and target have the same name, and different content, the file will be moved to `TARGET_$(date '+%Y-%m-%d_%H-%M-%S')`.
1. If the source and target are both directories, their contents will be safely merged together.
1. `smv` accepts no flags.

### Example

~~~{.bash}
$ ls -1 SOURCE/
  FILE_A
  FILE_B
  FILE_C
$ ls -1 TARGET/
  FILE_B
  FILE_C
$ smv SOURCE/* TARGET/
$ ls -1 SOURCE/
$ ls -1 TARGET/
  FILE_A
  FILE_B
  FILE_C
  FILE_C_2018-01-01_21-56-09
~~~

