const enabled = toBool(readConfig("Enabled", false));
const includeNormalWindows = toBool(readConfig("IncludeNormalWindows", true));
const includeDialogs = toBool(readConfig("IncludeDialogs", true));
const includePanels = toBool(readConfig("IncludePanels", false));
const includeNotifications = toBool(readConfig("IncludeNotifications", false));
const includeMenus = toBool(readConfig("IncludeMenus", false));
const includeTooltips = toBool(readConfig("IncludeTooltips", false));
const includeSplashScreens = toBool(readConfig("IncludeSplashScreens", false));
const configuredOpacity = clamp(toNumber(readConfig("Opacity", 75), 75), 50, 99) / 100;

const ignoredResourceClasses = {
    "kscreenlocker_greet": true,
    "ksmserver-logout-greeter": true,
    "kwin_wayland": true,
    "kwin_x11": true,
};

function toBool(value) {
    return value === true
        || value === 1
        || String(value).toLowerCase() === "true";
}

function toNumber(value, fallback) {
    const number = Number(value);
    return Number.isFinite(number) ? number : fallback;
}

function clamp(value, minimum, maximum) {
    return Math.min(maximum, Math.max(minimum, value));
}

function resourceClass(window) {
    return String(window.resourceClass || "").toLowerCase();
}

function isMenuOrPopup(window) {
    return window.popupMenu
        || window.dropdownMenu
        || window.comboBox
        || window.appletPopup
        || window.popupWindow;
}

function categoryForWindow(window) {
    if (!window
            || window.deleted
            || window.desktopWindow
            || window.internal
            || window.criticalNotification
            || window.inputMethod
            || ignoredResourceClasses[resourceClass(window)]
    ) {
        return "";
    }

    if (window.notification || window.onScreenDisplay) {
        return "notifications";
    }

    if (isMenuOrPopup(window)) {
        return "menus";
    }

    if (window.tooltip) {
        return "tooltips";
    }

    if (window.splash) {
        return "splashes";
    }

    if (window.dock) {
        return "panels";
    }

    if (window.dialog) {
        return "dialogs";
    }

    if (window.normalWindow) {
        return "normal";
    }

    return "";
}

function categoryIsIncluded(category) {
    switch (category) {
    case "normal":
        return includeNormalWindows;
    case "dialogs":
        return includeDialogs;
    case "panels":
        return includePanels;
    case "notifications":
        return includeNotifications;
    case "menus":
        return includeMenus;
    case "tooltips":
        return includeTooltips;
    case "splashes":
        return includeSplashScreens;
    default:
        return false;
    }
}

function approximatelyEqual(left, right) {
    return Math.abs(left - right) < 0.001;
}

function applyToWindow(window) {
    const category = categoryForWindow(window);
    if (!category) {
        return;
    }

    if (enabled && categoryIsIncluded(category)) {
        if (!approximatelyEqual(window.opacity, configuredOpacity)) {
            window.opacity = configuredOpacity;
        }
        return;
    }

    // Only restore windows which still look like they were managed by us.
    // This avoids resetting unrelated custom opacity values in most cases.
    if (approximatelyEqual(window.opacity, configuredOpacity)) {
        window.opacity = 1.0;
    }
}

workspace.windowList().forEach(applyToWindow);

if (enabled && (includeNormalWindows
        || includeDialogs
        || includePanels
        || includeNotifications
        || includeMenus
        || includeTooltips
        || includeSplashScreens)) {
    workspace.windowAdded.connect(applyToWindow);
}
