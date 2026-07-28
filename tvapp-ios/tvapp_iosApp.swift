import SwiftUI

@main
struct tvapp_iosApp: App {
    @State private var dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            ShowListView(viewModel: ShowListViewModel(repository: dependencies.showRepository))
        }
    }
}
