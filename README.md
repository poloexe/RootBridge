# RootBridge

An iOS developer framework for rootless tweak development. This framework makes it possible to compile "universal" (root + rootless) binaries.

## Universal Binaries

Binaries developed with this framework should be virtually identical in compiled form between rooted or rootless jailbreaks (arm64e ABI aside).

* Ensure all linked third-party libraries/frameworks are using `@rpath` install_names. See HookKit or Modulous frameworks as an example.
* Add the necessary `rpath` options to your project, so the framework is found under either prefix. See Shadow as an example:

```make
YourTweak_LDFLAGS += -rpath /Library/Frameworks -rpath /var/jb/Library/Frameworks
```

* Wrap any jailbreak paths in your code with `[RootBridge getJBPath:path]`.

## Features

* Efficiently detect if your code is running on a rootless platform in runtime.
* Convert path strings to rootless paths if necessary.

`getJBPath:` rewrites only jailbreak roots — `/Library/...` and `/usr/...` become `/var/jb/Library/...` and `/var/jb/usr/...`. Everything else is returned unchanged, including `/var/mobile/...`, app bundle paths, paths already under `/var/jb`, and relative paths.
