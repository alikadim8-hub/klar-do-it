import Foundation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    var reminderDate: Date?
    var repeatType: RepeatType
    var leadTime: LeadTime

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        reminderDate: Date? = nil,
        repeatType: RepeatType = .none,
        leadTime: LeadTime = .none
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.reminderDate = reminderDate
        self.repeatType = repeatType
        self.leadTime = leadTime
    }
}
