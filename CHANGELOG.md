# Changelog

## 0.1.0

- Added a self-contained Plasma 6 and KWin implementation.
- Added global application-window, dialog, and panel/dock scope controls.
- Added opt-in notification/OSD, menu/popup, tooltip, and splash-screen scopes.
- Added automatic, icon, percentage, wide-slider, and full-control appearances.
- Fixed Plasma configuration-page property injection so appearance modes save
  and apply correctly.
- Fixed live status parsing and wide-layout behavior in vertical panels.
- Made the full-controls opacity icon open the standard widget popup.
- Added the effect switch, opacity slider, presets, and scope controls to the
  Configure dialog using the shared live backend client.
- Limited the public slider to the safer 50–100% range.
- Preserved the last translucent value when switching to full opacity.
- Added backend reconciliation, rollback behavior, and automated controller
  tests.
