import Foundation

final class ServerDuplicateCache {
    private var entries: [String: Bool] = [:]
    private let fileURL: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let dir = base?.appendingPathComponent("ImmichSync", isDirectory: true)
        if let dir {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            fileURL = dir.appendingPathComponent("server-duplicate-cache.json")
        } else {
            fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("server-duplicate-cache.json")
        }
        load()
    }

    func lookup(key: String) -> Bool? {
        entries[key]
    }

    func store(key: String, isDuplicate: Bool) {
        entries[key] = isDuplicate
    }

    func clear() {
        entries.removeAll()
        save()
    }

    func save() {
        if let data = try? JSONSerialization.data(withJSONObject: entries, options: []) {
            try? data.write(to: fileURL, options: [.atomic])
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = json as? [String: Bool] else {
            return
        }
        entries = dict
    }
}
