import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

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

    Switch {
        Kirigami.FormData.label: i18n("Effect:")
        text: i18n("Enabled")
        checked: backend.opacityEnabled
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setEnabled(checked)
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Window opacity:")

        Slider {
            id: configOpacitySlider

            Layout.fillWidth: true
            from: backend.minimumOpacity
            to: backend.maximumOpacity
            stepSize: 1
            snapMode: Slider.SnapAlways
            live: false
            enabled: !backend.commandPending && backend.backendAvailable
            value: backend.opacityPercent
            Accessible.name: i18n("Window opacity")
            onPressedChanged: function() {
                if (!configOpacitySlider.pressed) {
                    backend.applyOpacity(configOpacitySlider.value);
                }
            }
        }

        Label {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
            text: i18n("%1%", Math.round(configOpacitySlider.value))
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Presets:")
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            model: [60, 75, 85, 100]

            Button {
                required property int modelData

                Layout.fillWidth: true
                text: i18n("%1%", modelData)
                enabled: !backend.commandPending && backend.backendAvailable
                onClicked: backend.applyOpacity(modelData)
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("Make transparent")
        font.weight: Font.DemiBold
    }

    CheckBox {
        text: i18n("Application windows")
        checked: backend.includeNormalWindows
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("normal", checked)
    }

    CheckBox {
        text: i18n("Dialogs")
        checked: backend.includeDialogs
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("dialogs", checked)
    }

    CheckBox {
        text: i18n("Panels and docks")
        checked: backend.includePanels
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("panels", checked)
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("Additional surfaces")
        font.weight: Font.DemiBold
    }

    CheckBox {
        text: i18n("Notifications and on-screen displays")
        checked: backend.includeNotifications
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("notifications", checked)
    }

    CheckBox {
        text: i18n("Menus and popups")
        checked: backend.includeMenus
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("menus", checked)
    }

    CheckBox {
        text: i18n("Tooltips")
        checked: backend.includeTooltips
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("tooltips", checked)
    }

    CheckBox {
        text: i18n("Splash screens")
        checked: backend.includeSplashScreens
        enabled: !backend.commandPending && backend.backendAvailable
        onToggled: backend.setScope("splashes", checked)
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
        visible: backend.lastError.length > 0
        color: Kirigami.Theme.negativeTextColor
        text: backend.lastError
        wrapMode: Text.Wrap
    }

    Label {
        Layout.fillWidth: true
        visible: !backend.backendAvailable
        color: Kirigami.Theme.negativeTextColor
        text: i18n("KWin's scripting service is unavailable.")
        wrapMode: Text.Wrap
    }

    BackendClient {
        id: backend
    }
}
