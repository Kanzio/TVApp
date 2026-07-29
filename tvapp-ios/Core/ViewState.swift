import Foundation

enum ViewState<T: Equatable>: Equatable {
    case loading
    case success(T)
    case error(String)
    case empty
}
