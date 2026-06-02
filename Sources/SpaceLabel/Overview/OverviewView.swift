import SwiftUI

struct OverviewView: View {
    let rows: [OverviewRow]
    let onClose: () -> Void

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
                    ForEach(rows) { row in
                        OverviewRowView(row: row)
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
        .onExitCommand { onClose() }
    }
}

private struct OverviewRowView: View {
    let row: OverviewRow

    private var color: Color? {
        row.colorName.flatMap { name in
            SpaceProfile.availableColors.first(where: { $0.name == name })?.color
        }
    }

    var body: some View {
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
                Text(row.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                if !row.notesPreview.isEmpty {
                    Text(row.notesPreview)
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
}
