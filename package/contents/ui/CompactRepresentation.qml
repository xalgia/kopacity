import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

Item {
    id: compact

    required property var controller

    readonly property int automaticMode: 0
    readonly property int iconMode: 1
    readonly property int percentageMode: 2
    readonly property int sliderMode: 3
    readonly property int controlsMode: 4
    readonly property int effectiveMode: {
        if (controller.displayMode === sliderMode && width < Kirigami.Units.gridUnit * 5) {
            return iconMode;
        }
        if (controller.displayMode === controlsMode && width < Kirigami.Units.gridUnit * 10) {
            return percentageMode;
        }
        if (controller.displayMode !== automaticMode) {
            return controller.displayMode;
        }
        if (width >= 250) {
            return controlsMode;
        }
        if (width >= Kirigami.Units.gridUnit * 3) {
            return percentageMode;
        }
        return iconMode;
    }
    readonly property int controlExtent: Math.max(28, Math.min(32, height))

    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    Layout.preferredWidth: {
        if (!controller.horizontalPanel || controller.displayMode === iconMode) {
            return Kirigami.Units.iconSizes.medium;
        }
        if (controller.displayMode === percentageMode) {
            return Kirigami.Units.gridUnit * 3.5;
        }
        if (controller.displayMode === sliderMode) {
            return controller.sliderWidth;
        }
        if (controller.displayMode === controlsMode) {
            return controller.sliderWidth + Kirigami.Units.gridUnit * 7;
        }
        return Math.max(300, controller.sliderWidth + Kirigami.Units.gridUnit * 5);
    }
    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

    implicitWidth: Layout.preferredWidth
    implicitHeight: Layout.preferredHeight

    Loader {
        anchors.fill: parent
        sourceComponent: {
            switch (compact.effectiveMode) {
            case compact.percentageMode:
                return percentageComponent;
            case compact.sliderMode:
                return sliderComponent;
            case compact.controlsMode:
                return controlsComponent;
            default:
                return iconComponent;
            }
        }
    }

    Component {
        id: iconComponent

        Item {
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                onClicked: function(mouse) {
                    if (mouse.button === Qt.MiddleButton) {
                        compact.controller.setEnabled(!compact.controller.opacityEnabled);
                    } else {
                        compact.controller.expanded = !compact.controller.expanded;
                    }
                }

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    opacity: compact.controller.effectActive ? 1 : 0.55
                    source: "edit-opacity"
                }

                PC3.BusyIndicator {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.9
                    height: width
                    running: compact.controller.commandPending
                    visible: running
                }
            }
        }
    }

    Component {
        id: percentageComponent

        PC3.ToolButton {
            text: i18n("%1%", compact.controller.opacityPercent)
            enabled: !compact.controller.commandPending
            onClicked: compact.controller.expanded = !compact.controller.expanded
            PC3.ToolTip.text: i18n("Open KOpacity controls")
            PC3.ToolTip.visible: hovered
        }
    }

    Component {
        id: sliderComponent

        Item {
            PC3.Slider {
                id: wideSlider

                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.smallSpacing
                from: compact.controller.minimumOpacity
                to: compact.controller.maximumOpacity
                stepSize: 1
                snapMode: PC3.Slider.SnapAlways
                live: false
                enabled: !compact.controller.commandPending
                value: compact.controller.opacityPercent
                Accessible.name: i18n("Window opacity")
                PC3.ToolTip.text: i18n("%1% opacity", Math.round(wideSlider.value))
                PC3.ToolTip.visible: wideSlider.hovered || wideSlider.pressed

                onPressedChanged: function() {
                    if (!wideSlider.pressed) {
                        compact.controller.applyOpacity(wideSlider.value);
                    }
                }
            }
        }
    }

    Component {
        id: controlsComponent

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            PC3.ToolButton {
                Layout.minimumWidth: compact.controlExtent
                Layout.preferredWidth: compact.controlExtent
                Layout.maximumWidth: compact.controlExtent
                Layout.fillHeight: true
                icon.name: compact.controller.commandPending ? "" : "edit-opacity"
                opacity: compact.controller.effectActive ? 1 : 0.6
                Accessible.name: i18n("Open KOpacity controls")
                onClicked: compact.controller.expanded = !compact.controller.expanded
                PC3.ToolTip.text: Accessible.name
                PC3.ToolTip.visible: hovered

                PC3.BusyIndicator {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.7
                    height: width
                    running: compact.controller.commandPending
                    visible: running
                }
            }

            PC3.ToolButton {
                Layout.minimumWidth: compact.controlExtent
                Layout.preferredWidth: compact.controlExtent
                Layout.maximumWidth: compact.controlExtent
                Layout.fillHeight: true
                text: "−"
                enabled: !compact.controller.commandPending
                    && compact.controller.opacityPercent > compact.controller.minimumOpacity
                Accessible.name: i18n("More transparent")
                onClicked: compact.controller.adjustOpacity(-5)
                PC3.ToolTip.text: Accessible.name
                PC3.ToolTip.visible: hovered
            }

            PC3.Slider {
                id: controlsSlider

                Layout.minimumWidth: Kirigami.Units.gridUnit * 4
                Layout.fillWidth: true
                from: compact.controller.minimumOpacity
                to: compact.controller.maximumOpacity
                stepSize: 1
                snapMode: PC3.Slider.SnapAlways
                live: false
                enabled: !compact.controller.commandPending
                value: compact.controller.opacityPercent
                Accessible.name: i18n("Window opacity")
                onPressedChanged: function() {
                    if (!controlsSlider.pressed) {
                        compact.controller.applyOpacity(controlsSlider.value);
                    }
                }
            }

            PC3.ToolButton {
                Layout.minimumWidth: compact.controlExtent
                Layout.preferredWidth: compact.controlExtent
                Layout.maximumWidth: compact.controlExtent
                Layout.fillHeight: true
                text: "+"
                enabled: !compact.controller.commandPending
                    && compact.controller.opacityPercent < compact.controller.maximumOpacity
                Accessible.name: i18n("More opaque")
                onClicked: compact.controller.adjustOpacity(5)
                PC3.ToolTip.text: Accessible.name
                PC3.ToolTip.visible: hovered
            }

            PC3.ToolButton {
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                Layout.fillHeight: true
                text: i18n("%1%", compact.controller.opacityPercent)
                enabled: !compact.controller.commandPending
                Accessible.name: i18n("Open KOpacity controls")
                onClicked: compact.controller.expanded = !compact.controller.expanded
                PC3.ToolTip.text: Accessible.name
                PC3.ToolTip.visible: hovered
            }
        }
    }
}
