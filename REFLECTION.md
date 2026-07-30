# Reflection

1. Which part of your submission are you least confident about, and why?

I'm least confident about following iOS/Swift best practices throughout the project — things like folder structure, architectural conventions, and idiomatic Swift code style. My background is primarily in web development, and I've only recently started learning Swift, so I don't yet have the depth of experience to confidently say my code follows the "right" patterns the way an experienced iOS developer would. I did my best to research and apply conventions I found (like MVVM structure and SwiftUI-specific patterns), but I'm aware there are likely places where a more seasoned iOS developer would organize things differently or catch idioms I'm not yet aware of.

2. Describe a moment during this project where you got completely stuck. What did you do, step by step?

While working on this assignment, I ran into an infinite loading state on the Show Detail View when fetching season data. This was tricky for me because my background is primarily in frontend web development with React, so I had to dig into SwiftUI-specific patterns and constraints I wasn't familiar with yet.

My first instinct was that it was a rendering issue. I opened the Xcode console and found a recurring log: "AttributeGraph: Cycle detected" which confirmed my suspicion of a rendering cycle problem. I then added logging to check whether the fetched data itself was empty, but it turned out the data was fetching correctly. Since the AttributeGraph warning consistently appeared whenever I opened the Show Detail View, I narrowed the problem down to that specific view's code.

From there, I collaborated with AI to help pinpoint the root cause within ShowDetailView and ShowDetailViewModel. We found that the HTML-to-AttributedString parsing logic was being executed directly inside the view's body, which is expensive and was triggering repeated re-renders. The fix was to move that parsing logic out of body entirely into an async function called from .onAppear instead so it only runs once rather than on every view update.

Lesson learned: never run expensive computation directly inside body. Heavy work should always be pulled out and handled asynchronously (e.g. in onAppear or a background task) so it doesn't interfere with SwiftUI's rendering cycle.

3. Imagine: it's Thursday, your task is due Friday, and you realize you misunderstood the requirement, half your work is wrong. What are you doing now?

First, I'd acknowledge the mistake instead of trying to hide it or rush a workaround, since I misunderstood the requirement, that's on me, and the priority is to fix it properly rather than defend the wrong approach.

Step by step, I would:

    - Assess the damage: figure out exactly which parts of my work are actually wrong versus what's still reusable, so I don't throw away more than necessary.
    - Re-read the requirement carefully, and if it's ambiguous or open to interpretation, I'd immediately reach out to my mentor/team to clarify and confirm the correct understanding rather than guessing again and risking a second mistake.
    - Communicate proactively: I'd let them know as early as possible that I found the issue, what I misunderstood, and my plan to fix it, instead of staying silent until the deadline.
    - Re-prioritize and replan: with the time left, focus on fixing the core/critical parts first, and be honest if I think I won't fully finish by Friday, so expectations can be managed early rather than at the last minute.
    - Execute with focus, cutting any non-essential polish to make sure the corrected core functionality is solid and delivered on time.

4. Your mentor asks you to change an approach you believe is worse. What do you do?

I would bring it up for discussion rather than silently comply or silently ignore it. I'd explain my reasoning and walk through a comparison between my approach and theirs, the trade-offs, pros, and cons of each, so we're evaluating it based on substance rather than just deferring to authority or stubbornly sticking to my own idea.

If, through that discussion, it turns out their approach is actually better, maybe because they have context or experience I don't, I'd genuinely thank them for the insight and adopt it without resistance.

If I still believe my approach is stronger after comparing both, I'd continue the discussion respectfully, laying out the specific reasons and trade-offs clearly, so we can reach a decision together based on the best argument rather than just deferring to seniority or giving up on my position too easily.

Either way, I see this as a collaborative conversation, not a conflict, the goal is to land on the best solution, whoever it comes from.

5. What's something technical you taught yourself recently outside of class/work, and how did you learn it?

Recently I've been teaching myself Xcode and Swift for iOS development. Coming from a frontend web development background mainly React.js, I wanted to expand into a new area of competency: native iOS development.

I approached learning Swift and SwiftUI by drawing parallels to concepts I already knew from React, for example, mapping SwiftUI's declarative UI and state management (@State, @Published, ObservableObject) to React's component state and hooks, since both frameworks share a similar declarative mental model even though the syntax and platform are completely different.

To learn hands-on, I used AI as a learning aid to help explain unfamiliar Swift/SwiftUI concepts and patterns, and I built a small functional project, a movie search app using the TMDb API, as a practical way to apply what I was learning fetching data from a real API, handling async operations, managing state, and building out UI in SwiftUI. Building something functional end-to-end helped the concepts stick much better than just reading documentation alone.
