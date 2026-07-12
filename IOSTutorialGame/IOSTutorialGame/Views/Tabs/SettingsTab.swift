import SwiftUI
import PhotosUI
import UIKit

struct SettingsTab: View {
    @ObservedObject private var store = SessionStore.shared
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("notificationsOn") private var notificationsOn = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("playerName") private var playerName = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("profileImageBase64") private var profileImageBase64: String = ""
    @State private var showResetConfirm = false
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var reminderTime: Date {
        get {
            var c = DateComponents()
            c.hour = reminderHour
            c.minute = reminderMinute
            return Calendar.current.date(from: c) ?? Date()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        profileCard
                        appearanceCard
                        notificationsCard
                        dataCard

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [Color(red: 0.04, green: 0.05, blue: 0.08), Color(red: 0.08, green: 0.09, blue: 0.14), Color(red: 0.06, green: 0.07, blue: 0.10)] : [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(red: 0.62, green: 0.78, blue: 1.0).opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Playzo Settings")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(primaryTextColor)
            Text("Set your name, reminder time, and local data preferences.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(secondaryTextColor)
        }
        .padding(.top, 22)
    }

    private var profileCard: some View {
        settingsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Profile")

                HStack(alignment: .center, spacing: 14) {
                    ZStack {
                        if let data = Data(base64Encoded: profileImageBase64), !profileImageBase64.isEmpty, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(cardStroke, lineWidth: 1))
                        } else {
                            Circle()
                                .fill(Color(uiColor: .tertiarySystemBackground))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(secondaryTextColor)
                                )
                                .overlay(Circle().stroke(cardStroke, lineWidth: 1))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Enter your name", text: $playerName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(primaryTextColor)
                            .padding(14)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .cornerRadius(16)

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text("Choose profile photo")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(Color(red: 0.12, green: 0.48, blue: 0.88))
                            .cornerRadius(12)
                        }
                        .onChange(of: selectedItem) { oldValue, newValue in
                            guard let item = newValue else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    profileImageBase64 = data.base64EncodedString()
                                }
                            }
                        }
                    }
                }

            }
        }
    }

    private var appearanceCard: some View {
        settingsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Appearance")
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Dark Mode")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryTextColor)
                        Text("Switch between light and dark themes.")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryTextColor)
                    }
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                        .tint(Color(red: 0.12, green: 0.48, blue: 0.88))
                }
            }
        }
    }

    private var notificationsCard: some View {
        settingsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Notifications")

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Daily reminder")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(primaryTextColor)
                        Text("Get a reminder to come back and play.")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryTextColor)
                    }
                    Spacer()
                    Toggle("", isOn: $notificationsOn)
                        .tint(Color(red: 0.12, green: 0.48, blue: 0.88))
                        .onChange(of: notificationsOn, initial: false) { _, newValue in
                            if newValue {
                                NotificationService.shared.requestPermission { granted in
                                    if granted {
                                        NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                    } else {
                                        notificationsOn = false
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelAll()
                            }
                        }
                }

                if notificationsOn {
                    DatePicker(
                        "Reminder time",
                        selection: Binding(
                            get: { reminderTime },
                            set: { date in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                reminderHour = components.hour ?? 9
                                reminderMinute = components.minute ?? 0
                                if notificationsOn {
                                    NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .cornerRadius(16)
                }
            }
        }
    }

    private var dataCard: some View {
        settingsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Data")

                Button {
                    showResetConfirm = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Reset all stats")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.78, green: 0.16, blue: 0.18))
                            Text("This clears session history on this device.")
                                .font(.system(size: 13))
                                .foregroundColor(secondaryTextColor)
                        }
                        Spacer()
                        Text("\(store.sessions.count) sessions")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .confirmationDialog("Reset all stats?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                    Button("Reset", role: .destructive) {
                        store.resetAll()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will delete all your game history. High scores saved in app storage won't be affected.")
                }
            }
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(Color(uiColor: .secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .cornerRadius(22)
            .shadow(color: Color.blue.opacity(colorScheme == .dark ? 0.20 : 0.10), radius: 14, x: 0, y: 8)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(secondaryTextColor)
    }

    private var cardStroke: Color {
        Color(uiColor: .tertiarySystemFill)
    }

    private var primaryTextColor: Color {
        Color(uiColor: .label)
    }

    private var secondaryTextColor: Color {
        Color(uiColor: .secondaryLabel)
    }
}

