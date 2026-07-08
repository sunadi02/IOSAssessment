import SwiftUI

struct QuizRushView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = QuizRushViewModel()
    @State private var shake = false
    @State private var flashCorrect = false
    
    var body: some View {
        ZStack {
            background

            VStack(spacing: 16) {
                topBar

                ZStack {
                    switch vm.state {
                    case .loading:
                        loadingView
                    case .failed:
                        errorView
                    case .loaded:
                        gameView
                    case .finished:
                        resultsView
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.08, green: 0.10, blue: 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(28)
            }
        }
        .task { await vm.load() }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    var background: some View {
        LinearGradient(
            colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.10), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Arcade Atlas")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
                Text("Quiz Rush")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.40, green: 0.48, blue: 0.60))
            }

            Spacer()
        }
    }
    
    // MARK: - Loading
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.4)
            Text("fetching questions...")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.45))
        }
    }
    
    // MARK: - Error
    var errorView: some View {
        VStack(spacing: 20) {
            Text("😕")
                .font(.system(size: 48))
            Text(vm.errorMessage)
                .font(.system(size: 15))
                .foregroundColor(Color(white: 0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("try again") {
                Task { await vm.load() }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(width: 130, height: 44)
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    // MARK: - Game
    var gameView: some View {
        guard let q = vm.current else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(spacing: 0) {
                
                // top bar
                HStack {
                    Text(vm.progress)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                    
                    Spacer()
                    
                    if vm.streak >= 2 {
                        Text("🔥 \(vm.streak) streak")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Text("\(vm.timeLeft)s")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.timeLeft <= 5 ? .red : Color(white: 0.45))
                        .animation(nil, value: vm.timeLeft)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // timer bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .frame(height: 3)
                        Rectangle()
                            .fill(vm.timeLeft <= 5 ? Color.red : Color.white)
                            .frame(width: geo.size.width * CGFloat(vm.timeLeft) / 20.0, height: 3)
                            .animation(.linear(duration: 1), value: vm.timeLeft)
                    }
                }
                .frame(height: 3)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // category + difficulty
                        HStack(spacing: 8) {
                            Text(q.category)
                                .font(.system(size: 11))
                                .foregroundColor(Color(white: 0.4))
                                .lineLimit(1)
                            Spacer()
                            Text(q.difficulty)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.difficultyColor(q.difficulty))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        // question
                        Text(q.decodedQuestion)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .offset(x: shake ? -8 : 0)
                            .animation(
                                shake ? .default.repeatCount(4, autoreverses: true).speed(6) : .default,
                                value: shake
                            )
                        
                        // score
                        HStack {
                            Text("score  \(vm.score)")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(white: 0.4))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        // answers
                        VStack(spacing: 10) {
                            ForEach(q.allAnswers.indices, id: \.self) { idx in
                                let answer = q.allAnswers[idx]
                                answerButton(answer, correct: q.decodedCorrect)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .animation(nil, value: q.allAnswers)
                        .animation(nil, value: vm.selectedAnswer)
                    }
                }
            }
            .background(
                flashCorrect ? Color.green.opacity(0.08) : Color.clear
            )
        )
    }
    
    func answerButton(_ answer: String, correct: String) -> some View {
        let decoded = answer.htmlDecoded
        let selected = vm.selectedAnswer != nil
        let isCorrect = decoded == correct
        let wasChosen = vm.selectedAnswer == decoded || vm.selectedAnswer == answer
        
        var bg: Color {
            if !selected { return Color(white: 0.13) }
            if isCorrect { return Color.green.opacity(0.25) }
            if wasChosen { return Color.red.opacity(0.25) }
            return Color(white: 0.09)
        }
        
        var border: Color {
            if !selected { return Color.clear }
            if isCorrect { return .green }
            if wasChosen { return .red }
            return Color.clear
        }
        
        return Button {
            guard vm.selectedAnswer == nil else { return }
            if decoded != correct {
                shake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shake = false }
            } else {
                flashCorrect = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { flashCorrect = false }
            }
            vm.answer(decoded)
            // Advance to next question after short delay
        
        } label: {
            Text(decoded)
                .font(.system(size: 15))
                .foregroundColor(selected && !isCorrect && !wasChosen ? Color(white: 0.35) : .white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(bg)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(border, lineWidth: 1.5)
                )
        }
        .disabled(selected)
        .buttonStyle(.plain)
        .animation(nil, value: vm.selectedAnswer)
    }
    
    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("round over")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(white: 0.5))
            
            Text("\(vm.score)")
                .font(.system(size: 96, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top, 4)
            
            Text("points")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.4))
            
            if vm.score > 0 && vm.score >= vm.highScore {
                Text("🏆 new best!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
            }
            
            HStack(spacing: 30) {
                VStack(spacing: 3) {
                    Text("\(vm.bestStreak)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                    Text("best streak")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.4))
                }
                VStack(spacing: 3) {
                    Text("\(vm.highScore)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(Color(white: 0.6))
                    Text("all-time best")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.4))
                }
            }
            .padding(.top, 20)
            
            Spacer()
            ShareLink(item: "I just scored \(vm.score) on Quiz Rush 🎮 — beat that!") {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("share score")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 180, height: 44)
                .background(Color(white: 0.18))
                .cornerRadius(10)
            }
            .padding(.bottom, 12)
            Button("play again") {
                Task { await vm.load() }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(width: 140, height: 46)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.bottom, 50)
        }
    }
}
