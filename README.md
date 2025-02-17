# skbd

**Stark Key Bind Daemon for macOS**

`skbd` is a lightweight background service that allows you bind custom key combinations to execute shell commands on macOS.

## Installation

The recommended way to get `skbd` installed is using [Homebrew](https://brew.sh).

    brew tap starkwm/formulae
    brew install starkwm/formulae/skbd

If installed with Homebrew, you can use `brew services` to manage running `skbd` in the background.

Alternatively you can build from source, which requires the latest Xcode (and macOS SDK) to be installed.

    git clone git@github.com:starkwm/skbd.git
    cd skbd
    make

If you build from source, you'll need to create a Launch Agent `.plist` file to run `skbd` in the background.

## Configuration

`skbd` can be configured using a single file, or a directory of multiple files. By default files located in `~/.config/skbd` are used. The path can be overridden using the `-c/--config` flag.

You can declare key binds by specifying one or more modifier keys and the key to bind to a command.

    cmd + shift - k: open -a iTerm

The command will be executed using the shell defined by the `$SHELL` environment variable, falling back to `/bin/bash` if not set. Commands can be split over multiple lines by using a `\` at the end of the line.

    ctrl + shift - enter:
        osascript -e 'if application "Ghostty" is running then' \
                  -e '  tell application "System Events"' \
                  -e '    click menu item "New Window" of menu "File" of menu bar 1 of process "Ghostty"' \
                  -e '  end tell' \
                  -e 'else' \
                  -e '  tell application "Ghostty" to activate' \
                  -e 'end if' > /dev/null

### Modifiers

The available modifiers values are:

- `shift`
- `control`/`ctrl`
- `option`/`opt`/`alt`
- `command`/`cmd`
- `meh`
- `hyper`

The `meh` modifier key, is a shortcut for using `shift`, `control`, and `opt` all together.

The `hyper` modifier key, is a shortcut for using `shift`, `control`, `opt`, and `command` all together.

### Keys

The available key values are:

Okay, here's the list of string values representing keyboard keys, based on the provided key codes:

- Space
- Tab
- Return
- CapsLock
- PageUp
- PageDown
- Home
- End
- Up
- Right
- Down
- Left
- F1
- F2
- F3
- F4
- F5
- F6
- F7
- F8
- F9
- F10
- F11
- F12
- F13
- F14
- F15
- F16
- F17
- F18
- F19
- F20
- Escape
- Delete
- `
- \-
- =
- \[
- ]
- ;
- '
- \\
- .
- ,
- /
- A
- B
- C
- D
- E
- F
- G
- H
- I
- J
- K
- L
- M
- N
- O
- P
- Q
- R
- S
- T
- U
- V
- W
- X
- Y
- Z
- 0
- 1
- 2
- 3
- 4
- 5
- 6
- 7
- 8
- 9

### Comments

Comments can be added to the configuration file with lines starting with `#`.
