# Development

[Documentation index](index.md)

Run these commands from the repository root:

```sh
make build    # Debug build
make release  # Optimized build
make test     # Run tests
make format   # Format Swift sources
make lint     # Check Swift formatting
make clean    # Remove build products
```

See [getting started](getting-started.md) for build requirements, output locations, and running the daemon.

## Code and tests

`Sources/Skbd` contains argument parsing and daemon startup. `Sources/SkbdCore` contains configuration loading, parsing, file watching, and key event handling.

Keep setup, execution, and assertions in separate statement groups. Place static members before instance members, initializers before instance methods, and private methods after public and internal methods. Keep conformance extensions below the main type.

Parser tests use configuration text so they exercise the lexer too. Lexer tests check the complete token list. Command tests check output from the launched shell. Avoid changing process environment variables in tests because the suite runs in parallel.

`HotKey.matches` compares a binding against an event. Matching is directional. A generic `cmd` binding accepts `lcmd` events, but an `lcmd` binding requires the left modifier flag.

The lock file stays on disk after release so competing processes always lock the same inode. The file's presence does not mean the daemon is running.

Tests create key events without installing a system event tap. To check Accessibility permissions, live key delivery, and automatic reloads, run the daemon with a temporary configuration and exercise those behaviors manually.
