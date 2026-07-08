import SwiftUI

struct SettingsTab: View {
    @ObservedObject private var store = SessionStore.shared
    @AppStorage("notificationsOn") private var notificationsOn = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("playerName") private var playerName = ""
    @State private var showResetConfirm = false
    
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
                colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
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
            Text("Arcade Atlas Settings")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
            Text("Set your name, reminder time, and local data preferences.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.34, green: 0.42, blue: 0.56))
        }
        .padding(.top, 22)
    }

    private var profileCard: some View {
        settingsCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Profile")

                TextField("Enter your name", text: $playerName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.28))
                    .padding(14)
                    .background(Color(red: 0.98, green: 0.99, blue: 1.0))
                    .cornerRadius(16)

                Text("This name is stored with every finished game and used on the leaderboard.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
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
                            .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                        Text("Get a reminder to come back and play.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
                    }
                    Spacer()
                    Toggle("", isOn: $notificationsOn)
                        .tint(Color(red: 0.12, green: 0.48, blue: 0.88))
                        .onChange(of: notificationsOn, initial: false) { _, newValue in
                            if newValue {
                                NotificationService.shared.requestPermission()
                                NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
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
                                NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .padding(14)
                    .background(Color(red: 0.98, green: 0.99, blue: 1.0))
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
                                .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
                        }
                        Spacer()
                        Text("\(store.sessions.count) sessions")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
                    }
                    .padding(14)
                    .background(Color(red: 0.98, green: 0.99, blue: 1.0))
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
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
            )
            .cornerRadius(22)
            .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(Color(red: 0.36, green: 0.44, blue: 0.58))
    }
}

