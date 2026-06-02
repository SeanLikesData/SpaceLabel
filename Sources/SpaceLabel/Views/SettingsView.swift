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
            }
            .padding(12)

            Spacer(minLength: 0)
        }
    }
}
