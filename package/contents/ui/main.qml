import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    property alias configuredOpacityPercent: backend.configuredOpacityPercent
    property alias opacityPercent: backend.opacityPercent
    property alias opacityEnabled: backend.opacityEnabled
    property alias includeNormalWindows: backend.includeNormalWindows
    property alias includeDialogs: backend.includeDialogs
    property alias includePanels: backend.includePanels
    property alias includeNotifications: backend.includeNotifications
    property alias includeMenus: backend.includeMenus
    property alias includeTooltips: backend.includeTooltips
    property alias includeSplashScreens: backend.includeSplashScreens
    property alias backendLoaded: backend.backendLoaded
    property alias backendAvailable: backend.backendAvailable
    property alias commandPending: backend.commandPending
    property alias lastError: backend.lastError

    readonly property int minimumOpacity: backend.minimumOpacity
    readonly property int maximumOpacity: backend.maximumOpacity
    readonly property var opacityPresets: backend.opacityPresets
    readonly property int displayMode: normalizedDisplayMode(Plasmoid.configuration.displayMode)
    readonly property int controlWidth: Math.max(160, Math.min(480, Plasmoid.configuration.sliderWidth))
    readonly property bool horizontalPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool anyScopeEnabled: backend.anyScopeEnabled
    readonly property bool effectActive: backend.effectActive

    Plasmoid.icon: "edit-opacity"
    Plasmoid.status: !backendAvailable || lastError.length > 0
        ? PlasmaCore.Types.NeedsAttentionStatus
        : effectActive
            ? PlasmaCore.Types.ActiveStatus
            : PlasmaCore.Types.PassiveStatus
    Plasmoid.title: i18n("KOpacity")

    toolTipMainText: i18n("KOpacity")
    toolTipSubText: lastError.length > 0
        ? lastError
        : effectActive
            ? i18n("%1% opacity", opacityPercent)
            : i18n("Full opacity")

    function refreshStatus() {
        backend.refreshStatus();
    }

    function applyOpacity(value) {
        backend.applyOpacity(value);
    }

    function setEnabled(enabled) {
        backend.setEnabled(enabled);
    }

    function adjustOpacity(delta) {
        backend.adjustOpacity(delta);
    }

    function setScope(scope, enabled) {
        backend.setScope(scope, enabled);
    }

    function setDisplayMode(mode) {
        Plasmoid.configuration.displayMode = normalizedDisplayMode(mode);
    }

    function normalizedDisplayMode(mode) {
        var value = Math.round(Number(mode));
        if (!Number.isFinite(value)) {
            return 0;
        }
        if (value >= 3) {
            return 3;
        }
        return Math.max(0, value);
    }

    onExpandedChanged: function() {
        if (root.expanded) {
            refreshStatus();
        }
    }

    compactRepresentation: CompactRepresentation {
        controller: root
    }

    fullRepresentation: FullRepresentation {
        controller: root
    }

    BackendClient {
        id: backend

        initialCommand: "sync"
    }

    Component.onCompleted: {
        var migratedMode = normalizedDisplayMode(Plasmoid.configuration.displayMode);
        if (Plasmoid.configuration.displayMode !== migratedMode) {
            Plasmoid.configuration.displayMode = migratedMode;
        }
    }
}
