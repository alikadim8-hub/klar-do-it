import Foundation
import UserNotifications





final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // طلب إذن الإشعارات
    func requestIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        }
    }

    // جدولة إشعار (مع تذكير قبل الموعد)
    func schedule(
        id: String,
        title: String,
        body: String,
        date: Date,
        repeatType: RepeatType,
        leadTime: LeadTime
    ) async {

        await requestIfNeeded()

        // نحسب وقت الإشعار بعد طرح الـ leadTime
        let notifyDate = date.addingTimeInterval(-leadTime.seconds())

        // لو صار الوقت بالماضي، لا نسوي إشعار
        if notifyDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body.isEmpty ? "Påminnelse" : body
        content.sound = .default

        let trigger: UNNotificationTrigger

        switch repeatType {
        case .none:
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(1, notifyDate.timeIntervalSinceNow),
                repeats: false
            )

        case .daily:
            let comps = Calendar.current.dateComponents(
                [.hour, .minute],
                from: notifyDate
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: comps,
                repeats: true
            )

        case .weekly:
            let comps = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: notifyDate
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: comps,
                repeats: true
            )

        case .monthly:
            let comps = Calendar.current.dateComponents(
                [.day, .hour, .minute],
                from: notifyDate
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: comps,
                repeats: true
            )
        }

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // إلغاء إشعار
    func cancel(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }
}
