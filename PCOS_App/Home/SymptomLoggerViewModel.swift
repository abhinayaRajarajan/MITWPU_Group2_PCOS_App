import Foundation

final class SymptomLoggerViewModel {
    // Basic placeholder state so the type is usable immediately
    struct State {
        var selectedSymptoms: [String] = []
        var date: Date = Date()
    }
    
    var state = State()
    
    init() {}
}
