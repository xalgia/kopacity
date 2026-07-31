const enabled = toBool(readConfig("Enabled", false));
const includeNormalWindows = toBool(readConfig("IncludeNormalWindows", true));
const includeDialogs = toBool(readConfig("IncludeDialogs", true));
const includePanels = toBool(readConfig("IncludePanels", false));
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

function isUnsafeTransient(window) {
    return window.splash
        || window.notification
        || window.criticalNotification
        || window.onScreenDisplay
        || window.tooltip
        || window.popupMenu
        || window.dropdownMenu
        || window.comboBox
        || window.appletPopup
        || window.popupWindow
        || window.inputMethod;
}

function categoryForWindow(window) {
    if (!window
            || window.deleted
            || window.desktopWindow
            || window.internal
            || ignoredResourceClasses[resourceClass(window)]
            || isUnsafeTransient(window)) {
        return "";
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

if (enabled && (includeNormalWindows || includeDialogs || includePanels)) {
    workspace.windowAdded.connect(applyToWindow);
}
