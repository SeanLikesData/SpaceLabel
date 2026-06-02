import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showingSettings = false
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Text("Settings")
                    .font(.headline)

                Spacer()

                // Invisible spacer to balance the Back button so the title stays centered.
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .hidden()
            }
            .padding(10)

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                Toggle("Frame desktop with space color", isOn: $settings.borderEnabled)

                if settings.borderEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Border thickness")
                                .font(.callout)
                            Spacer()
                            Text("\(Int(settings.borderThickness)) pt")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.borderThickness, in: 1...20, step: 1)
                    }
                    Text("A colored frame appears around every screen in the current desktop's color.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)

            Spacer(minLength: 0)
        }
    }
}
