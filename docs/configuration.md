# Configuration

[Documentation index](index.md)

## Configuration path

By default, `skbd` loads `~/.config/skbd/skbdrc`. The path can refer to a single UTF-8 file or a directory of files. Use `-c` or `--config` to choose another path:

```sh
skbd --config ~/.config/skbd/workrc
skbd --config ~/.config/skbd/conf.d
```

The selected path must exist and contain valid configuration at startup. If it cannot be loaded or parsed, `skbd` prints an error and exits.

## Configuration file

A configuration contains key bindings and an optional application block list:

```text
# Open a terminal with Command-Shift-K.
cmd + shift - k: open -a Terminal

.blocklist [
  "Ghostty"
  "Finder"
]
```

Lines starting with `#` are comments. Blank lines and indentation are allowed. See [key bindings](key-bindings.md) for modifiers, key names, passthrough, and multiline commands.

## Configuration directory

When the configured path is a directory, `skbd` loads all non-hidden regular files directly inside it in lexicographical filename order. It joins their contents with newlines and parses them as one configuration. Subdirectories are not loaded, and files do not need a particular extension.

For example:

```text
~/.config/skbd/conf.d/
  10-applications
  20-windows
  30-blocklist
```

The first matching key binding wins. If several files contain the same binding, the earlier file takes precedence. If the configuration contains multiple `.blocklist` directives, the last one replaces the earlier lists.

## Automatic reloads

Configuration changes reload automatically while `skbd` is running:

- For a single file, edits reload without restarting the daemon.
- For a symlink, `skbd` watches both the symlink location and the resolved target. Editing the target or repointing the symlink reloads the configuration.
- For a directory, editing, adding, removing, or renaming files reloads the configuration.

If an updated configuration cannot be loaded or parsed, `skbd` prints an error and keeps using the last valid configuration.

## Block list

Use `.blocklist` to disable all `skbd` shortcuts while a listed application is frontmost:

```text
.blocklist [
  "Ghostty"
  "Finder"
]
```

Entries are quoted application names, matched exactly against the frontmost application's localized name. While a listed application is frontmost, `skbd` passes key events through without executing commands.
