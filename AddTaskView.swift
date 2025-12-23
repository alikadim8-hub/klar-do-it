import SwiftUI

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: TaskStore

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var enableReminder: Bool = false
    @State private var reminderDate: Date = Date()
    @State private var repeatType: RepeatType = .none
    @State private var leadTime: LeadTime = .none

    var body: some View {
        NavigationStack {
            Form {

                Section {
                    TextField("Task title", text: $title)
                }

                Section {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(header: Text("Reminder")) {

                    Toggle("Enable reminder", isOn: $enableReminder)

                    if enableReminder {

                        DatePicker(
                            "Date & time",
                            selection: $reminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        Picker("Repeat", selection: $repeatType) {
                            Text("None").tag(RepeatType.none)
                            Text("Daily").tag(RepeatType.daily)
                            Text("Weekly").tag(RepeatType.weekly)
                        }

                        Picker("Notify", selection: $leadTime) {
                            ForEach(LeadTime.allCases, id: \.self) { t in
                                Text(t.title).tag(t)
                            }

                        }
                    }
                }
            }
            .navigationTitle("Add task")
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {

                        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanNote  = note.trimmingCharacters(in: .whitespacesAndNewlines)

                        let date = enableReminder ? reminderDate : nil
                        let rep  = enableReminder ? repeatType : .none
                        let lead = enableReminder ? leadTime : .none

                        store.add(
                            title: cleanTitle,
                            note: cleanNote,
                            reminderDate: date,
                            repeatType: rep,
                            leadTime: lead
                        )

                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
