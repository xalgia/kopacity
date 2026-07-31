import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_displayMode: displayMode.currentIndex
    property alias cfg_sliderWidth: controlWidth.value
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
            i18n("Full controls")
        ]
    }

    SpinBox {
        id: controlWidth

        Kirigami.FormData.label: i18n("Full-control width:")
        from: 160
        to: 480
        stepSize: 10
        editable: true
        enabled: displayMode.currentIndex === 0
            || displayMode.currentIndex === 3
    }

    Label {
        Layout.fillWidth: true
        Kirigami.FormData.isSection: true
        text: i18n("Automatic shows Full controls at 250 px or wider, Percentage at medium widths, and Icon in constrained layouts.")
        wrapMode: Text.Wrap
    }

    Label {
        Layout.fillWidth: true
        text: i18n("Full controls fall back to Percentage when the available width is too small.")
        wrapMode: Text.Wrap
    }
}
