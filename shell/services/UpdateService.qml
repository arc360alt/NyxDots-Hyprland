pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tracks the installed NyxDots version against this repo's GitHub releases
// (tags only, no release assets — a release just marks a commit). Checking
// hits the GitHub API; applying does a forced git checkout of that tag,
// regenerates the derived config, and restarts the running shell.
Singleton {
    id: root

    readonly property string repoSlug: "arc360alt/NyxDots-Hyprland"
    readonly property string versionFile: Config.repoRoot + "/state/version.txt"
    readonly property string updateScript: Config.repoRoot + "/scripts/update.sh"

    property string installedVersion: "unknown"
    property string latestVersion: ""
    property bool checking: false
    property bool updating: false
    property bool checkedOnce: false
    property string errorMessage: ""

    readonly property bool updateAvailable: checkedOnce && latestVersion.length > 0
        && compareVersions(latestVersion, installedVersion) > 0

    // Compares dotted version strings ("v1.2.0" style, leading "v" ignored).
    // Positive if a > b, negative if a < b, 0 if equal. Falls back to plain
    // string inequality for anything that doesn't parse as dotted numbers,
    // so non-semver tags still register as "different" rather than crashing.
    function compareVersions(a, b) {
        const parts = v => v.replace(/^v/i, "").split(".").map(n => parseInt(n, 10));
        const pa = parts(a);
        const pb = parts(b);
        const len = Math.max(pa.length, pb.length);
        for (let i = 0; i < len; i++) {
            const na = pa[i] || 0;
            const nb = pb[i] || 0;
            if (isNaN(na) || isNaN(nb)) return a === b ? 0 : (a > b ? 1 : -1);
            if (na !== nb) return na - nb;
        }
        return 0;
    }

    function checkForUpdates() {
        root.checking = true;
        root.errorMessage = "";
        checkProc.running = true;
    }

    // Kills and relaunches the shell as its last step, so this has to
    // outlive the calling process — see scripts/update.sh.
    function applyUpdate() {
        if (!root.updateAvailable || root.updating) return;
        root.updating = true;
        Quickshell.execDetached(["bash", root.updateScript, root.latestVersion]);
    }

    FileView {
        id: versionFileView
        path: root.versionFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.installedVersion = text().trim()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) root.installedVersion = "unknown";
        }
    }

    Process {
        id: checkProc
        command: ["curl", "-s", "-m", "10", "https://api.github.com/repos/" + root.repoSlug + "/releases/latest"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.checking = false;
                root.checkedOnce = true;
                try {
                    const data = JSON.parse(text);
                    if (data.tag_name) {
                        root.latestVersion = data.tag_name;
                    } else {
                        root.errorMessage = "no releases published yet";
                    }
                } catch (e) {
                    root.errorMessage = "couldn't reach GitHub";
                }
            }
        }
    }
}
