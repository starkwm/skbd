# skbd

Stark Key Bind Daemon for macOS.

`skbd` is a simple service that can run in the background. It lets you bind
different key combinations to running shell commands.

## Installation

To quickest way to get `skbd` installed is using [Homebrew](https://brew.sh).

    brew tap starkwm/formulae
    brew install starkwm/formulae/skbd

If installed with Homebrew, this allows you to use `brew services` to manage
running `skbd`.

You can also build from source, which requires the latest Xcode.

    git clone git@github.com:starkwm/skbd.git
    cd skbd
    make

If built from source, you will need to create your own Launch Agent `.plist`
file to run `skbd` in the background.

## Configuration

You configure `skbd` using a configuration file located in
`~/.config/skbd/skbdrc` by default, or can be overridden using the `-c/--config`
flag.

You can declare key binds by specifying the modifier keys and the key to bind to
a command.

    cmd + shift - k: open -a iTerm

The command will be executed using the shell defined by the `$SHELL` environment
variable. It will fallback to `/bin/bash` if not defined.

The shell defined by the `$SHELL` environment variable run the command. It will
fallback to `/bin/bash` if not defined.

The available modifier key values are:

- `shift`
- `control`/`ctrl`
- `option`/`opt`/`alt`
- `command`/`cmd`
- `hyper`

The `hyper` modifier key, is a shortcut for using `shift`, `control`, `opt`, and
`command` all together.

Comments can be added to the configuration file with lines starting with `#`.
