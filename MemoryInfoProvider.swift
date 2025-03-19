import Foundation

class MemoryInfoProvider {
    static let shared = MemoryInfoProvider()

    private init() {}

    func getMemoryInfo() -> MemoryInfo {
        return CPUInfoProvider.shared.getMemoryInfo()
    }
}