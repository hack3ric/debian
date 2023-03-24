# Chromium Patches for Debian

Mainly taken from openSUSE, added FFmpeg patch to support riscv64 in its build scripts since openSUSE and Arch patches its system FFmpeg to open "backdoor" for Chromium, while Debian uses Chromium's own vendored version.

Before applying the patch, un-apply the ppc64le patches since we all modified the same platform-checking macros.

Note that `valgrind` should be excluded for now in `debian/control`:

``` diff
 Depends:
   ...
-  valgrind
+  valgrind [!riscv64]
```
