import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

ColumnLayout {
    id: panel

    required property var controller

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.minimumHeight: implicitHeight
    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: "edit-opacity"
        }

        PC3.Label {
            Layout.fillWidth: true
            text: i18n("KOpacity")
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        PC3.Switch {
            checked: panel.controller.opacityEnabled
            enabled: !panel.controller.commandPending
                && panel.controller.backendAvailable
            Accessible.name: checked ? i18n("Disable opacity") : i18n("Enable opacity")
            onToggled: panel.controller.setEnabled(checked)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PC3.ToolButton {
            icon.name: "list-remove-symbolic"
            enabled: !panel.controller.commandPending
                && panel.controller.opacityPercent > panel.controller.minimumOpacity
            Accessible.name: i18n("More transparent")
            onClicked: panel.controller.adjustOpacity(-5)
            PC3.ToolTip.text: Accessible.name
            PC3.ToolTip.visible: hovered
        }

        PC3.Slider {
            Layout.fillWidth: true
            from: panel.controller.minimumOpacity
            to: panel.controller.maximumOpacity
            stepSize: 1
            snapMode: PC3.Slider.SnapAlways
            live: false
            enabled: !panel.controller.commandPending
                && panel.controller.backendAvailable
            value: panel.controller.opacityPercent
            Accessible.name: i18n("Window opacity")
            onPressedChanged: {
                if (!pressed) {
                    panel.controller.applyOpacity(value);
                }
            }
        }

        PC3.ToolButton {
            icon.name: "list-add-symbolic"
            enabled: !panel.controller.commandPending
                && panel.controller.opacityPercent < panel.controller.maximumOpacity
            Accessible.name: i18n("More opaque")
            onClicked: panel.controller.adjustOpacity(5)
            PC3.ToolTip.text: Accessible.name
            PC3.ToolTip.visible: hovered
        }

        PC3.Label {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
            text: i18n("%1%", panel.controller.opacityPercent)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            model: [60, 75, 85, 100]

            PC3.Button {
                required property int modelData

                Layout.fillWidth: true
                text: i18n("%1%", modelData)
                enabled: !panel.controller.commandPending
                    && panel.controller.backendAvailable
                onClicked: panel.controller.applyOpacity(modelData)
            }
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
    }

    PC3.Label {
        Layout.fillWidth: true
        text: i18n("Make transparent")
        font.weight: Font.DemiBold
    }

    PC3.CheckBox {
        Layout.fillWidth: true
        text: i18n("Application windows")
        checked: panel.controller.includeNormalWindows
        enabled: !panel.controller.commandPending
            && panel.controller.backendAvailable
        onToggled: panel.controller.setScope("normal", checked)
    }

    PC3.CheckBox {
        Layout.fillWidth: true
        text: i18n("Dialogs")
        checked: panel.controller.includeDialogs
        enabled: !panel.controller.commandPending
            && panel.controller.backendAvailable
        onToggled: panel.controller.setScope("dialogs", checked)
    }

    PC3.CheckBox {
        Layout.fillWidth: true
        text: i18n("Panels and docks")
        checked: panel.controller.includePanels
        enabled: !panel.controller.commandPending
            && panel.controller.backendAvailable
        onToggled: panel.controller.setScope("panels", checked)
    }

    PC3.Label {
        Layout.fillWidth: true
        text: i18n("The desktop, lock screen, menus, notifications, tooltips, and other transient surfaces always remain opaque.")
        color: Kirigami.Theme.disabledTextColor
        font: Kirigami.Theme.smallFont
        wrapMode: Text.Wrap
    }

    PC3.Label {
        Layout.fillWidth: true
        visible: !panel.controller.backendAvailable
        color: Kirigami.Theme.negativeTextColor
        text: i18n("KWin's scripting service is unavailable.")
        wrapMode: Text.Wrap
    }

    PC3.Label {
        Layout.fillWidth: true
        visible: panel.controller.lastError.length > 0
        color: Kirigami.Theme.negativeTextColor
        text: panel.controller.lastError
        wrapMode: Text.Wrap
    }
}
