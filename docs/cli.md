# Command line

[Documentation index](index.md)

## Start the daemon

Run `skbd` without options to load `~/.config/skbd/skbdrc` and listen for shortcuts in the foreground:

```sh
skbd
```

Only one instance can run per user. A second instance exits with `skbd is already running`. Press Control-C to stop a foreground process.

## Options

```text
-c, --config <path>     Use a configuration file or directory
-v, --version          Show version information
-h, --help             Show help information
```

Use a different configuration path:

```sh
skbd --config ~/.config/skbd/workrc
skbd -c ~/.config/skbd/conf.d
```

The selected path must exist and contain valid configuration. See [configuration](configuration.md) for directory loading and automatic reloads.

Print help or version information without starting the daemon:

```sh
skbd --help
skbd --version
```

See [getting started](getting-started.md#run-skbd) for managing a Homebrew service or running a source build.
