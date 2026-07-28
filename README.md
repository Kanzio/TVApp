# TV Show Browser

A simple TV show browser app built with Swift and SwiftUI, demonstrating clean architecture principles, state management, and modern iOS development practices. This was built as part of the Mamikos take-home assignment.

## Features Implemented
- [ ] List Screen fetching TV shows from TVMaze API.
- [ ] Detail Screen displaying comprehensive show information.
- [ ] Share action for shows.
- [ ] Loading, Error (with retry), and Success states.
- [ ] MVVM Architecture.
- [ ] Unit Tests.

## Architecture Overview
The application follows a lightweight Clean Architecture pattern utilizing MVVM (Model-View-ViewModel) for the presentation layer.

- **Presentation Layer:** Contains SwiftUI views and ViewModels to handle state (`ViewState`).
- **Domain Layer:** Defines the `Show` domain model and `ShowRepositoryProtocol`.
- **Data Layer:** Implements API calls, network models (DTOs), and mappers.

## Folder Structure
```
tvapp-ios/
├── App/                # App entry point
├── Domain/             # Domain Models and Repository Protocols
├── Data/               # DTOs, NetworkService, Mappers, and Repository Implementations
├── Presentation/       # Views and ViewModels (List and Detail)
├── Core/               # Shared utilities, extensions, and dependency injection
└── Resources/          # Assets and Localization
```

## Key Design Decisions
(To be updated during implementation)

## How to Run
- Open `tvapp-ios.xcodeproj` in Xcode (requires Xcode 14+ / iOS 16+).
- Select the `tvapp-ios` scheme.
- Press `Cmd + R` to build and run the app.

## How to Run Tests
- Press `Cmd + U` to run the unit test suite.

## Known Limitations / Out of Scope
- Pagination beyond the first page is not implemented.
- Offline persistence (e.g., CoreData) is not supported in this version.
- Search / Filtering.

## Future Improvements
- Add infinite scrolling pagination.
- Implement robust image caching (e.g., Kingfisher).
- Add offline storage for browsing without internet access.
- Include Pull-to-refresh functionality.
