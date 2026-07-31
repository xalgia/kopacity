import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Kirigami.FormLayout {
    id: page

    // Plasma injects the complete applet configuration into every page.
    // Declare appearance and panel-layout keys here even though this page
    // intentionally leaves them unchanged.
    property int cfg_displayMode: 0
    property int cfg_displayModeDefault: 0
    property int cfg_sliderWidth: 240
    property int cfg_sliderWidthDefault: 240
    property var cfg_expanding
    property var cfg_length

    property bool includeNormalWindows: true
    property bool includeDialogs: true
    property bool includePanels: false
    property bool includeNotifications: false
    property bool includeMenus: false
    property bool includeTooltips: false
    property bool includeSplashScreens: false
    property bool commandPending: false
    property string activeCommand: ""
    property string lastError: ""

    readonly property string controllerPath: fileUrlToPath(Qt.resolvedUrl("../code/kopacityctl"))

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

    function parseStatus(output) {
        includeNormalWindows = statusBool(output, "normal", includeNormalWindows);
        includeDialogs = statusBool(output, "dialogs", includeDialogs);
        includePanels = statusBool(output, "panels", includePanels);
        includeNotifications = statusBool(output, "notifications", includeNotifications);
        includeMenus = statusBool(output, "menus", includeMenus);
        includeTooltips = statusBool(output, "tooltips", includeTooltips);
        includeSplashScreens = statusBool(output, "splashes", includeSplashScreens);
    }

    function runControl(command) {
        if (commandPending) {
            return;
        }

        commandPending = true;
        lastError = "";
        activeCommand = "/bin/sh " + shellQuote(controllerPath) + " " + command;
        executable.exec(activeCommand);
        commandTimeout.restart();
    }

    function setScope(scope, enabled) {
        runControl("scope " + scope + " " + (enabled ? "on" : "off"));
    }

    CheckBox {
        text: i18n("Application windows")
        checked: page.includeNormalWindows
        enabled: !page.commandPending
        onToggled: page.setScope("normal", checked)
    }

    CheckBox {
        text: i18n("Dialogs")
        checked: page.includeDialogs
        enabled: !page.commandPending
        onToggled: page.setScope("dialogs", checked)
    }

    CheckBox {
        text: i18n("Panels and docks")
        checked: page.includePanels
        enabled: !page.commandPending
        onToggled: page.setScope("panels", checked)
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("Additional surfaces")
        font.weight: Font.DemiBold
    }

    CheckBox {
        text: i18n("Notifications and on-screen displays")
        checked: page.includeNotifications
        enabled: !page.commandPending
        onToggled: page.setScope("notifications", checked)
    }

    CheckBox {
        text: i18n("Menus and popups")
        checked: page.includeMenus
        enabled: !page.commandPending
        onToggled: page.setScope("menus", checked)
    }

    CheckBox {
        text: i18n("Tooltips")
        checked: page.includeTooltips
        enabled: !page.commandPending
        onToggled: page.setScope("tooltips", checked)
    }

    CheckBox {
        text: i18n("Splash screens")
        checked: page.includeSplashScreens
        enabled: !page.commandPending
        onToggled: page.setScope("splashes", checked)
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("These are global KWin settings shared by every KOpacity widget. Changes take effect immediately.")
        wrapMode: Text.Wrap
    }

    Label {
        Layout.fillWidth: true
        text: i18n("The desktop, lock screen, critical notifications, input methods, and KWin's own surfaces always remain opaque.")
        wrapMode: Text.Wrap
    }

    Label {
        Layout.fillWidth: true
        visible: page.lastError.length > 0
        color: Kirigami.Theme.negativeTextColor
        text: page.lastError
        wrapMode: Text.Wrap
    }

    Plasma5Support.DataSource {
        id: executable

        engine: "executable"
        connectedSources: []

        function exec(command) {
            connectSource(command);
        }

        onNewData: function(source, data) {
            var stdout = page.dataValue(data, ["stdout", "standard output", "output"]);
            var stderr = page.dataValue(data, ["stderr", "standard error"]);
            var exitCodeValue = page.dataValue(data, ["exit code", "exitCode"]);
            var exitCode = exitCodeValue === "" ? 0 : Number(exitCodeValue);

            if (stdout) {
                page.parseStatus(stdout);
            }
            if (exitCode > 0) {
                page.lastError = String(stderr || i18n("KOpacity could not apply the requested change.")).trim();
            }

            page.commandPending = false;
            page.activeCommand = "";
            commandTimeout.stop();
            disconnectSource(source);
        }
    }

    Timer {
        id: commandTimeout

        interval: 20000
        repeat: false
        onTriggered: {
            if (page.activeCommand.length > 0) {
                executable.disconnectSource(page.activeCommand);
            }
            page.commandPending = false;
            page.activeCommand = "";
            page.lastError = i18n("Timed out while talking to KWin.");
        }
    }

    Component.onCompleted: runControl("status")
}
