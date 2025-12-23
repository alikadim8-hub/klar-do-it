import Foundation
import SwiftUI
import Combine

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let key = "klar.tasks.v1"

    init() {
        load()
    }

    // MARK: - Add
    func add(
        title: String,
        note: String,
        reminderDate: Date?,
        repeatType: RepeatType,
        leadTime: LeadTime
    ) {
        let task = TaskItem(
            title: title,
            note: note,
            reminderDate: reminderDate,
            repeatType: repeatType,
            leadTime: leadTime
        )

        tasks.insert(task, at: 0)
        save()

        if let dueDate = reminderDate {
            Task {
                await NotificationManager.shared.schedule(
                    id: task.id.uuidString,
                    title: task.title,
                    body: task.note,
                    date: dueDate,
                    repeatType: repeatType,
                    leadTime: leadTime
                )

            }
        }
    }

    // MARK: - Toggle
    func toggle(id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].isCompleted.toggle()
        save()
    }

    // MARK: - Remove
    func remove(at offsets: IndexSet) {
        for i in offsets {
            let id = tasks[i].id.uuidString
            NotificationManager.shared.cancel(id: id)
        }
        tasks.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch { }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            tasks = []
        }
    }
}
