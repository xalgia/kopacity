import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_displayMode: displayMode.currentIndex
    property alias cfg_sliderWidth: sliderWidth.value
    property int cfg_displayModeDefault: 0
    property int cfg_sliderWidthDefault: 240
    property var cfg_expanding
    property var cfg_length

    ComboBox {
        id: displayMode

        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Panel appearance:")
        model: [
            i18n("Automatic"),
            i18n("Icon"),
            i18n("Percentage"),
            i18n("Wide slider"),
            i18n("Full controls")
        ]
    }

    SpinBox {
        id: sliderWidth

        Kirigami.FormData.label: i18n("Wide control width:")
        from: 160
        to: 480
        stepSize: 10
        editable: true
        enabled: displayMode.currentIndex === 0
            || displayMode.currentIndex === 3
            || displayMode.currentIndex === 4
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("Automatic uses an icon in constrained layouts and expands when enough width is available, including in wide vertical panels.")
        wrapMode: Text.Wrap
    }

    Label {
        Layout.fillWidth: true
        text: i18n("The wide slider contains only a 50–100% slider. Open the widget settings from its context menu to change this appearance later.")
        wrapMode: Text.Wrap
    }
}
