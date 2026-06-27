import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("ARCADE")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                        Text("pick a game")
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.45))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: TapFrenzyView()) {
                            ModeButton(title: "TAP FRENZY", desc: "tap the button as fast as you can", icon: "hand.tap.fill")
                        }
                        NavigationLink(destination: LightItUpView()) {
                            ModeButton(title: "LIGHT IT UP", desc: "hit the glowing card before it fades", icon: "lightbulb.fill")
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ModeButton: View {
    let title: String
    let desc: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(white: 0.4))
        }
        .padding(16)
        .background(Color(white: 0.11))
        .cornerRadius(14)
    }
}
