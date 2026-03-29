import SwiftUI

struct HUDView: View {
    let name: String
    let index: Int
    let notes: String
    let colorTag: String?

    private var tintColor: Color? {
        guard let colorTag else { return nil }
        return SpaceProfile.availableColors.first(where: { $0.name == colorTag })?.color
    }

    private var notesPreview: String? {
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let lines = trimmed.components(separatedBy: .newlines).prefix(2)
        return lines.joined(separator: "\n")
    }

    var body: some View {
        HStack(spacing: 14) {
            Text("\(index)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("Desktop \(index)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))

                if let notesPreview {
                    Text(notesPreview)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(width: 320)
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                if let tintColor {
                    tintColor.opacity(0.15)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
