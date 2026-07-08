# IOSTutorialGame — Arcade App

## Architecture
MVVM pattern. Views are kept simple — logic lives in ViewModels and Services.
- **Models/** — GameSession, TriviaQuestion, Card, GameMode
- **ViewModels/** — QuizRushViewModel handles all quiz state and API calls
- **Services/** — SessionStore (persistence), LocationService, NotificationService, TriviaService
- **Views/** — split into Tabs (shell) and Games (individual modes)

## Features
- Tap Frenzy — 10 second tap game with combo multiplier and trap colour bonus
- Light It Up — grid reaction game with 4 difficulty levels, streaks, bonus cards
- Quiz Rush — 10 live trivia questions from OpenTDB with streak bonuses and per-question timer
- Stats tab — personal bests, score history chart, recent games
- Map tab — pins showing where each game was played using CoreLocation
- Settings — daily notification reminder with custom time, stats reset
- ShareLink on every result screen

## Known Limitations
- Map pins require location permission — if denied, coordinates save as 0,0
- OpenTDB API has rate limits — retry button handles failures
- High scores use @AppStorage separately from SessionStore history

## Reflection
Building this taught me SwiftUI state management (@State, @AppStorage, @ObservedObject),
async/await networking, CoreLocation, UserNotifications, and the Swift Charts framework.
The biggest challenge was keeping the ViewModel separate from the view while still
letting the view react to changes — ObservableObject and @Published solved that.
