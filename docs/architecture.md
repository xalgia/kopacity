# Architecture

## Package boundary

Everything required at runtime is below `package/`:

- `contents/ui/` contains the widget and configuration interfaces.
- `contents/ui/BackendClient.qml` supplies one live state and command model to
  both the widget and its Configure dialog.
- `contents/code/kopacityctl` serializes changes, owns persistent state, and
  controls KWin through D-Bus.
- `contents/code/kwin/main.js` runs inside KWin and applies opacity.

No file is copied into `~/.local/bin`, `~/.local/share/kwin/scripts`, or
`~/.local/state`.

## State

Global effect state is stored in `kwinrc` under:

```text
[Script-io.github.xalgia.kopacity.backend]
```

The stored opacity remains at the last translucent value when KOpacity is
disabled. The controller reports an effective value of 100% while disabled.
Moving a slider below 100% enables the effect again.

Appearance configuration uses the normal per-instance Plasma configuration.

## Applying a change

1. The QML interface invokes the bundled controller through Plasma's executable
   data engine.
2. The controller takes a per-user lock and snapshots the current settings.
3. It writes the requested settings.
4. It unloads and reloads the bundled KWin script.
5. It verifies that the script is loaded when the effect should remain active.
6. If loading fails, it restores the previous settings and attempts to restore
   the previous backend state.

When disabled, the KWin script runs once to restore windows still carrying the
configured KOpacity value, then unloads itself.

## Window safety

The backend handles normal application windows, dialogs, docks,
notifications/OSDs, menus/popups, tooltips, and splash screens as separate
categories. It permanently ignores desktop windows, KWin internal windows, the
lock screen, critical notifications, and input methods.

Restoration only changes a window when its current opacity matches KOpacity's
configured value. This reduces interference with unrelated custom opacity
rules, although an unrelated window using the exact same opacity cannot be
distinguished from a KOpacity-managed window.

## Multiple instances

Effect state is global. Each instance refreshes state when opened. An instance
that remains closed can show stale state after another instance changes the
effect, until it is opened again. Appearance remains local to the instance.
