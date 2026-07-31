import QtQuick

import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: backend

    property string initialCommand: "status"
    property int configuredOpacityPercent: 75
    property int opacityPercent: 100
    property bool opacityEnabled: false
    property bool includeNormalWindows: true
    property bool includeDialogs: true
    property bool includePanels: false
    property bool includeNotifications: false
    property bool includeMenus: false
    property bool includeTooltips: false
    property bool includeSplashScreens: false
    property bool backendLoaded: false
    property bool backendAvailable: true
    property bool commandPending: false
    property string activeCommand: ""
    property string lastError: ""

    readonly property int minimumOpacity: 50
    readonly property int maximumOpacity: 100
    readonly property bool anyScopeEnabled: includeNormalWindows
        || includeDialogs
        || includePanels
        || includeNotifications
        || includeMenus
        || includeTooltips
        || includeSplashScreens
    readonly property bool effectActive: opacityEnabled
        && opacityPercent < maximumOpacity
        && anyScopeEnabled
        && backendLoaded
    readonly property string controllerPath: fileUrlToPath(Qt.resolvedUrl("../code/kopacityctl"))

    visible: false
    width: 0
    height: 0

    function clamp(value) {
        return Math.min(maximumOpacity, Math.max(minimumOpacity, Math.round(value)));
    }

    function roundedStep(value) {
        return clamp(Math.round(value / 5) * 5);
    }

    function fileUrlToPath(url) {
        var value = url.toString();
        if (value.indexOf("file://") === 0) {
            value = value.substring(7);
        }
        return decodeURIComponent(value);
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function dataValue(data, keys) {
        for (var index = 0; index < keys.length; ++index) {
            if (data[keys[index]] !== undefined) {
                return data[keys[index]];
            }
        }
        return "";
    }

    function statusBool(output, key, fallback) {
        var match = new RegExp("(?:^|\\s)" + key + "=(true|false)(?:\\s|$)").exec(output);
        return match ? match[1] === "true" : fallback;
    }

    function statusNumber(output, key, fallback) {
        var match = new RegExp("(?:^|\\s)" + key + "=([0-9]+)(?:\\s|$)").exec(output);
        return match ? Number(match[1]) : fallback;
    }

    function parseStatus(output) {
        opacityEnabled = statusBool(output, "enabled", opacityEnabled);
        configuredOpacityPercent = clamp(statusNumber(output, "opacity", configuredOpacityPercent));
        opacityPercent = clamp(statusNumber(output, "effective", opacityPercent));
        includeNormalWindows = statusBool(output, "normal", includeNormalWindows);
        includeDialogs = statusBool(output, "dialogs", includeDialogs);
        includePanels = statusBool(output, "panels", includePanels);
        includeNotifications = statusBool(output, "notifications", includeNotifications);
        includeMenus = statusBool(output, "menus", includeMenus);
        includeTooltips = statusBool(output, "tooltips", includeTooltips);
        includeSplashScreens = statusBool(output, "splashes", includeSplashScreens);
        backendLoaded = statusBool(output, "loaded", backendLoaded);
        backendAvailable = statusBool(output, "available", backendAvailable);
    }

    function runControl(command) {
        if (commandPending) {
            return false;
        }

        commandPending = true;
        lastError = "";
        activeCommand = "/bin/sh " + shellQuote(controllerPath) + " " + command;
        executable.exec(activeCommand);
        commandTimeout.restart();
        return true;
    }

    function refreshStatus() {
        runControl("status");
    }

    function applyOpacity(value) {
        var next = clamp(value);
        opacityPercent = next;
        opacityEnabled = next < maximumOpacity;
        runControl("set " + next);
    }

    function setEnabled(enabled) {
        opacityEnabled = enabled;
        opacityPercent = enabled ? configuredOpacityPercent : maximumOpacity;
        runControl(enabled ? "on" : "off");
    }

    function adjustOpacity(delta) {
        applyOpacity(roundedStep(opacityPercent + delta));
    }

    function setScope(scope, enabled) {
        if (scope === "normal") {
            includeNormalWindows = enabled;
        } else if (scope === "dialogs") {
            includeDialogs = enabled;
        } else if (scope === "panels") {
            includePanels = enabled;
        } else if (scope === "notifications") {
            includeNotifications = enabled;
        } else if (scope === "menus") {
            includeMenus = enabled;
        } else if (scope === "tooltips") {
            includeTooltips = enabled;
        } else if (scope === "splashes") {
            includeSplashScreens = enabled;
        }
        runControl("scope " + scope + " " + (enabled ? "on" : "off"));
    }

    Plasma5Support.DataSource {
        id: executable

        engine: "executable"
        connectedSources: []

        function exec(command) {
            connectSource(command);
        }

        onNewData: function(source, data) {
            var stdout = backend.dataValue(data, ["stdout", "standard output", "output"]);
            var stderr = backend.dataValue(data, ["stderr", "standard error"]);
            var exitCodeValue = backend.dataValue(data, ["exit code", "exitCode"]);
            var exitCode = exitCodeValue === "" ? 0 : Number(exitCodeValue);

            if (stdout) {
                backend.parseStatus(stdout);
            }
            if (exitCode > 0) {
                backend.lastError = String(stderr || i18n("KOpacity could not apply the requested change.")).trim();
            }

            backend.commandPending = false;
            backend.activeCommand = "";
            commandTimeout.stop();
            disconnectSource(source);
        }
    }

    Timer {
        id: commandTimeout

        interval: 20000
        repeat: false
        onTriggered: {
            if (backend.activeCommand.length > 0) {
                executable.disconnectSource(backend.activeCommand);
            }
            backend.commandPending = false;
            backend.activeCommand = "";
            backend.lastError = i18n("Timed out while talking to KWin.");
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: !backend.commandPending
        onTriggered: backend.refreshStatus()
    }

    Component.onCompleted: runControl(initialCommand)
}
