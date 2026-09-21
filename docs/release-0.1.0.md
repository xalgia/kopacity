# Release 0.1.0 validation

Validated on 2026-09-21 using Plasma/KWin 6.7.4 and Qt 6.11.2 on Wayland.

## Passed

- Shell, JavaScript, XML, JSON, and QML checks, plus mocked controller tests.
- Repository MIT terms matched the SPDX MIT reference; attribution is
  `Copyright (c) 2026 Xalgia`.
- The archive includes a byte-identical copy of the repository license.
- Archive integrity and every packaged file match the release source.
- Fresh archive installation, same-version upgrade, and removal in an isolated
  package root and private D-Bus/KWin session.
- Real KWin application-window opacity: 100%, 70%, and 85%.
- Excluding the application-window scope restores full opacity.
- Disabling restores full opacity; re-enabling restores the previous 85% value.
- Upgrade and backend synchronization preserve the configured effect.
- The installed widget starts in `plasmawindowed`; its newly created window
  inherits the active opacity and restores to 100% when the effect is disabled.
- Removal after disabling leaves the isolated backend unloaded.
- The user's live KWin and Plasma configuration files remained byte-identical.
- All 57 historical Git blobs were scanned for common credential patterns,
  private-key headers, private host paths, and private IPv4 addresses, with no
  findings. Commit authors use the public GitHub noreply address. No Actions
  runs, issues, wiki, or forks were present before the public-visibility change.

## Limits

- These results do not validate every Plasma 6 version or X11.
- The test Qt dialog was classified by KWin as a normal window, so it did not
  independently validate the dialog category. Optional surface categories have
  controller-test coverage, not exhaustive live-application coverage.
- UI launch was tested; this is not a complete automated UI-interaction suite.
- The history scan is a precaution, not a guarantee that every possible secret
  format is detectable.
- KDE Store discovery and installation remain a separate post-publication check.

## Listing media

The owner requested AI-generated visuals. The review assets are explicitly
labeled **AI-generated mockup** and are not evidence of runtime validation.
They must be approved before being added to the public listing. Generation used
the built-in image tool; the popup layout was based on a native render of the
actual `FullRepresentation.qml` component. Local review images and prompts are
kept in the ignored `dist/store-review/` directory until approval.
