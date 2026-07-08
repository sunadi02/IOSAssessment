import SwiftUI

struct SettingsTab: View {
    @ObservedObject var store = SessionStore.shared
    @AppStorage("notificationsOn") private var notificationsOn = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
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
                Color(white: 0.07).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // notifications section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("notifications")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.4))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("daily reminder")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $notificationsOn)
                                    .tint(.white)
                                    .onChange(of: notificationsOn, initial: false) { oldValue, newValue in
                                        if newValue {
                                            NotificationService.shared.requestPermission()
                                            NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                        } else {
                                            NotificationService.shared.cancelAll()
                                        }
                                    }
                            }
                            .padding(16)
                            
                            if notificationsOn {
                                Divider()
                                    .background(Color(white: 0.2))
                                
                                DatePicker(
                                    "reminder time",
                                    selection: Binding(
                                        get: { reminderTime },
                                        set: { date in
                                            let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                                            reminderHour = c.hour ?? 9
                                            reminderMinute = c.minute ?? 0
                                            NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                        }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .colorScheme(.dark)
                                .padding(16)
                            }
                        }
                        .background(Color(white: 0.11))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                    
                    // data section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("data")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.4))
                            .padding(.horizontal, 20)
                        
                        Button {
                            showResetConfirm = true
                        } label: {
                            HStack {
                                Text("reset all stats")
                                    .font(.system(size: 15))
                                    .foregroundColor(.red)
                                Spacer()
                                Text("\(store.sessions.count) sessions")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(white: 0.35))
                            }
                            .padding(16)
                            .background(Color(white: 0.11))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                        .confirmationDialog("reset all stats?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                            Button("reset", role: .destructive) {
                                store.resetAll()
                            }
                            Button("cancel", role: .cancel) {}
                        } message: {
                            Text("this will delete all your game history. high scores saved in app storage won't be affected.")
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

