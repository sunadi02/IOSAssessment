import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject var store = SessionStore.shared
    @State private var selected: GameSession? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    ForEach(store.sessions.filter { $0.latitude != 0 }) { session in
                        Annotation(session.mode.rawValue, coordinate: CLLocationCoordinate2D(
                            latitude: session.latitude,
                            longitude: session.longitude
                        )) {
                            Button {
                                selected = session
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(pinColor(session.mode))
                                        .frame(width: 28, height: 28)
                                    Text("\(session.score)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                if store.sessions.filter({ $0.latitude != 0 }).isEmpty {
                    VStack(spacing: 8) {
                        Text("no locations yet")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Text("finish a game to drop a pin")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.5))
                    }
                    .padding(20)
                    .background(Color(white: 0.1).opacity(0.9))
                    .cornerRadius(14)
                }
                
                if let s = selected {
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(s.mode.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(s.score) points  ·  \(s.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            Spacer()
                            Button {
                                selected = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        .padding(16)
                        .background(Color(white: 0.1))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func pinColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color(white: 0.6)
        case .lightItUp: return .blue
        case .quizRush: return .orange
        }
    }
}
