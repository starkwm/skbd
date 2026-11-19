# skbd

Stark Key Bind Daemon for macOS.

`skbd` binds keyboard shortcuts to shell commands. Configure modifiers, pass key presses through to applications, and disable shortcuts for selected applications. Configuration changes reload automatically.

## Quick start

Requires macOS 26 or later and Accessibility permission for `skbd`.

```sh
brew tap starkwm/formulae
brew install starkwm/formulae/skbd@2
```

Create `~/.config/skbd/skbdrc` with a binding:

```text
cmd + shift - k: open -a Terminal
```

Grant Accessibility permission before starting `skbd`. On macOS 27.3 or later, use the System & App Protection Override pane and re-add the executable after each upgrade or rebuild. See [Grant Accessibility permission](docs/getting-started.md#grant-accessibility-permission).

Start the daemon now and at login:

```sh
brew services start skbd@2
```

See [getting started](docs/getting-started.md) for source builds or the [configuration guide](docs/configuration.md) for file loading and automatic reloads.

## Documentation

The [documentation index](docs/index.md) links to all guides and references.

- [Configuration](docs/configuration.md)
- [Key bindings](docs/key-bindings.md)
- [Modifiers and keys](docs/key-bindings.md#modifiers)
- [Command line](docs/cli.md)
- [Development](docs/development.md)
