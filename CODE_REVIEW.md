# Code Review — MovieViewModel (iOS)

- 'movies' not '@Published' -> Add '@Published'
  Problem: The class conforms to ObservableObject, but movies is a plain var. SwiftUI views observing this object will not re-render when movies changes, because no objectWillChange notification is emitted.
- Synchronous blocking network call -> Use 'URLSession' + 'async/await'
  Problem: Data(contentsOf: URL) is a synchronous, blocking call. If loadMovies() is invoked from the main thread (which it will be, from a SwiftUI .task or button action), it freezes the UI while the network request is in flight — and Data(contentsOf:) isn't even designed for network requests; it's meant for local file URLs. There's no timeout, retry, or cancellation handling either.
- 'try!' crashes on any error -> Replace with 'do/catch', surface errors
  Problem: Both the network fetch and the JSON decode use try!. Any failure (no internet connection, server downtime, HTTP error status, malformed JSON, schema mismatch) crashes the app instantly. This is unacceptable in production code, a flaky backend or a single bad server response takes down every user's app.
- No '@MainActor' / thread safety -> Mark UI-updating code '@MainActor'
  Problem: Even once this is made async, updates to @Published properties must happen on the main thread. Without @MainActor, updating movies from a background continuation could cause UI glitches or crashes in debug builds.
- No loading/error UI state -> Add 'isLoading', 'errorMessage'
  Problem: The UI has no way to show a spinner, an error message, or an empty state, it only ever sees the final movies array.
