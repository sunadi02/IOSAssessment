import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("ARCADE")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("Choose a game")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationLink(destination: TapFrenzyView()) {
                        GameCard(title: "TAP FRENZY", subtitle: "Tap as fast as you can", icon: "hand.tap.fill")
                    }
                    
                    NavigationLink(destination: LightItUpView()) {
                        GameCard(title: "LIGHT IT UP", subtitle: "Tap the lit card before it goes dark", icon: "lightbulb.fill")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct GameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.white)
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(16)
    }
}
