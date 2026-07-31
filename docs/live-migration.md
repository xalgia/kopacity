# Live migration

The currently installed prototype uses `org.codex.windowopacity` and the
separate `codex-opacity-control` KWin script. KOpacity uses a new package and
backend ID, so both can be installed side by side during validation.

The safe migration order is:

1. Install and validate KOpacity while its new backend remains disabled.
2. Copy the live prototype's enabled state, opacity, and scope to KOpacity.
3. Load KOpacity at the same effective opacity.
4. Unload the legacy backend without running its full-opacity restore path.
5. Replace the old panel instance with KOpacity.
6. Remove the legacy helper and script packages only after the new backend has
   remained stable.

This order avoids a full-opacity flash and preserves the active session.
