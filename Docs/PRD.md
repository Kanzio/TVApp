# Product Requirements Document (PRD)

## TV Show Browser — iOS Take-Home Assignment

**Document Owner:** Senior Product Manager / Senior iOS Architect
**Prepared for:** iOS Mobile Engineer (Intern) Candidate
**Platform:** iOS (Swift, SwiftUI)
**API:** [TVMaze API](https://www.tvmaze.com/api)
**Status:** Ready for implementation

---

## 1. Project Overview

### 1.1 Objective

Build a **TV Show Browser** iOS application that allows a user to browse a list of TV shows fetched from the public TVMaze API, view details for a selected show, and share that show's information with others. The assignment is intentionally scoped small, but it is evaluated as a **production-quality sample**, not a prototype. The purpose is not to test whether the candidate can call an API — it is to test:

- Ability to structure a maintainable, testable SwiftUI app using MVVM and Clean Architecture principles.
- Ability to model and handle real-world network states (loading, success, error, retry).
- Judgment about scope: doing the required things _well_ rather than doing everything _poorly_.
- Baseline engineering hygiene: unit tests, folder structure, commit history, README.

### 1.2 Target Outcome

A single-target iOS app with two primary screens (List, Detail) that:

1. Fetches a page of shows from `GET /shows?page=0`.
2. Displays poster, title, and rating (nullable) per row.
3. Navigates to a Detail screen showing large poster, title, HTML-rendered summary, and premiere date.
4. Offers a Share action from the Detail screen.
5. Gracefully handles loading, error (with retry), and empty states.
6. Ships with at least 2 meaningful unit tests (ViewModel and/or Repository layer).

### 1.3 Non-Goals (Explicitly Out of Scope for v1)

- Pagination beyond the first page (documented as a "Future Improvement").
- Search / filtering.
- Persistent offline storage (SwiftData / CoreData) — a lightweight in-memory cache is acceptable, disk persistence is not required.
- Authentication (TVMaze is a public, unauthenticated API).
- Favorites / bookmarking.
- watchOS / iPadOS-specific layouts (app should not crash on iPad, but no dedicated iPad layout work is required).

### 1.4 Success Criteria

The submission is considered successful if:

- It builds and runs without warnings on the latest stable Xcode/iOS SDK.
- All required states (loading/success/error/empty) are visibly and correctly implemented.
- Architecture is layered (Presentation / Domain / Data) and each layer is independently testable.
- Unit tests pass and demonstrate real behavior verification (not trivial assertions).
- Code is readable by a reviewer who has never seen the project, without additional explanation.

---

## 2. Functional Requirements

### 2.1 Launch

- App launches directly into the **List Screen**.
- On launch, the app immediately triggers a network request to `GET /shows?page=0`.
- No splash screen is required; the List Screen itself renders the Loading state immediately.

### 2.2 Loading

- While the initial request (or a retry) is in-flight, the List Screen shows a centered loading indicator (`ProgressView`) with no partial/stale content behind it, to avoid showing a flash of an empty list.
- Loading state must not block the UI thread; the rest of the app (e.g., navigation bar) remains responsive.
- If a request resolves in under ~200ms, the loading indicator may appear only briefly — this is acceptable and does not need artificial delay/minimum-display-time logic for v1 (documented, not required).

### 2.3 Error

- If the network call fails (no connectivity, timeout, decoding failure, non-2xx HTTP status), the List Screen replaces its content with an **Error View**, showing:
  - A short, human-readable message (not a raw `Error` description or stack trace).
  - A **Retry** button.
- Error state must be distinguishable at a glance from Empty state (different message/iconography).
- The Detail Screen has its own, independent error handling only if fetching detail requires a **separate** network call (see §2.7 for the decision on this — recommended: reuse list data, no separate call needed for v1).

### 2.4 Retry

- Tapping **Retry** re-triggers the same request that failed (idempotent), transitions the ViewState back to `.loading`, and follows the normal loading → success/error flow.
- Retry must not stack duplicate in-flight requests if tapped multiple times quickly (ViewModel should guard against concurrent duplicate calls, e.g., ignore new retry taps while a request is already in-flight).

### 2.5 Empty State

- If the API call succeeds (HTTP 200) but returns an empty array, the List Screen shows an **Empty View** with a friendly message (e.g., "No shows available right now.") — distinct from the Error View, since this is not a failure, it's a valid response with zero content.
- This is a defensive/edge-case handler; TVMaze's `/shows` endpoint is not expected to return empty in practice, but the ViewState model should support it cleanly regardless.

### 2.6 List Screen

- Displays a scrollable, vertical list of shows.
- Each row shows:
  - **Poster** — `image.medium`. If `image` is `nil` or the URL fails to load, show a neutral placeholder (system image or solid-color box with a TV/film icon), never a broken-image glyph or blank space that looks like a bug.
  - **Title** — `name`.
  - **Rating** — `rating.average`. If `nil`, display a neutral placeholder such as "N/A" or "—" rather than "0" or blank (a `nil` rating is not the same as a zero rating, and must never be silently converted to `0.0`).
- Tapping a row navigates to the Detail Screen for that show.
- List should use a `List` or `LazyVStack`-in-`ScrollView` (see §13 for tradeoffs) for lazy row rendering — do not eagerly render all rows into memory/view hierarchy at once, since the first page alone can return 250 shows.

### 2.7 Detail Screen

- Displays:
  - **Large poster** — `image.original`. Falls back to `image.medium` if `original` is unavailable, then to a placeholder if both are `nil`.
  - **Title** — `name`.
  - **Summary** — `summary`, which contains raw HTML (e.g., `<p>`, `<b>`, `<i>` tags). Must be rendered as readable formatted text, not raw HTML markup (see §14).
  - **Premiere date** — `premiered`, formatted in a locale-appropriate, human-readable form (e.g., "March 25, 2008" rather than the raw `"2008-03-25"` ISO string).
- **Data source decision:** Since the list endpoint (`/shows?page=0`) already returns the full show object (poster, name, rating, summary, premiered, and a `url` field for the TVMaze page), the Detail Screen **does not require a second network call** for v1. The selected `Show` domain object is passed directly from List → Detail. This is a deliberate architectural simplification that:
  - Reduces unnecessary network usage and latency.
  - Removes a redundant loading/error state on Detail.
  - Is explicitly documented in the README as a decision, with the "fetch full detail by ID" flow noted as a trivial future extension (the `ShowRepository` should still expose a `fetchShow(id:)` method to demonstrate the API layer supports it, even if the Detail screen doesn't call it by default — see §17 for how this is tested).
- Contains the **Share** button (see §2.8).

### 2.8 Share

- A Share button (`ShareLink` or `UIActivityViewController` wrapper) on the Detail Screen shares:
  - Show title.
  - Plain-text (HTML-stripped) summary.
  - The TVMaze web URL for the show (`show.url` from the API response, e.g., `https://www.tvmaze.com/shows/1/under-the-dome`).
- Shared content should be composed into a single well-formatted text block (title, then summary, then link), not three disconnected share items.
- Share action must be available as soon as the Detail Screen is shown — no loading state needed here since all data is already in memory (per §2.7).

### 2.9 Image Loading

- All remote images (poster thumbnails and large poster) use asynchronous, non-blocking image loading with a placeholder while loading and a fallback on failure.
- Image loading must not cause list scroll jank — images should load per-row as rows become visible, not all upfront.
- See §13 for the specific recommended approach (`AsyncImage`) and its tradeoffs.

### 2.10 HTML Rendering

- The `summary` field from the API is HTML (e.g., `"<p><b>Under the Dome</b> is the story of...</p>"`).
- The app must render this as styled/readable body text on the Detail Screen — bold/italic formatting from the HTML should be preserved where feasible, but at minimum all HTML tags must be stripped so the user never sees raw `<p>`/`<b>` markup on screen.
- See §14 for the recommended conversion strategy.

### 2.11 Navigation

- Navigation is a simple two-level stack: **List → Detail**, using `NavigationStack` (iOS 16+).
- Back navigation returns to the List Screen with its previous state intact (no re-fetch, no scroll position reset) — this is a natural consequence of the List Screen's ViewModel surviving in memory across the push/pop, and should not require extra state-restoration code.
- No deep linking or tab bar is required for v1.

---

## 3. Non-Functional Requirements

### 3.1 Performance

- Initial list render should feel responsive; use lazy loading (`List`/`LazyVStack`) so that receiving up to ~250 shows on page 0 does not cause a visible freeze.
- Network calls run off the main thread implicitly via Swift Concurrency (`async/await` on `URLSession`); UI updates are dispatched back to the main actor.
- Avoid re-decoding or re-fetching data unnecessarily on view re-appearance (e.g., navigating back from Detail should not re-trigger the list network call).

### 3.2 Maintainability

- Clear separation of concerns: Networking, Domain/Models, Repository, ViewModel, and View layers must not leak into each other (e.g., Views never talk to `URLSession` directly; ViewModels never import `UIKit`/`SwiftUI` view-building code beyond what's needed for `@Published` state).
- Protocol-oriented boundaries (`ShowRepositoryProtocol`, `NetworkServiceProtocol`) so implementations can be swapped/mocked without touching consumers.
- Naming, file organization, and folder structure should make the codebase navigable to a new engineer within minutes (see §17).

### 3.3 Scalability

- The architecture should support, without a rewrite:
  - Adding pagination (page 1, 2, 3…).
  - Adding new screens (e.g., Search, Favorites) that reuse the same `ShowRepository` and networking layer.
  - Swapping TVMaze for another data source behind the same repository protocol.
- Achieved via Repository Pattern + Dependency Injection (see §9).

### 3.4 Offline Behavior

- Full offline persistence (SwiftData/CoreData) is **not required** for v1 (documented as a Future Improvement, §22).
- Minimum expected behavior: if the device has no connectivity when the app launches, the request fails gracefully into the Error state with Retry — the app must never crash or hang indefinitely on a network failure.
- No stale-data caching between app launches is required for v1; in-memory ViewModel state surviving List↔Detail navigation within a single session is sufficient.

### 3.5 Accessibility

- All interactive elements (list rows, Retry button, Share button) must have appropriate accessibility labels (`accessibilityLabel`) so VoiceOver can announce, e.g., "Breaking Bad, rating 9.5" for a row, rather than reading raw layout fragments.
- Images marked `accessibilityHidden(true)` where the poster is purely decorative and the title/text already conveys the needed information, to avoid VoiceOver reading an unhelpful "image" label.
- Text should support Dynamic Type (avoid fixed frame heights that clip large accessibility text sizes).
- Color contrast for rating/error text should meet WCAG AA where reasonably achievable with system colors.

### 3.6 Error Handling (Non-Functional Framing)

- All errors surfaced to the user must be human-readable; raw `Error.localizedDescription` from `URLSession`/`DecodingError` should be mapped to a small, controlled set of user-facing messages (see §15).
- No silent failures: every failure path must result in a visible state change (Error view), never a frozen loading spinner or a blank screen.

---

## 4. User Stories

**US-1: View list of shows**
As a user,
I want to see a list of TV shows with their poster, title, and rating when I open the app,
So that I can quickly browse what's available.

_Acceptance Criteria:_

- Given the app is launched, when the network request succeeds, then a scrollable list of shows is displayed with poster, title, and rating for each.
- Given a show has no rating, when it is displayed in the list, then a neutral placeholder (e.g., "N/A") is shown instead of "0" or a blank space.
- Given a show has no poster image, when it is displayed, then a placeholder graphic is shown instead of a broken image or blank space.

**US-2: See loading feedback**
As a user,
I want to see a loading indicator while shows are being fetched,
So that I know the app is working and hasn't frozen.

_Acceptance Criteria:_

- Given the app is fetching data, when the List Screen is shown, then a loading indicator is visible and no partial/empty list is shown underneath it.
- Given the fetch completes successfully, when data arrives, then the loading indicator is replaced by the list content.

**US-3: Recover from a network error**
As a user,
I want to see a clear error message and a way to retry when the app fails to load shows,
So that I'm not stuck on a broken screen.

_Acceptance Criteria:_

- Given the network request fails (no connection, timeout, server error, or bad data), when the failure occurs, then an error message and a Retry button are shown.
- Given the user taps Retry, when the retry request is made, then the screen returns to the Loading state and then to Success or Error based on the new outcome.
- Given the user taps Retry multiple times rapidly, when a request is already in-flight, then no duplicate concurrent requests are triggered.

**US-4: View show details**
As a user,
I want to tap on a show to see more details about it,
So that I can learn more before deciding to watch it.

_Acceptance Criteria:_

- Given the user taps a show row, when the Detail Screen opens, then it displays the large poster, title, formatted (non-HTML) summary, and a human-readable premiere date.
- Given the show has no summary, when the Detail Screen is shown, then a neutral fallback message (e.g., "No description available.") is shown instead of blank space.
- Given the show has no `image.original`, when the Detail Screen is shown, then `image.medium` or a placeholder is used instead.

**US-5: Share a show**
As a user,
I want to share a show's title, summary, and TVMaze link,
So that I can recommend it to someone else.

_Acceptance Criteria:_

- Given the user is on the Detail Screen, when they tap Share, then the system share sheet opens with the show's title, plain-text summary, and TVMaze URL pre-populated as shareable content.
- Given the summary contains HTML, when it is shared, then the shared text is plain text with HTML tags removed (not raw markup).

**US-6: Navigate back without losing state**
As a user,
I want to return to the list after viewing a show's details,
So that I can continue browsing without the list reloading or losing my scroll position.

_Acceptance Criteria:_

- Given the user navigates from List to Detail and back, when they return to the List Screen, then the previously loaded list content is still shown without a new network call or visible reload flicker.

---

## 5. User Flow

### 5.1 Happy Path

```
Launch App
    ↓
List Screen renders → ViewState = .loading
    ↓
GET /shows?page=0
    ↓
Response 200 + non-empty array
    ↓
ViewState = .success([Show])
    ↓
List Screen displays rows (poster, title, rating)
    ↓
User taps a row
    ↓
NavigationStack pushes Detail Screen (Show passed directly, no network call)
    ↓
Detail Screen displays large poster, title, formatted summary, premiere date
    ↓
User taps Share
    ↓
System Share Sheet opens with title + plain-text summary + TVMaze URL
    ↓
User dismisses Share Sheet → remains on Detail Screen
    ↓
User taps Back
    ↓
NavigationStack pops → List Screen shown with prior state intact (no re-fetch)
```

### 5.2 Failure Flow (Initial Load)

```
Launch App
    ↓
List Screen renders → ViewState = .loading
    ↓
GET /shows?page=0
    ↓
Failure (no connectivity / timeout / non-2xx / decode error)
    ↓
ViewState = .error(message)
    ↓
Error View displayed with Retry button
    ↓
User taps Retry
    ↓
ViewState = .loading
    ↓
GET /shows?page=0 (repeated)
    ↓
   ├── Success → ViewState = .success([Show]) → List rendered
   └── Failure again → ViewState = .error(message) → Error View shown again
```

### 5.3 Edge Case Flow (Empty Success)

```
GET /shows?page=0
    ↓
Response 200 + empty array []
    ↓
ViewState = .empty
    ↓
Empty View displayed ("No shows available right now.")
```

### 5.4 Edge Case Flow (Partial Data)

```
Show received with rating.average = null OR image = null
    ↓
Row/Detail still renders successfully (ViewState remains .success)
    ↓
Missing fields are individually substituted with placeholders
    (this is NOT an error state — a nil field is valid data, not a failure)
```

---

## 6. Screen Specifications

### 6.1 List Screen

| Aspect              | Details                                                                                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**         | Entry point of the app; lets the user browse all shows from page 0 of the TVMaze catalog.                                                                                                                       |
| **Components**      | Navigation title ("TV Shows"), scrollable list of `ShowRowView` items (poster thumbnail, title, rating badge), `ProgressView` (loading), `ErrorStateView` (message + Retry button), `EmptyStateView` (message). |
| **User Actions**    | Tap a row → navigate to Detail. Tap Retry (in error state) → re-fetch. Pull-to-refresh (optional, nice-to-have, not required).                                                                                  |
| **Navigation**      | Root of `NavigationStack`. Pushes `DetailView` on row tap.                                                                                                                                                      |
| **Possible States** | `.loading`, `.success([Show])`, `.error(String)`, `.empty`                                                                                                                                                      |
| **Validation**      | None (no user input on this screen). Defensive checks only: nil-safe rendering of `rating` and `image` per row.                                                                                                 |

### 6.2 Detail Screen

| Aspect              | Details                                                                                                                                                                                                                                                                                                                                   |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**         | Shows full information about a single selected show and lets the user share it.                                                                                                                                                                                                                                                           |
| **Components**      | Large poster image (`AsyncImage`), title text, formatted summary text (HTML-stripped/attributed), premiere date label, Share button (toolbar or inline).                                                                                                                                                                                  |
| **User Actions**    | Tap Share → opens system share sheet. Tap Back (nav bar) → returns to List.                                                                                                                                                                                                                                                               |
| **Navigation**      | Pushed from List Screen via `NavigationLink`/programmatic navigation with the selected `Show` value. No further navigation from here in v1.                                                                                                                                                                                               |
| **Possible States** | Single implicit `.success` state (data is already available synchronously from the List Screen selection, per §2.7) with per-field nil-safety (missing image → placeholder; missing summary → fallback text; missing premiere date → "Unknown"). No `.loading`/`.error` state needed for v1 since no network call is made on this screen. |
| **Validation**      | None (no user input; only defensive nil-handling for optional fields).                                                                                                                                                                                                                                                                    |

### 6.3 Error State Component (Shared)

| Aspect              | Details                                                                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**         | Reusable view shown whenever a `ViewState.error` occurs, currently only on the List Screen but designed to be reusable if future screens need it. |
| **Components**      | Icon (e.g., `wifi.slash` or `exclamationmark.triangle`), message text, Retry button.                                                              |
| **User Actions**    | Tap Retry → invokes a closure/callback provided by the parent ViewModel.                                                                          |
| **Navigation**      | None; stays on the current screen.                                                                                                                |
| **Possible States** | N/A (this _is_ a state representation, not a stateful component itself).                                                                          |
| **Validation**      | N/A                                                                                                                                               |

---

## 7. Data Model

The TVMaze `/shows` and `/shows/{id}` endpoints return a rich object. The PRD distinguishes between the **full API response shape** (for `Codable` decoding, kept in the Data layer) and the **trimmed Domain model** (used by the rest of the app, per Clean Architecture — the app should not pass raw DTOs into the UI layer).

### 7.1 Full API Response Fields (Reference)

```
Show {
  id: Int
  url: String
  name: String
  type: String
  language: String?
  genres: [String]
  status: String
  runtime: Int?
  averageRuntime: Int?
  premiered: String?        // "yyyy-MM-dd"
  ended: String?
  officialSite: String?
  schedule: Schedule
  rating: Rating
  weight: Int
  network: Network?
  webChannel: Network?
  dvdCountry: Country?
  externals: Externals
  image: ImageLinks?
  summary: String?          // contains HTML
  updated: Int
  _links: Links
}

Schedule {
  time: String
  days: [String]
}

Rating {
  average: Double?          // NULLABLE — a show can be unrated
}

Network {
  id: Int
  name: String
  country: Country?
}

Country {
  name: String
  code: String
  timezone: String
}

Externals {
  tvrage: Int?
  thetvdb: Int?
  imdb: String?
}

ImageLinks {
  medium: String?           // NULLABLE — used for list thumbnails
  original: String?         // NULLABLE — used for detail large poster
}

Links {
  self: LinkRef
  previousepisode: LinkRef?
  nextepisode: LinkRef?
}

LinkRef {
  href: String
}
```

### 7.2 Which Fields Are Actually Needed

Only a subset is required for this assignment's UI. The DTO (`ShowDTO`) can decode everything above (or a safe subset) but the **Domain model (`Show`) should only expose what the app uses**, keeping the domain layer lean and decoupled from API shape:

| Field                                                                                                                                            | Used On             | Required? | Notes                                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                                                                                                                                             | List, Detail        | Yes       | Identity for `Identifiable`, used for future `fetchShow(id:)` calls                                                                       |
| `name`                                                                                                                                           | List, Detail, Share | Yes       | Title                                                                                                                                     |
| `image.medium`                                                                                                                                   | List                | Yes       | Poster thumbnail                                                                                                                          |
| `image.original`                                                                                                                                 | Detail              | Yes       | Large poster (falls back to `medium`)                                                                                                     |
| `rating.average`                                                                                                                                 | List                | Yes       | Nullable — must be handled                                                                                                                |
| `summary`                                                                                                                                        | Detail, Share       | Yes       | HTML — must be stripped/rendered                                                                                                          |
| `premiered`                                                                                                                                      | Detail              | Yes       | ISO date string — must be formatted                                                                                                       |
| `url`                                                                                                                                            | Share               | Yes       | TVMaze web link for the show                                                                                                              |
| `genres`, `status`, `schedule`, `network`, `runtime`, `externals`, `_links`, `weight`, `updated`, `type`, `language`, `dvdCountry`, `webChannel` | —                   | No        | Not required by any screen in v1; excluded from the Domain model. Can remain in the DTO if easier for decoding, simply unused downstream. |

### 7.3 Recommended Domain Model

```
struct Show: Identifiable, Equatable {
    let id: Int
    let name: String
    let posterThumbnailURL: URL?     // from image.medium
    let posterLargeURL: URL?         // from image.original, falling back to image.medium
    let ratingAverage: Double?       // preserved as nil, never defaulted to 0
    let summaryHTML: String?         // raw HTML, converted at the View/Presentation layer
    let premiereDateRaw: String?     // "yyyy-MM-dd", formatted at the View/Presentation layer
    let tvMazeURL: URL?              // from `url`
}
```

This mapping (`ShowDTO` → `Show`) happens in the **Data layer** (e.g., inside the Repository or a dedicated Mapper), so the rest of the app never touches `Codable`/API-shaped types directly.

---

## 8. API Layer

### 8.1 Endpoints Used

| Endpoint                              | Method | Purpose                                                | Used By                                                                                                                                |
| ------------------------------------- | ------ | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `https://api.tvmaze.com/shows?page=0` | GET    | Fetch first page (~250 shows) of the full show catalog | List Screen                                                                                                                            |
| `https://api.tvmaze.com/shows/{id}`   | GET    | Fetch a single show by ID                              | Exposed in `ShowRepositoryProtocol` for architectural completeness/testing, not called by the Detail Screen in v1 (see §2.7 rationale) |

### 8.2 Request

- Simple `GET` requests, no auth headers, no request body, no query params beyond `page`.
- `Accept: application/json` header is good practice but not strictly required (TVMaze returns JSON by default).
- Requests are made via a single injectable `NetworkService` (see §12), not scattered `URLSession.shared` calls.

### 8.3 Response

- `200 OK` with a JSON array (`/shows`) or a single JSON object (`/shows/{id}`).
- TVMaze does not paginate via headers/links for this endpoint in a way this assignment needs to handle — `page` is a manual query parameter, and out-of-range pages return `[]` with `200 OK` (this is why the Empty state matters, §2.5).
- `404 Not Found` is returned by `/shows/{id}` if the ID doesn't exist (relevant for the exposed-but-unused detail-fetch path).
- `429 Too Many Requests` is possible if rate limits are hit (TVMaze enforces per-IP rate limiting) — should be treated as a generic recoverable error in v1 (mapped to the same Error state + Retry), with a note in Future Improvements about honoring `Retry-After`.

### 8.4 Error Handling (API Layer Responsibilities)

The Networking layer should translate all failure modes into a small, closed set of typed errors (not leak raw `URLError`/`DecodingError` upward):

```
enum NetworkError: Error {
    case noConnection
    case timeout
    case invalidResponse       // non-2xx status code
    case decodingFailed
    case unknown(Error)
}
```

- `URLError.notConnectedToInternet` / `.networkConnectionLost` → `.noConnection`
- `URLError.timedOut` → `.timeout`
- HTTP status outside 200-299 → `.invalidResponse`
- `DecodingError` thrown by `JSONDecoder` → `.decodingFailed`
- Anything else → `.unknown(Error)`

This `NetworkError` is what the Repository layer receives and maps into a **user-facing message** at the ViewModel level (see §15) — keeping "what went wrong technically" separate from "what we tell the user."

### 8.5 HTTP Status Handling

| Status                  | Handling                                                                                      |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| 200                     | Decode body; if array is empty → Empty state; otherwise → Success                             |
| 4xx                     | Map to `.invalidResponse`; surfaced as a generic "Something went wrong" error with Retry      |
| 5xx                     | Map to `.invalidResponse`; surfaced as a generic "Something went wrong" error with Retry      |
| Timeout / no connection | Mapped to `.noConnection`/`.timeout`; surfaced as "Check your internet connection" with Retry |

### 8.6 Retry Strategy

- **User-initiated retry** (tapping the Retry button) is the required mechanism for v1 — simple, predictable, testable.
- **Automatic retry** (e.g., exponential backoff on transient failures) is explicitly **not required** for v1 but documented as a Future Improvement (§22) — if implemented, it should live in the Repository or a dedicated `RetryPolicy` helper, not in the ViewModel, to keep retry logic testable and reusable.
- Retry must reuse the exact same request construction logic (no duplicated URL-building code between initial load and retry).

---

## 9. Architecture

### 9.1 Recommendation: MVVM + Clean Architecture (light), SwiftUI-native

**Recommended stack:** SwiftUI + MVVM for the presentation layer, wrapped in a lightweight Clean Architecture split of **Presentation / Domain / Data**, with a **Repository Pattern** as the boundary between Domain and Data, and **manual/protocol-based Dependency Injection** (no third-party DI framework needed for an app this size).

**Why this combination:**

- **MVVM** is the natural fit for SwiftUI: `@Published` state on an `ObservableObject`/`@Observable` ViewModel maps directly onto SwiftUI's declarative re-rendering model, and is what the assignment explicitly requires.
- **Clean layering (Presentation / Domain / Data)** keeps the ViewModel free of networking/decoding details, and keeps the View free of business logic — this is what makes the app _testable_ (ViewModels can be tested with a mock Repository, with zero SwiftUI/UIKit dependency) and _maintainable_ (a new engineer can find "where things live" quickly).
- **Repository Pattern** gives a single seam (`ShowRepositoryProtocol`) between "the app" and "TVMaze specifically." If TVMaze's API shape changes, or a second data source is added, only the Data layer changes — Domain and Presentation are untouched.
- **Dependency Injection via protocols + initializer injection** is simple, explicit, and fully sufficient at this scale; introducing a DI container (e.g., Swinject) would be over-engineering for a 2-screen app and is explicitly called out as unnecessary complexity for v1 (documented in Future Improvements as an option, not a requirement).
- This is **not full "Uncle Bob" Clean Architecture with use-case interactors for every action** — that would be over-engineering for a take-home assignment. The PRD recommends a **pragmatic subset**: enough separation to be testable and swappable, without ceremony that doesn't pay for itself at this scope.

### 9.2 Layer Responsibilities

| Layer                                                                   | Responsibility                                                                                         | Depends On                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| **Presentation** (Views + ViewModels)                                   | Render UI, hold `ViewState`, react to user actions, call Repository via protocol                       | Domain                                                         |
| **Domain** (Models + Repository Protocol)                               | Define `Show` domain model and `ShowRepositoryProtocol` — the "contract" the rest of the app relies on | Nothing (pure Swift, no SwiftUI/Foundation networking imports) |
| **Data** (Repository Implementation + Network Service + DTOs + Mappers) | Implement `ShowRepositoryProtocol`, perform HTTP calls, decode JSON, map DTO → Domain model            | Domain (to conform to the protocol)                            |

Dependency direction: **Presentation → Domain ← Data**. Data and Presentation never depend on each other directly; they only meet through the Domain-defined protocol. This is the core Clean Architecture rule being preserved here.

### 9.3 High-Level Component Diagram (textual)

```
ShowListView ──uses──> ShowListViewModel ──calls──> ShowRepositoryProtocol
                                                            ▲
                                                            │ conforms to
                                                   ShowRepository (Data layer)
                                                            │ uses
                                                   NetworkServiceProtocol
                                                            ▲
                                                            │ conforms to
                                                     URLSessionNetworkService
```

### 9.4 Folder Structure (Preview — full version in §17)

```
TVShowBrowser/
    App/
    Domain/
    Data/
    Presentation/
    Core/ (shared utilities, e.g., HTML parsing, DateFormatter helpers)
    Resources/
TVShowBrowserTests/
```

---

## 10. State Management

### 10.1 ViewState Definition

A single generic (or per-screen) enum represents everything the View needs to know to render itself, avoiding scattered booleans (`isLoading`, `hasError`, `errorMessage`, `shows: [Show]`) that can drift out of sync with each other:

```swift
enum ViewState<T> {
    case loading
    case success(T)
    case error(String)
    case empty
}
```

Applied to the List Screen:

```swift
@Published private(set) var state: ViewState<[Show]> = .loading
```

### 10.2 Why an Enum Over Multiple Booleans

- **Illegal states are unrepresentable**: with booleans, you could accidentally have `isLoading = true` _and_ `errorMessage != nil` at the same time, which is a bug waiting to happen. An enum with associated values makes that combination impossible by construction.
- SwiftUI's `switch` over the enum in the View body makes exhaustiveness compiler-enforced — if a new case is added later (e.g., `.refreshing`), the compiler flags every view that needs updating.

### 10.3 States Used in This App

| State                             | Meaning                                                  | List Screen                                       | Detail Screen                                                 |
| --------------------------------- | -------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------- |
| `.loading`                        | Request in-flight                                        | Shows `ProgressView`                              | Not used (no async load, per §2.7)                            |
| `.success(T)`                     | Data available and non-empty                             | Shows the list                                    | Always effectively "success" since data is passed in directly |
| `.error(String)`                  | Request failed                                           | Shows Error View + Retry                          | Not used                                                      |
| `.empty`                          | Request succeeded, zero items                            | Shows Empty View                                  | Not applicable (a single `Show` is never "empty")             |
| `.refreshing` _(optional/future)_ | Pull-to-refresh in progress while old data stays visible | Not required for v1; noted in Future Improvements | N/A                                                           |

### 10.4 State Ownership

- `ShowListViewModel` owns and publishes `ViewState<[Show]>`.
- `ShowDetailViewModel` (thin) owns the already-resolved `Show` and derived, presentation-ready values (formatted date, plain-text summary) — it does not need a `ViewState` since there's no async operation, but wrapping the `Show` in a ViewModel (rather than passing the struct straight to the View) still keeps formatting logic testable and out of the View.

---

## 11. Navigation Strategy

- Use **`NavigationStack`** (iOS 16+), the modern SwiftUI navigation API, in place of the deprecated `NavigationView`.
- Root view (`ShowListView`) is wrapped in a `NavigationStack`.
- Navigation to Detail is done via `NavigationLink(value: show)` combined with `.navigationDestination(for: Show.self) { show in DetailView(show: show) }`, which is the recommended type-safe, decoupled navigation pattern (the List View doesn't need to know how Detail is constructed beyond the type).
- No custom `NavigationPath` manipulation is required for v1 (no deep linking, no programmatic multi-step navigation) — a plain `NavigationStack` with default path management is sufficient and keeps things simple.
- This choice is easily extensible later: if deep linking or a 3rd screen is added, introducing an explicit `@State private var path = NavigationPath()` is a small, additive change, not a rewrite.

---

## 12. Networking Strategy

- **`URLSession`** with Swift Concurrency (`async/await`) — no Combine, no completion-handler-based APIs, no third-party networking library (Alamofire, etc.). This is the leanest, most modern, most testable approach and matches what the assignment implicitly expects ("Swift, SwiftUI").
- **`Codable`** + **`JSONDecoder`** for decoding, with `.convertFromSnakeCase` not needed here since TVMaze's JSON keys are already close to Swift naming (verify field-by-field during implementation; a couple of fields like `webChannel`/`dvdCountry` are already camelCase-compatible in TVMaze's raw response... engineer should double check exact casing against a live response before finalizing `CodingKeys`).
- **Dependency Injection**: define a `NetworkServiceProtocol` with a single method, e.g.:
  ```swift
  protocol NetworkServiceProtocol {
      func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
  }
  ```
  A concrete `URLSessionNetworkService` implements this. The Repository depends on the protocol, not the concrete type, so a `MockNetworkService` can be substituted in unit tests with zero real network calls.
- **Endpoint modeling**: a small `Endpoint` type (or simple enum) encapsulating path + query items keeps URL construction in one place, rather than string-interpolated URLs scattered across the codebase.
- Timeout: use a reasonable `URLSessionConfiguration.timeoutIntervalForRequest` (e.g., 15s) so failures surface as `.timeout` rather than hanging indefinitely.

---

## 13. Image Loading Strategy

### 13.1 Recommendation: SwiftUI's Native `AsyncImage`

For this assignment's scope, **`AsyncImage`** (built into SwiftUI since iOS 15) is the recommended approach.

**Why:**

- Zero third-party dependencies — keeps the project simple to build/review, which matters for a take-home reviewed by someone else.
- Built-in support for placeholder/loading/failure phases via `AsyncImage(url:) { phase in ... }`, which maps cleanly onto the "handle loading/error" requirement at the image level too.
- Sufficient for a ~250-row list on a single page with no pagination — the volume doesn't demand a heavier caching solution for v1.

### 13.2 Tradeoffs

| Approach                                                  | Pros                                                                            | Cons                                                                                                                                                                                                   |
| --------------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **`AsyncImage` (recommended)**                            | Native, no dependencies, simple API, built-in phases                            | No persistent/disk caching out of the box — re-scrolling past a row may re-fetch the image from URLSession's in-memory cache only (acceptable for v1); no request de-duplication/prioritization tuning |
| **Kingfisher / SDWebImage / Nuke (3rd-party)**            | Robust disk + memory caching, request de-duplication, prefetching, more control | Adds external dependency + SPM resolution overhead for a small assignment; likely seen as over-engineering by a reviewer for a 2-screen app                                                            |
| **Custom `URLSession`-based image loader with `NSCache`** | Full control, no dependency, in-memory caching across scrolls                   | More code to write and test for marginal benefit at this scale; better suited once pagination/heavier image reuse is added                                                                             |

**Guidance for the engineer:** Use `AsyncImage` for v1. If time allows and code quality is otherwise solid, a very small `NSCache<NSURL, UIImage>`-backed wrapper around `AsyncImage`'s loading (custom `ImageLoader`) is a reasonable "polish" addition and demonstrates awareness of the caching gap — but this is optional, not required, and should not come at the cost of the core required features. Document the choice either way in the README (§20).

---

## 14. HTML Rendering Strategy

The `summary` field arrives as HTML, e.g.:

```
"<p><b>Under the Dome</b> is the story of a small town that is
suddenly and inexplicably sealed off from the rest of the world...</p>"
```

### 14.1 Recommended Approach

Convert the HTML string into an `NSAttributedString` using `Data(using: .utf8)` + `NSAttributedString(data:options:documentAttributes:)` with `.documentType: .html`, then bridge to SwiftUI via `AttributedString(nsAttributedString)` and render with `Text(attributedString)`. This is the standard, dependency-free way to get **basic formatting preserved** (bold, italics, paragraph breaks) while avoiding a full HTML rendering engine.

**Important caveats to document/handle:**

- `NSAttributedString(data:options:documentAttributes:)` with `.documentType: .html` is a **synchronous, non-trivial-cost operation** (it spins up WebKit under the hood on some OS versions) — for a single Detail Screen conversion of one short summary, this is negligible, but it should **not** be run per-row in the List Screen (it isn't needed there — the list only shows title/rating, not summary — so this concern is naturally avoided by the screen split in this PRD).
- Do the conversion **off the main thread if it's ever done at list-scale**; for the single Detail Screen conversion in v1, doing it synchronously on `.task`/`.onAppear` in the ViewModel is acceptable, but should still not block the initial screen paint (recommended: perform the conversion in the ViewModel's `init` or an `async` context, not directly in the View's `body`).

### 14.2 Fallback / Simpler Alternative

If `NSAttributedString` HTML parsing proves finicky (e.g., default font/color doesn't match the app's design system, requiring extra style-stripping work), a simpler and fully acceptable fallback is:

- Strip HTML tags via a regular expression or a small manual parser (e.g., `NSRegularExpression` removing `<[^>]+>`), then decode HTML entities (`&amp;`, `&#39;`, etc.), and display as plain `Text` with the app's own typography.
- This loses bold/italic styling but is simpler, more predictable, and fully satisfies the requirement ("summary contains HTML" → must not be shown as raw markup).

**Recommendation for the take-home:** Attempt the `NSAttributedString` approach first since it's a nice quality signal (preserves formatting with zero dependencies), but the regex-strip fallback is a perfectly acceptable, lower-risk choice if time is limited — reviewers should weight _correctness and no raw HTML on screen_ far above _which of these two methods was chosen_.

### 14.3 For Share (§2.8)

Regardless of which rendering method is used on-screen, the **shared text must be plain text** (no HTML, no attributed-string artifacts) — reuse the tag-stripped plain-text version for the `ShareLink`/activity items, since share sheets and Messages/Mail don't render arbitrary HTML.

---

## 15. Error Handling Strategy

### 15.1 Error Sources & Handling Matrix

| Source                          | Detection                                                    | User-Facing Message                                                                 | Recovery                                                  |
| ------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------------------------- | --------------------------------------------------------- |
| **No connectivity**             | `URLError.notConnectedToInternet` / `.networkConnectionLost` | "No internet connection. Please check your network and try again."                  | Retry button                                              |
| **Timeout**                     | `URLError.timedOut`                                          | "The request timed out. Please try again."                                          | Retry button                                              |
| **Invalid response (4xx/5xx)**  | HTTP status outside 200-299                                  | "Something went wrong while loading shows. Please try again."                       | Retry button                                              |
| **Decoding failure**            | `DecodingError` thrown by `JSONDecoder`                      | "We couldn't process the data from the server. Please try again."                   | Retry button                                              |
| **Image unavailable**           | `AsyncImage` `.failure` phase, or `nil` URL                  | Silent, non-blocking — show a placeholder graphic in place of the image             | None needed; not a blocking error, just a visual fallback |
| **Null rating**                 | `rating.average == nil`                                      | Silent, non-blocking — show "N/A" instead of a number                               | None needed; this is valid data, not an error             |
| **Empty summary/premiere date** | Field is `nil` on the `Show`                                 | Silent, non-blocking — show fallback copy ("No description available." / "Unknown") | None needed                                               |

### 15.2 Principles

1. **Distinguish "the request failed" from "a field is missing."** Only a failed _network request_ triggers the List Screen's `.error` ViewState. A `nil` rating, image, or summary is normal, valid data and must be handled locally/silently at the field level — never bubble up to a full-screen error.
2. **Never show raw system error text to the user.** All errors are mapped through `NetworkError` (§8.4) into the fixed message table above before reaching the View.
3. **Every error path has a recovery action.** For network-level errors, that's Retry. For field-level gaps (image/rating/summary), that's a graceful placeholder — there's nothing to "retry" for a genuinely missing field.
4. **Retry is idempotent and debounced against duplicate taps** (§2.4) — the ViewModel should track an `isRequestInFlight` flag (or equivalent) so double-taps don't fire two concurrent fetches.

---

## 16. Unit Testing Plan

### 16.1 What Should Be Tested

- **Repository layer**: given a mocked `NetworkServiceProtocol` response (success JSON, failure, empty array), verify the Repository returns the correctly mapped `[Show]` domain models, or correctly propagates/maps errors.
- **ViewModel layer**: given a mocked `ShowRepositoryProtocol`, verify:
  - Initial state transitions correctly from `.loading` → `.success` on a successful fetch.
  - Initial state transitions correctly from `.loading` → `.error` on a failed fetch, with the expected message.
  - Empty array response results in `.empty` state, not `.success([])` being treated the same as populated success.
  - Retry re-triggers the fetch and correctly transitions state again.
  - Rating/image nil-handling logic (if any transformation happens at this layer) produces the expected fallback values.
- **Mock Network Service**: a `MockNetworkService: NetworkServiceProtocol` that returns pre-configured canned responses or throws pre-configured errors, without touching real `URLSession`/network — this is what makes Repository and ViewModel tests fast and deterministic.

### 16.2 Expected Test Cases (Minimum Set — assignment requires ≥2, this PRD recommends aiming for 5-8 for a strong submission)

| #   | Layer                                                | Test                                               | Assertion                                                                           |
| --- | ---------------------------------------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 1   | ViewModel                                            | `fetchShows()` succeeds with valid data            | State becomes `.success` with the expected number/content of shows                  |
| 2   | ViewModel                                            | `fetchShows()` fails (mock throws `.noConnection`) | State becomes `.error` with the expected mapped message                             |
| 3   | ViewModel                                            | `fetchShows()` succeeds with an empty array        | State becomes `.empty`, not `.success([])`                                          |
| 4   | ViewModel                                            | `retry()` after a failure                          | State transitions `.error` → `.loading` → `.success`/`.error` again correctly       |
| 5   | Repository                                           | `fetchShows()` maps DTO → Domain correctly         | `rating.average == nil` in DTO maps to `ratingAverage == nil` in domain (not `0.0`) |
| 6   | Repository                                           | `fetchShows()` propagates a decoding failure       | Throws/returns the correct mapped `NetworkError.decodingFailed`                     |
| 7   | Mapper (if extracted separately)                     | HTML summary → plain text stripping                | Given a sample HTML string, tags are removed and text content is preserved          |
| 8   | ViewModel (Detail, if formatting logic exists there) | Premiere date formatting                           | Given `"2008-03-25"`, output matches the expected human-readable format             |

### 16.3 Test Tooling

- Use **XCTest** (built-in, no need for Quick/Nimble at this scale).
- Prefer `async` test functions (`func test_x() async throws`) to naturally test the `async/await` ViewModel/Repository methods without needing expectation/wait boilerplate.
- Keep mocks lightweight — hand-written structs/classes conforming to the protocols are sufficient; no mocking framework (Cuckoo, Mockingbird) is necessary for 1-2 protocols.

---

## 17. Folder Structure

```
TVShowBrowser/
├── TVShowBrowser.xcodeproj
├── TVShowBrowser/
│   ├── App/
│   │   └── TVShowBrowserApp.swift          # @main entry point, root NavigationStack + DI wiring
│   │
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── Show.swift                  # Domain model (Show struct, Identifiable, Equatable)
│   │   └── Repositories/
│   │       └── ShowRepositoryProtocol.swift # protocol ShowRepositoryProtocol
│   │
│   ├── Data/
│   │   ├── DTO/
│   │   │   ├── ShowDTO.swift                # Codable, mirrors raw API JSON shape
│   │   │   ├── ImageLinksDTO.swift
│   │   │   └── RatingDTO.swift
│   │   ├── Mapping/
│   │   │   └── ShowMapper.swift             # ShowDTO -> Show mapping logic
│   │   ├── Repositories/
│   │   │   └── ShowRepository.swift         # concrete implementation of ShowRepositoryProtocol
│   │   └── Networking/
│   │       ├── NetworkServiceProtocol.swift
│   │       ├── URLSessionNetworkService.swift
│   │       ├── Endpoint.swift                # request/path/query construction
│   │       └── NetworkError.swift
│   │
│   ├── Presentation/
│   │   ├── ShowList/
│   │   │   ├── ShowListView.swift
│   │   │   ├── ShowListViewModel.swift
│   │   │   └── Components/
│   │   │       ├── ShowRowView.swift
│   │   │       ├── ErrorStateView.swift
│   │   │       └── EmptyStateView.swift
│   │   └── ShowDetail/
│   │       ├── ShowDetailView.swift
│   │       ├── ShowDetailViewModel.swift
│   │       └── Components/
│   │           └── ShareContentBuilder.swift # builds the shareable text bundle
│   │
│   ├── Core/
│   │   ├── ViewState.swift                   # generic ViewState<T> enum
│   │   ├── Extensions/
│   │   │   ├── String+HTML.swift             # HTML -> AttributedString / plain text helpers
│   │   │   └── Date+Formatting.swift         # premiere date formatting helper
│   │   └── DI/
│   │       └── AppDependencies.swift         # simple composition root (wires Network -> Repository -> ViewModel)
│   │
│   └── Resources/
│       ├── Assets.xcassets                   # placeholder images, app icon, colors
│       └── Localizable.strings               # (optional) user-facing strings, centralizes error/empty copy
│
└── TVShowBrowserTests/
    ├── Mocks/
    │   ├── MockNetworkService.swift
    │   └── MockShowRepository.swift
    ├── RepositoryTests/
    │   └── ShowRepositoryTests.swift
    ├── ViewModelTests/
    │   ├── ShowListViewModelTests.swift
    │   └── ShowDetailViewModelTests.swift
    └── Fixtures/
        └── shows_sample.json                 # canned API response for tests
```

**Notes:**

- `Core/DI/AppDependencies.swift` acts as a lightweight composition root — a single place where `URLSessionNetworkService()` → `ShowRepository(networkService:)` → `ShowListViewModel(repository:)` are wired together, injected into the App entry point. This is the "Dependency Injection" required by the assignment, without needing a framework.
- `Fixtures/shows_sample.json` (a trimmed real or realistic sample of the TVMaze response) is strongly recommended over hand-typing JSON strings inline in every test — keeps tests readable and reusable.

---

## 18. Git Commit Plan

A clean, incremental commit history is itself a quality signal for this assignment. Recommended sequence (~18 commits):

1. `chore: initialize Xcode project with SwiftUI App lifecycle`
2. `chore: set up folder structure (App, Domain, Data, Presentation, Core, Resources)`
3. `docs: add initial README with project overview`
4. `feat(domain): add Show domain model`
5. `feat(domain): add ShowRepositoryProtocol`
6. `feat(data): add ShowDTO and related Codable DTOs`
7. `feat(data): add NetworkError and NetworkServiceProtocol`
8. `feat(data): implement URLSessionNetworkService with async/await`
9. `feat(data): implement ShowMapper (DTO -> domain mapping) with nil-safe rating/image handling`
10. `feat(data): implement ShowRepository conforming to ShowRepositoryProtocol`
11. `feat(core): add generic ViewState<T> enum`
12. `feat(presentation): implement ShowListViewModel with loading/success/error/empty handling`
13. `feat(presentation): build ShowListView with List, ShowRowView, and NavigationStack`
14. `feat(presentation): add ErrorStateView and EmptyStateView components`
15. `feat(presentation): implement ShowDetailViewModel with HTML summary + date formatting`
16. `feat(presentation): build ShowDetailView with large poster, summary, premiere date`
17. `feat(presentation): add Share functionality via ShareLink on Detail screen`
18. `feat(core): add HTML-to-plain-text/AttributedString conversion helper`
19. `test: add MockNetworkService and MockShowRepository`
20. `test: add ShowRepository and ShowListViewModel unit tests`
21. `chore: wire up dependency injection composition root in App entry point`
22. `polish: accessibility labels, Dynamic Type support, placeholder image handling`
23. `docs: finalize README with architecture notes and future improvements`

_(23 listed to give flexibility; a candidate delivering ~15-20 real, meaningful commits following this shape is fully in line with the assignment's expectation — quality and logical grouping matter more than hitting an exact count.)_

---

## 19. Development Roadmap

### Phase 1 — Project Setup

- Create Xcode project (SwiftUI App lifecycle, iOS 16+ deployment target for `NavigationStack`).
- Set up folder structure per §17.
- Write initial README skeleton.

### Phase 2 — Domain & Networking Foundation

- Define `Show` domain model.
- Define `ShowRepositoryProtocol`.
- Define `NetworkServiceProtocol`, `NetworkError`, and `Endpoint`.
- Implement `URLSessionNetworkService`.

### Phase 3 — Data Layer

- Define `ShowDTO` and nested DTOs matching the real TVMaze JSON shape (verify against a live response).
- Implement `ShowMapper` (DTO → domain), with explicit nil-handling for `rating.average` and `image`.
- Implement `ShowRepository`.

### Phase 4 — List Screen

- Implement `ShowListViewModel` with `ViewState<[Show]>`.
- Build `ShowListView` + `ShowRowView`.
- Implement `ErrorStateView` + `EmptyStateView`.
- Wire loading/error/retry/empty flows end-to-end against the real API.

### Phase 5 — Detail Screen & Navigation

- Set up `NavigationStack` + `navigationDestination`.
- Implement `ShowDetailViewModel` (date formatting, HTML handling).
- Build `ShowDetailView` (large poster, title, summary, premiere date).

### Phase 6 — Share Feature

- Implement `ShareContentBuilder` to compose title + plain-text summary + URL.
- Add `ShareLink`/share button to Detail Screen.

### Phase 7 — Testing

- Build `MockNetworkService` / `MockShowRepository`.
- Write Repository and ViewModel unit tests (§16).

### Phase 8 — Polish & Accessibility

- Add accessibility labels, Dynamic Type checks, placeholder graphics for missing images.
- Handle edge cases (nil rating, nil image, nil summary, nil premiere date) defensively across both screens.

### Phase 9 — Documentation & Submission

- Finalize README (§20).
- Review commit history for clarity (squash/reorder if needed).
- Final smoke test on a clean simulator + a real device if available.

---

## 20. README Outline

The submitted README should contain:

1. **Project Title & One-Line Summary**
2. **Screenshots / Screen Recording** (List, Detail, Loading, Error states)
3. **Features Implemented** — checklist against the assignment requirements
4. **Architecture Overview** — brief explanation of MVVM + Clean layering (Presentation/Domain/Data), with a short diagram or bullet list of layer responsibilities
5. **Folder Structure** — brief annotated tree (can be a trimmed version of §17)
6. **Key Design Decisions** — e.g.:
   - Why the Detail Screen reuses List data instead of calling `/shows/{id}` (§2.7)
   - Why `AsyncImage` was chosen over a third-party image library (§13)
   - How HTML summaries are rendered (§14)
   - How `nil` rating/image/summary are handled
7. **How to Run** — Xcode version, iOS deployment target, any setup steps (should be "none" beyond opening and running, since there's no API key)
8. **How to Run Tests** — e.g., `⌘U` in Xcode, or `xcodebuild test` command
9. **Known Limitations / Out of Scope** — pagination, offline persistence, search, etc. (mirrors §1.3)
10. **Future Improvements** — link to/summarize §22
11. **AI Usage Disclosure** (if applicable/requested by the assignment) — what AI tools were used and for what parts, per §21

---

## 21. AI Usage Opportunities

Where AI assistance can meaningfully speed up development, and what must still be manually verified:

| Area                                 | How AI Can Help                                                                     | What Must Be Verified Manually                                                                                                                                                                                   |
| ------------------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **DTO/Codable scaffolding**          | Generating `Codable` structs from a sample TVMaze JSON response                     | Confirm every field's optionality against _actual_ API responses (e.g., confirm `rating.average`, `image`, `premiered` are genuinely nullable in practice, not just assumed) — AI may guess wrong on optionality |
| **Boilerplate SwiftUI views**        | Scaffolding basic `List`/`VStack` layouts, `ShareLink` usage syntax                 | Visual review on simulator/device — AI-generated layout code often needs spacing/alignment/Dynamic Type adjustments                                                                                              |
| **Unit test scaffolding**            | Generating `XCTestCase` structure, async test boilerplate, mock class skeletons     | Ensure assertions are meaningful (not just "does it compile") and that mocks actually simulate the failure/edge cases described in §16, not just the happy path                                                  |
| **HTML-to-text conversion approach** | Suggesting the `NSAttributedString(data:options:)` pattern or regex-based stripping | Test against the _actual_ summary HTML TVMaze returns (nested tags, entities like `&amp;`, `&#39;`) — verify no raw tags/artifacts leak into the UI                                                              |
| **Error message copy**               | Drafting user-facing error/empty-state copy                                         | Ensure tone is consistent with the rest of the app and that no technical jargon (e.g., "DecodingError") leaks into user-facing text                                                                              |
| **README drafting**                  | Generating a first-pass structure/copy                                              | Ensure it accurately reflects what was _actually_ built, not what was planned — mismatches here are an obvious red flag to a reviewer                                                                            |
| **Refactoring suggestions**          | Identifying places to extract protocols, reduce duplication                         | Confirm refactors don't break the required layering (e.g., don't let AI casually import `SwiftUI` into the Domain layer for "convenience")                                                                       |

**General principle:** AI is well-suited to scaffolding and boilerplate; the engineer remains responsible for verifying API contract assumptions (nullability, field shapes), for the correctness of edge-case handling, and for ensuring the final architecture matches this PRD's layering — not just "compiles and runs."

---

## 22. Future Improvements

Explicitly **not required** for this assignment, but worth noting to demonstrate forward-thinking engineering judgment:

- **Pagination**: fetch `page=1, 2, 3…` as the user scrolls near the bottom of the list (infinite scroll), instead of only loading page 0.
- **Search**: a search bar filtering shows by name, either client-side (over the loaded page) or via TVMaze's `/search/shows?q=` endpoint.
- **Favorites**: allow users to bookmark shows, persisted locally (SwiftData or a simple `UserDefaults`-backed store for a small ID set).
- **Image caching**: introduce a small `NSCache`-backed wrapper or a lightweight third-party image library (Nuke/Kingfisher) for disk-persistent caching across app launches.
- **Offline cache**: persist the last successful `/shows` response (e.g., via SwiftData or a JSON file cache) so the app can show _something_ on next launch even without connectivity, with a "showing cached data" indicator.
- **Dependency Injection framework**: adopt a lightweight DI container (e.g., Factory, Swinject) if the app's dependency graph grows beyond what manual initializer injection can cleanly handle.
- **Snapshot testing**: add snapshot tests (e.g., via `swift-snapshot-testing`) for `ShowRowView`, `ErrorStateView`, and `ShowDetailView` to catch unintended visual regressions.
- **Pull-to-refresh**: add `.refreshable {}` on the List Screen for manual refresh without leaving the screen.
- **Automatic retry with backoff**: for transient network errors, retry silently once or twice with exponential backoff before surfacing the Error state to the user.
- **Deep linking**: support opening a specific show's Detail Screen directly via a universal link or URL scheme.
- **iPad-optimized layout**: adopt a `NavigationSplitView` for a two-column List/Detail layout on iPad/large-screen devices.
- **Localization**: externalize all user-facing strings (currently sketched via `Localizable.strings` in §17) and support multiple languages.
- **Analytics/telemetry**: track error rates, retry frequency, and screen views to inform future prioritization (with appropriate privacy handling).

---

## Appendix A: Quick Requirement-to-Section Traceability

| Assignment Requirement                                           | Covered In         |
| ---------------------------------------------------------------- | ------------------ |
| iOS only, Swift, SwiftUI, MVVM                                   | §9, §17            |
| Loading / Error+Retry / Success states                           | §2.2-2.4, §10, §15 |
| List Screen (poster, title, rating, nullable rating)             | §2.6, §6.1, §7.3   |
| Detail Screen (large poster, title, HTML summary, premiere date) | §2.7, §6.2, §14    |
| Share (title, summary, TVMaze URL)                               | §2.8, §6.2         |
| Minimum 2 unit tests                                             | §16                |
| Clean Architecture preferred                                     | §9                 |
| Focus on quality over feature completeness                       | §1.3, §19, §22     |

---

_End of Document._
