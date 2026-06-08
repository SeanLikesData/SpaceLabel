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

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Popover size")
                        .font(.callout)
                    Picker("Popover size", selection: $settings.popoverSize) {
                        ForEach(PopoverSize.allCases) { size in
                            Text(size.label).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Text(settings.popoverSize.dimensionsLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Menu bar indicator")
                        .font(.callout)
                    Picker("Menu bar indicator", selection: $settings.menuBarIndicator) {
                        ForEach(MenuBarIndicator.allCases) { indicator in
                            Text(indicator.label).tag(indicator)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Text("Show the desktop's color as a dot before the name, as an underline beneath it, or not at all.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)

            Spacer(minLength: 0)
        }
    }
}
