# AI Usage Log

This log documents meaningful interactions with AI during development of this take-home assignment. Each entry covers what was asked, what was received, the action taken, and an honest assessment of what the AI got wrong or what I had to verify myself.

---

## Entry 1 — Product Requirements Document

**Problem I was solving:**  
Before any code was written, I needed a complete Product Requirements Document to serve as the implementation blueprint for the whole assignment, and then a follow-up prompt I could hand to a coding agent so it would actually execute that PRD faithfully instead of improvising scope.

**What I asked the AI:**  
I referenced the original task PDF attached to the assignment as the source of truth for scope. First, acting as a Senior PM / Senior iOS Architect, produce a full PRD (overview, functional/non-functional requirements, user stories, user flow, screen specs, data model, API layer, architecture, state management, navigation, networking, image loading, HTML rendering, error handling, testing plan, folder structure, commit plan, roadmap, README outline, AI usage opportunities, future improvements) explicitly no implementation code. Second, once the PRD was written, I asked for a follow-up prompt specifically written for an AI coding agent to execute that PRD correctly.

**What it gave me:**  
A PRD (PRD.md) covering every required area, including explicit architectural decisions. Then a separate Prompt.md containing ground rules for an execution agent: work phase-by-phase per the PRD's roadmap.

**Action taken:** Accepted both documents as delivered, no corrections needed at this stage since no code existed yet to surface errors against.

**What the AI got wrong:**  
Nothing was verifiably "wrong" at the planning stage since there's no compiler to catch mistakes in a PRD.

## Entry 2 — Architecture & Project Setup (Phases 1–4)

**Problem I was solving:**  
Set up the project architecture using Clean Architecture principles, separating Domain, Data, and Presentation layers to keep the codebase scalable and maintainable.

**What I asked the AI:**  
Set up the folder structure, networking layer, the repository layer, and core utilities.

**What it gave me:**  
A complete skeleton across all layers with enums, protocols, concrete types, and a DTO → domain mapper with nullable field handling.

**Action taken:** Accepted with review. I cross-referenced the 'ShowMapper' image fallback logic against the actual TVMaze API response to confirm it behaved correctly when 'original' was null.

**What the AI got wrong:**  
'ViewState<T>' was defined without 'Equatable' conformance.

---

## Entry 3 — `@Observable` / `@StateObject` Migration

**Problem I was solving:**  
The initial ViewModels used 'ObservableObject' / '@Published'. I wanted to migrate to the modern '@Observable' macro (iOS 17 Observation framework) and '@State' instead of '@StateObject'.

**What I asked the AI:**  
"Use Observable" — a short instruction expecting a full migration.

**What it gave me:**  
Updated all ViewModels with '@Observable', removed all '@Published' properties, and replaced '@StateObject' with '@State' at the call sites.

**Action taken:** Accepted, but immediately hit a compiler error: 'Initializer 'init(value:label:)' requires that 'Show' conform to 'Hashable'. The AI had migrated to 'NavigationLink(value:)' without adding 'Hashable' to the 'Show' domain model.

**What the AI got wrong:**  
It forgot that 'NavigationLink(value:)' has a 'Hashable' constraint. I had to report the compiler error before the 'Hashable' conformance was added to 'Show.swift'. A simple oversight but it shows the AI doesn't always trace downstream conformance requirements.

---

## Entry 4 — Seasons Infinite Loading Bug (AttributeGraph Cycle)

**Problem I was solving:**  
After implementing the '/shows/:id/seasons' feature, the seasons section was permanently stuck on "Loading seasons..." even though the console logged "Fetched 3 seasons" — confirming the network call succeeded.

**What I asked the AI:**  
Debug why the UI was not updating despite the data being fetched successfully.

**What it gave me (first attempt):**  
Added 'Equatable' to 'ViewState' and removed 'private(set)' from 'seasonsState'. No effect.

**What it gave me (second attempt):**  
Changed '.task' to '.onAppear { Task { ... } }' and changed 'State(wrappedValue:)' to 'State(initialValue:)'. Still no effect.

**What it gave me (third attempt — correct):**  
After I reported 'AttributeGraph: cycle detected' messages in the console, the AI identified the real root cause: 'NSAttributedString' HTML parsing was being performed inside a SwiftUI computed property ('var attributedSummary'). This happened during the layout pass and triggered an infinite re-evaluation loop, causing SwiftUI to abort all pending state updates. The fix was to move HTML parsing into an async 'loadData()' method and store the result as a plain stored property.

**Action taken:** Accepted the third fix. It resolved the bug completely.

**What the AI got wrong:**  
The first two fixes were misdiagnoses. The AI did not identify the 'AttributeGraph' cycle as the cause until I explicitly provided that console error. Without that clue, it was guessing at 'Equatable' and access control issues. This reinforced to me that AI debugging without specific error messages can be unreliable, and I should always surface the exact console output.

---
