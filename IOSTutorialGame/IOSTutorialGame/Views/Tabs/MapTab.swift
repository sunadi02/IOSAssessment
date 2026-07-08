import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject private var store = SessionStore.shared
    @ObservedObject private var location = LocationService.shared
    @State private var selected: LocationCluster? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        currentLocationCard
                        mapCard
                        selectedCard
                        Spacer(minLength: 18)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                location.refresh()
                centerOnCurrentLocation()
            }
            .onChange(of: location.lastLocation) { _, _ in
                centerOnCurrentLocation()
            }
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
                colors: [Color(red: 0.10, green: 0.45, blue: 0.96).opacity(0.15), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Arcade Atlas Map")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
            Text("Your current location and recent game pins live in one view.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.34, green: 0.42, blue: 0.56))
        }
        .padding(.top, 22)
    }

    private var currentLocationCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Current location")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.35, green: 0.42, blue: 0.55))
                Text(location.locationDescription)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
            }

            Spacer()
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private var mapCard: some View {
        Map(position: $cameraPosition) {
            ForEach(locationClusters) { cluster in
                Annotation(cluster.title, coordinate: cluster.coordinate) {
                    Button {
                        selected = cluster
                    } label: {
                        ZStack {
                            Circle()
                                .fill(cluster.pinColor)
                                .frame(width: 34, height: 34)
                                .shadow(color: cluster.pinColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            Text("\(cluster.sessions.count)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if let current = location.lastLocation {
                Annotation("You are here", coordinate: current.coordinate) {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 18, height: 18)
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                                .frame(width: 44, height: 44)
                        }
                        Text("You")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                    }
                }
            }
        }
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.blue.opacity(0.14), radius: 16, x: 0, y: 10)
    }

    private var selectedCard: some View {
        Group {
            if let s = selected {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                        Text(s.summary)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.43, green: 0.50, blue: 0.62))
                        Text("\(s.sessions.count) sessions")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.53, green: 0.58, blue: 0.68))

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(s.gamesSummary, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 0.22, green: 0.28, blue: 0.40))
                            }
                        }
                        .padding(.top, 4)
                    }

                    Spacer()

                    Button {
                        selected = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.43, green: 0.50, blue: 0.62))
                            .frame(width: 28, height: 28)
                            .background(Color(red: 0.97, green: 0.98, blue: 1.0))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
                )
                .cornerRadius(22)
                .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var locationClusters: [LocationCluster] {
        Dictionary(grouping: store.sessions.filter { $0.latitude != 0 }, by: { $0.locationKey })
            .map { key, sessions in
                LocationCluster(key: key, sessions: sessions)
            }
            .sorted { $0.sessions.count > $1.sessions.count }
    }

    private func centerOnCurrentLocation() {
        guard let current = location.lastLocation else { return }
        cameraPosition = .region(MKCoordinateRegion(
            center: current.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }
    
    func pinColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color(red: 0.10, green: 0.45, blue: 0.96)
        case .lightItUp: return Color(red: 0.62, green: 0.28, blue: 0.92)
        case .quizRush: return Color(red: 0.16, green: 0.72, blue: 0.56)
        }
    }
}

private struct LocationCluster: Identifiable {
    let key: String
    let sessions: [GameSession]

    var id: String { key }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: sessions[0].latitude, longitude: sessions[0].longitude)
    }

    var title: String {
        sessions.count == 1 ? sessions[0].mode.rawValue : "\(sessions.count) games"
    }

    var summary: String {
        Array(Set(sessions.map { $0.mode.rawValue })).sorted().joined(separator: " · ")
    }

    var gamesSummary: [String] {
        sessions
            .sorted { $0.timestamp > $1.timestamp }
            .map { "\($0.mode.rawValue) · \($0.playerName) · \($0.score) pts" }
    }

    var pinColor: Color {
        if sessions.contains(where: { $0.mode == .quizRush }) { return Color(red: 0.16, green: 0.72, blue: 0.56) }
        if sessions.contains(where: { $0.mode == .lightItUp }) { return Color(red: 0.62, green: 0.28, blue: 0.92) }
        return Color(red: 0.10, green: 0.45, blue: 0.96)
    }
}
