# Key bindings

[Documentation index](index.md)

## Syntax

Join modifiers with `+`, separate them from the key with `-`, and put the shell command after `:`:

```text
cmd + shift - k: open -a iTerm
```

Modifiers are optional. A binding can use a key on its own:

```text
f19: open -a Terminal
```

The first matching binding runs. By default, `skbd` consumes the matching key event so the frontmost application does not receive it.

## Passthrough

Use `->` instead of `:` to run the command and pass the key event through to the application:

```text
cmd + shift - k -> open -a iTerm
```

## Shell commands

Commands run with the shell named by `$SHELL`, falling back to `/bin/bash` when the variable is unset or empty. `skbd` passes the command to that shell with `-c` and discards the command's standard output and standard error. Redirect output in the command if you need a log.

The command can start on the line after `:`. End each continued command line with `\`:

```text
ctrl + shift - return:
    osascript -e 'if application "Ghostty" is running then' \
              -e '  tell application "System Events"' \
              -e '    click menu item "New Window" of menu "File" of menu bar 1 of process "Ghostty"' \
              -e '  end tell' \
              -e 'else' \
              -e '  tell application "Ghostty" to activate' \
              -e 'end if' > /dev/null
```

## Modifiers

| Modifier | Keys |
| --- | --- |
| `shift` | Shift |
| `ctrl` | Control |
| `opt`, `alt` | Option |
| `cmd` | Command |
| `meh` | Shift + Control + Option |
| `hyper` | Shift + Control + Option + Command |
| `fn` | Fn / Globe |

Prefix `shift`, `ctrl`, `opt`, `alt`, or `cmd` with `l` or `r` to require the left or right modifier key. For example, `lctrl`, `rshift`, and `ropt` are valid. Without a prefix, either side matches.

```text
lctrl + rshift - k: open -a Terminal
hyper - k: open -a Terminal
```

Modifiers must match the binding. For example, holding Shift prevents a `cmd - k` binding from matching.

## Keys

### Letters, digits, and punctuation

Use lowercase letters `a` through `z`, digits `0` through `9`, or these punctuation characters:

```text
` - = [ ] ' ; \ , . /
```

Character keys use the current ASCII-capable keyboard layout when the key map is first loaded. A punctuation key is written directly after the modifier separator:

```text
cmd - -: open -a Terminal
cmd - [: open -a Finder
cmd - ]: open -a Safari
```

### Named keys

| Group | Names |
| --- | --- |
| Typing | `return`, `tab`, `space`, `backspace`, `escape`, `backtick` |
| Navigation | `delete`, `home`, `end`, `pageup`, `pagedown`, `insert` |
| Arrows | `left`, `right`, `up`, `down` |
| Function keys | `f1` through `f20` |

Use `return` for the Return key. `backspace` is backward delete, and `delete` is forward delete.

Navigation, arrow, and function key names automatically include the `fn` event flag when matching a shortcut.

### Hexadecimal key codes

Use a hexadecimal macOS virtual key code prefixed with `0x` to bind by code:

```text
ctrl - 0x31: open -a Terminal
```

`0x31` is the Space key. Hexadecimal codes do not add the implicit `fn` flag used by named navigation, arrow, and function keys. Include `fn` in the modifiers when needed.

See [configuration](configuration.md) for file loading, automatic reloads, and application block lists.
