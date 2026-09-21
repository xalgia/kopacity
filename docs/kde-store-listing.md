# KDE Store listing draft

Editable draft agreed on 2026-09-21. This is preparation only, not a published
listing. Edit the sections below to add updates and finishing touches.

## Title

KOpacity — Window Transparency Control

## Short description

Adjust window transparency directly from your KDE Plasma 6 panel or desktop.

## Opening paragraph

KOpacity gives you a simple slider, quick presets, and an on/off switch for
window transparency. Choose which window categories are affected and select a
widget appearance that fits your desktop.

## How opacity works

KOpacity applies one shared opacity level to selected window categories. It
does not provide separate opacity settings for individual applications.

## Requirements

- KDE Plasma 6 and KWin 6.
- `qdbus6`, `kreadconfig6`, `kwriteconfig6`, a POSIX shell, and `timeout`.
- `kpackagetool6` for command-line installation.

Validated on Plasma/KWin 6.7.4 with Wayland. Other Plasma 6 versions and X11
have not been validated for this release.

Disable the effect before removing the last widget or uninstalling KOpacity.

## Project and support links

<!-- Public source and issue-tracker links verified without authentication
on 2026-09-21. -->

Source code:
https://github.com/xalgia/kopacity

Bug reports:
https://github.com/xalgia/kopacity/issues

## Support development

If you find KOpacity useful, consider supporting its development through GitHub
Sponsors. Sponsorship is optional; KOpacity remains free to use.

https://github.com/sponsors/xalgia

---

## Preparation notes — not part of the Store description

### Agreed direction

- Use the MIT license.
- Make the source repository public.
- Keep donations optional, not a condition of using the widget.
- Use GitHub Sponsors as the single donation destination:
  https://github.com/sponsors/xalgia
- Use a practical, straightforward description focused on KOpacity's function.
- Place the donation call to action at the bottom of the Store description.
- Keep the distinction between global category controls and per-application
  settings explicit.

### Finishing touches before publication

- [x] Preserve the agreed original description and optional Sponsors wording.
- [x] Add runtime requirements and accurately scoped compatibility information.
- [x] Replace the license's placeholder attribution and include it in the package.
- [ ] Approve AI-generated listing mockups; retain their disclosure labels.
- [x] Make the repository public and verify the project and issue-tracker links.
- [ ] Publish the GitHub release and upload the KDE Store listing.
- [ ] Verify discovery and installation through Get New Widgets.

Editing this document does not change the package metadata, license, repository
visibility, or Store listing. Those remain separate release actions.
