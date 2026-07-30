# Video Walkthrough Link

[Watch 5-Minute Video Walkthrough](https://drive.google.com/file/d/14oZq35cAiTFTjfg4YHsclzSX-XzllfBn/view?usp=sharing)

---

# TV Show Browser (iOS App)

A modern, production-quality iOS app built with **SwiftUI**, **async/await**, and **Clean Architecture**. This application fetches data from the public [TVMaze API](https://www.tvmaze.com/api) to allow users to browse popular TV shows, view detailed show metadata, browse cast members, explore seasons, and view episode listings per season.

Built as part of the **Mamikos iOS Take-Home Assignment**.

---

## 🌟 Key Features

- **TV Show Catalog & Infinite Scroll**: Displays a list of TV shows with poster thumbnails, titles, and ratings. Features seamless infinite scrolling pagination that loads next pages automatically as you reach the bottom of the list.
- **Rich Show Detail Screen**:
  - High-resolution poster banner.
  - HTML summary rendered cleanly into formatted rich text (`AttributedString`).
  - Human-readable premiere dates (e.g., `"June 24, 2013"`).
  - **Horizontal Cast Carousel**: Scrollable list of cast member avatars with actor and character names (`/shows/:id/cast`).
  - **Horizontal Season Carousel**: Scrollable cards for all seasons (`/shows/:id/seasons`).
- **Season Episode Listing**: Tapping any season card opens a dedicated `SeasonDetailView` displaying a list of all episodes (`/seasons/:id/episodes`) with episode images, episode numbers, ratings, and summaries.
- **Native Content Sharing**: Integrated native `ShareLink` in the navigation toolbar to share show information (Title, plain-text summary, and TVMaze URL).
- **State Management & UI Feedback**: Comprehensive handling of all state transitions:
  - **Loading State**: Custom activity indicators with accessibility labels.
  - **Error State**: User-friendly error messaging with an interactive **Retry** button.
  - **Empty State**: Dedicated empty state views for missing data.
  - **Success State**: Smooth content rendering.
- **Accessibility & Dynamic Type**: Includes `accessibilityLabel`, `accessibilityHidden` for decorative icons, and full support for native iOS Dynamic Type scalability.

---

## 🏗 Architecture Overview

The app strictly adheres to **Clean Architecture** and the **MVVM (Model-View-ViewModel)** pattern, ensuring high testability, separation of concerns, and maintainability.

```
tvapp-ios/
├── App/                  # App Entry point & Dependency Injection (AppDependencies)
├── Domain/               # Pure Swift business logic (Models & Repository Protocols)
│   ├── Models/           # Show, Season, Episode, CastMember
│   └── Repositories/     # ShowRepositoryProtocol
├── Data/                 # Data fetching, Networking, DTOs, Mappers
│   ├── DTO/              # ShowDTO, SeasonDTO, EpisodeDTO, CastDTO, etc.
│   ├── Mapping/          # ShowMapper, SeasonMapper, EpisodeMapper, CastMapper
│   ├── Networking/       # URLSessionNetworkService, Endpoint, NetworkError
│   └── Repositories/     # ShowRepository (Concrete implementation)
├── Presentation/         # SwiftUI Views & @Observable ViewModels
│   ├── ShowList/         # ShowListView, ShowListViewModel, ShowRowView
│   ├── ShowDetail/       # ShowDetailView, ShowDetailViewModel, CastMemberCardView, SeasonCardView
│   └── SeasonDetail/     # SeasonDetailView, SeasonDetailViewModel, EpisodeRowView
└── Core/                 # Shared Utilities & Extensions
    ├── Extensions/       # String+HTML, Date+Formatting
    └── ViewState.swift    # Generic ViewState<T> enum (Loading, Success, Error, Empty)
```

---

## 📐 Key Design Decisions

1. **Modern Observation Framework (`@Observable`)**: Uses iOS 17's `@Observable` macro for view models instead of the legacy `ObservableObject` / `@Published` pair, resulting in granular tracking and better performance.
2. **Repository Pattern & Protocol Abstraction**: `ShowDetailViewModel` and `ShowListViewModel` depend on `ShowRepositoryProtocol` rather than concrete network implementations, enabling effortless unit testing via mock repositories.
3. **Decoupled HTML Parsing**: HTML parsing (`NSAttributedString`) is performed asynchronously inside `loadData()` outside of SwiftUI's synchronous `body` layout pass, avoiding `AttributeGraph` rendering cycles.
4. **Resilient Pagination**: `loadMoreShows()` silently rolls back page counters on network failure without destroying already loaded data.
5. **Horizontal Edge Bleeding (`ScrollView`)**: Horizontal carousels for Cast and Seasons use negative horizontal margins combined with inner padding to bleed edge-to-edge across the screen without hard edge clipping.

---

## 🧪 Testing

The repository contains a robust suite of both **Unit Tests** (written with Swift Testing) and **UI Tests** (written with XCTest).

### Unit Tests (`tvapp-iosTests/`)

- **`ShowRepositoryTests`**: Tests JSON DTO mapping, nullable field fallbacks (e.g. image URLs), and error propagation.
- **`ShowListViewModelTests`**: Tests state transitions (`.loading` → `.success` / `.empty` / `.error`), infinite scroll pagination appending, page rollback on error, and retry logic.

### UI Tests (`tvapp-iosUITests/`)

- **`tvapp_iosUITests`**: Tests navigation bar titles, tapping list cells, navigating from `ShowListView` to `ShowDetailView`, verifying Cast and Seasons section headers exist, and navigating back.

### How to Run Tests

- Open `tvapp-ios.xcodeproj` in Xcode.
- Press `Cmd + U` to execute the full test suite.

---

## 🚀 How to Run the App

1. Open `tvapp-ios.xcodeproj` in Xcode (Xcode 15+ / iOS 17+ recommended).
2. Select the `tvapp-ios` target and an iOS Simulator (e.g., iPhone 15 Pro).
3. Press `Cmd + R` to build and run.

---

## 📄 Repository Required Documentation

This repository contains all 4 required submission documents in the root directory:

- [`README.md`] — Project documentation and walkthrough link.
- [`AI_LOG.md`] — Honest log of 6 detailed AI interactions, prompt choices, and bug resolution tracebacks.
- [`CODE_REVIEW.md`] — Code review evaluation of the sample `MovieViewModel`.
- [`REFLECTION.md`] — Written answers to all 5 reflection questions.
