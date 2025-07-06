import Foundation

class PushUpSessionTracker {
    static let shared = PushUpSessionTracker()

    private let serialQueue = DispatchQueue(label: "pushup.queue")
    private var _data: Int = 0

    private init() {}

    var soFar: Int {
        get {
            return serialQueue.sync { _data }
        }
        set {
            serialQueue.async { [weak self] in
                self?._data = newValue
            }
        }
    }
}
