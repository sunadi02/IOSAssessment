//
//  ContentView.swift
//  IOSTutorialGame
//
//  Created by student2 on 2026-06-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("TAP FRENZY")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                
                HStack(spacing: 60) {
                    VStack(spacing: 4) {
                        Text("0")
                            .font(.system(size: 52, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("SCORE")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .tracking(2)
                    }
                    VStack(spacing: 4) {
                        Text("10")
                            .font(.system(size: 52, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("TIME")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .tracking(2)
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("START")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.black)
                    )
                
                Spacer()
                
                Text("Best: 0")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
