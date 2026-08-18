pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    property alias tracked: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
    }
}
