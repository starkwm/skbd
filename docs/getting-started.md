# Getting started

[Documentation index](index.md)

## Requirements

- macOS 26 or later
- Accessibility permission for `skbd`
- Xcode 26 or later when building from source, with Swift 6.2

## Installation

### Homebrew

Install with [Homebrew](https://brew.sh):

```sh
brew tap starkwm/formulae
brew install starkwm/formulae/skbd@2
```

The Homebrew formula targets Apple silicon Macs. It installs an executable named `skbd`; use `skbd@2` when managing the Homebrew service.

### Build from source

```sh
git clone https://github.com/starkwm/skbd.git
cd skbd
make build
```

The development binary is written to `.build/debug/skbd`. Use `make release` for an optimized build in `.build/release/skbd`.

A source build is not installed as a background service automatically. To run at login, create a Launch Agent that starts the executable using its absolute path.

## Create a configuration

Create the configuration directory:

```sh
mkdir -p ~/.config/skbd
```

Save a binding in `~/.config/skbd/skbdrc`:

```text
cmd + shift - k: open -a Terminal
```

The configuration must exist before starting `skbd`. See [configuration](configuration.md) for directory configurations, automatic reloads, and application block lists, and [key bindings](key-bindings.md) for the syntax reference.

## Run skbd

Start a Homebrew installation now and at login:

```sh
brew services start skbd@2
```

For a source build, run the development binary in the foreground:

```sh
.build/debug/skbd
```

Enable Accessibility permission in System Settings > Privacy & Security > Accessibility. See [Apple's instructions for granting access](https://support.apple.com/en-au/guide/mac-help/mh43185/mac). Restart `skbd` after granting permission. If startup reports `failed to create event tap`, check this permission.

For Homebrew installations, restart or stop the service with:

```sh
brew services restart skbd@2
brew services stop skbd@2
```

Press Control-C to stop a foreground process. See [command-line usage](cli.md) for custom configuration paths and other options.
