import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "configAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Transparency")
        icon: "edit-opacity"
        source: "configTransparency.qml"
    }
}
