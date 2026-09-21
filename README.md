# KOpacity

KOpacity is a Plasma 6 widget for setting one global opacity level across
selected KWin window categories.

## Features

- A 50–100% opacity slider with one-percent precision.
- Presets at 50%, 70%, 85%, and 100%.
- Global scope controls for:
  - application windows (enabled by default),
  - dialogs (enabled by default),
  - panels and docks (disabled by default),
  - notifications and on-screen displays (disabled by default),
  - menus and popups (disabled by default),
  - tooltips (disabled by default),
  - splash screens (disabled by default).
- Four per-widget panel appearances:
  - automatic,
  - icon,
  - percentage,
  - full controls.
- The standard popup is available from icon-based controls, while the
  Configure dialog also exposes the effect switch, slider, presets, and scope
  controls for slider-only layouts.
- The popup includes an immediate per-widget appearance selector.
- Width-aware fallbacks for narrow horizontal and vertical panels.
- A self-contained KWin JavaScript backend; no hardcoded home-directory paths.
- Backend reconciliation when the widget starts or an effect setting changes.
- Rollback of configuration changes when the backend cannot be loaded.

The desktop, lock screen, critical notifications, input methods, and KWin's own
surfaces are always excluded.

## Requirements

- KDE Plasma 6
- KWin 6
- `qdbus6`
- `kreadconfig6` and `kwriteconfig6`
- `kpackagetool6` for installation
- a POSIX shell and `timeout`

The widget is intentionally Plasma/KWin-specific. It is not a GNOME, Xfce, or
Cinnamon extension.

Release 0.1.0 was validated on Plasma/KWin 6.7.4 with Wayland. Other Plasma 6
versions and X11 have not been validated for this release.

## Install a release

Download the `.plasmoid` archive from:
https://github.com/xalgia/kopacity/releases

Install it with Plasma's **Install Widget From Local File** action, or:

```sh
kpackagetool6 --type Plasma/Applet --install kopacity-0.1.0.plasmoid
```

Use `--upgrade` instead of `--install` if KOpacity is already installed. Add
**KOpacity** from the widget picker after installation.

Before removing the last widget or uninstalling it, disable the effect. To
uninstall the package:

```sh
kpackagetool6 --type Plasma/Applet --remove io.github.xalgia.kopacity
```

## Development

Checks additionally require `make`, Node.js (`node`), Python 3 (`python3`),
`xmllint`, and Qt 6's `qmllint` available on `PATH`. Packaging also requires
`zip` and `unzip`. These development tools are not needed just to install the
widget from a clone.

Run all static and controller tests:

```sh
make check
```

Build a Store-style `.plasmoid` archive:

```sh
make package
```

The generated archive is placed in `dist/`. The archive contains the contents
of `package/` at its root, as required by KPackage.

## Clone and install on another PC

Install the runtime requirements above on a KDE Plasma 6 PC, then clone with
Git and enter the checkout:

```sh
git clone https://github.com/xalgia/kopacity.git
cd kopacity
```

Install directly from the checkout; no build or archive is required:

```sh
kpackagetool6 --type Plasma/Applet --install package
```

Upgrade an existing development installation:

```sh
kpackagetool6 --type Plasma/Applet --upgrade package
```

Add **KOpacity** from Plasma's widget picker. Disable the effect before removing
the last widget instance or uninstalling the package.

For subsequent updates, run `git pull --ff-only` in the checkout and then the
upgrade command above. Your opacity settings and widget layout are local to
each PC and are not copied by cloning the repository.

## Configuration model

Opacity, enabled state, and transparency scope are global KWin settings shared
by every KOpacity instance. Appearance and requested width are stored per
widget, so a desktop instance can use full controls while a panel instance uses
only a percentage button. The popup and Configure dialog use the same backend
client, so operational controls report and modify the same live state.
Other instances refresh when opened; a closed instance can display stale state.

## Support development

If you find KOpacity useful, consider supporting its development through GitHub
Sponsors. Sponsorship is optional; KOpacity remains free to use.

https://github.com/sponsors/xalgia

## License

MIT
