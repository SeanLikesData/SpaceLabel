import SwiftUI

struct OverviewView: View {
    @State private var rows: [OverviewRow]
    @State private var editingID: String?
    let onClose: () -> Void
    let onSave: (OverviewRow) -> Void
    let onJump: (String) -> Void

    init(rows: [OverviewRow],
         onClose: @escaping () -> Void,
         onSave: @escaping (OverviewRow) -> Void,
         onJump: @escaping (String) -> Void) {
        _rows = State(initialValue: rows)
        self.onClose = onClose
        self.onSave = onSave
        self.onJump = onJump
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Desktops")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(rows.count)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.1))

            ScrollView {
                VStack(spacing: 6) {
                    ForEach($rows) { $row in
                        OverviewRowView(
                            row: $row,
                            isEditing: editingID == row.id,
                            onToggleEdit: { toggleEdit(row.id) },
                            onSave: onSave,
                            onJump: {
                                let id = row.id
                                onClose()
                                onJump(id)
                            }
                        )
                    }
                }
                .padding(12)
            }
        }
        .frame(width: 440, height: 520)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .onExitCommand {
            // Escape closes the open editor first, then dismisses the panel.
            if editingID != nil {
                editingID = nil
            } else {
                onClose()
            }
        }
    }

    private func toggleEdit(_ id: String) {
        editingID = (editingID == id) ? nil : id
    }
}

private struct OverviewRowView: View {
    @Binding var row: OverviewRow
    let isEditing: Bool
    let onToggleEdit: () -> Void
    let onSave: (OverviewRow) -> Void
    let onJump: () -> Void

    private var color: Color? {
        row.colorName.flatMap { name in
            SpaceProfile.availableColors.first(where: { $0.name == name })?.color
        }
    }

    private var displayName: String {
        row.name.isEmpty ? "Desktop \(row.index)" : row.name
    }

    private var preview: String {
        row.notes
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .prefix(2)
            .joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("\(row.index)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if !isEditing && !preview.isEmpty {
                        Text(preview)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.55))
                            .lineLimit(2)
                    }
                }

                Spacer()

                if let color {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                }

                Button(action: onToggleEdit) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help(isEditing ? "Done" : "Edit this desktop")
            }
            // Tap the row (when not editing) to jump to that desktop.
            .contentShape(Rectangle())
            .onTapGesture {
                if !isEditing { onJump() }
            }

            if isEditing {
                editor
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(row.isCurrent ? 0.10 : 0))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(row.isCurrent ? (color ?? .white) : .clear, lineWidth: 1.5)
        )
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Name this desktop...", text: $row.name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: row.name) { onSave(row) }

            HStack(spacing: 6) {
                ForEach(SpaceProfile.availableColors, id: \.name) { item in
                    Button {
                        row.colorName = item.name
                        onSave(row)
                    } label: {
                        Circle()
                            .fill(item.color)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .stroke(row.colorName == item.name ? Color.white : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            TextEditor(text: $row.notes)
                .font(.system(size: 12))
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.2))
                )
                .onChange(of: row.notes) { onSave(row) }
        }
        .padding(.leading, 46)
    }
}
