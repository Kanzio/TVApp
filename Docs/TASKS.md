# Implementation Tasks

## Phase 1: Project Setup
- [x] Initialize Xcode project (SwiftUI App lifecycle, iOS 16+).
- [x] Set up folder structure (App, Domain, Data, Presentation, Core, Resources).
- [x] Create initial `README.md` skeleton.
- [x] Set up `AI_LOG.md`, `CODE_REVIEW.md`, and `REFLECTION.md` in the repository root as required by the submission guidelines.

## Phase 2: Domain & Networking Foundation
- [ ] Define `Show` domain model.
- [ ] Define `ShowRepositoryProtocol`.
- [ ] Define `NetworkServiceProtocol`, `NetworkError`, and `Endpoint`.
- [ ] Implement `URLSessionNetworkService` using `async/await`.

## Phase 3: Data Layer
- [ ] Create `ShowDTO` and nested DTOs matching TVMaze JSON response.
- [ ] Implement `ShowMapper` for mapping DTOs to the `Show` domain model, carefully handling nullable fields (rating, image).
- [ ] Implement `ShowRepository` conforming to `ShowRepositoryProtocol`.

## Phase 4: Core Utilities & DI
- [ ] Create generic `ViewState<T>` enum.
- [ ] Add HTML to plain-text / `AttributedString` conversion helper.
- [ ] Add date formatting extensions for the premiere date.
- [ ] Set up `AppDependencies.swift` for lightweight dependency injection.

## Phase 5: List Screen
- [ ] Implement `ShowListViewModel` with loading, success, error, and empty state management.
- [ ] Create `ErrorStateView` (with retry button) and `EmptyStateView` components.
- [ ] Build `ShowRowView` to display poster thumbnail (`AsyncImage`), title, and rating.
- [ ] Build `ShowListView` displaying the list of shows and handling the different `ViewState`s.
- [ ] Wire up the dependency injection in the App entry point.

## Phase 6: Detail Screen & Navigation
- [ ] Implement `ShowDetailViewModel`.
- [ ] Build `ShowDetailView` with large poster, title, formatted summary, and human-readable premiere date.
- [ ] Connect navigation from `ShowListView` to `ShowDetailView` using `NavigationStack` and `NavigationLink`.

## Phase 7: Share Feature
- [ ] Implement `ShareContentBuilder` to compose shareable text (title, plain-text summary, TVMaze URL).
- [ ] Add `ShareLink` to the `ShowDetailView` toolbar.

## Phase 8: Testing
- [ ] Create `MockNetworkService` and `MockShowRepository`.
- [ ] Write unit tests for `ShowRepository` (mapping logic, error propagation).
- [ ] Write unit tests for `ShowListViewModel` (state transitions, retry logic, empty states).

## Phase 9: Polish & Final Submission Tasks
- [ ] Add accessibility labels and verify Dynamic Type support.
- [ ] Ensure placeholder graphics are shown for missing images.
- [ ] Finalize `README.md` with architecture decisions and future improvements.
- [ ] Complete `AI_LOG.md` with the required AI usage entries.
- [ ] Complete `CODE_REVIEW.md` (Code review exercise from PDF).
- [ ] Complete `REFLECTION.md` (Written reflection from PDF).
- [ ] Record the 5-minute walkthrough video and add the link to the `README.md`.
