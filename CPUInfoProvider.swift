import Foundation
import Darwin.sys.sysctl
import Darwin.mach.host_info
import Darwin.mach.mach_host

// Define structs to hold CPU and Memory information

struct CPUInfo {
    var model: String
    var cpuBrand: String
    var coreCount: UInt32
    var threadCount: UInt32
}

struct MemoryInfo {
    var totalMemory: UInt64
    var freeMemory: UInt64
}

class CPUInfoProvider {
    static let shared = CPUInfoProvider() // Singleton pattern

    private init() {}

    // Helper function to handle sysctl errors
    private func sysctl(byName name: String) -> String {
        var size: Int = 0
        sysctlbyname(name, nil, &size, nil, 0)

        guard size > 0 else {
            return "Unknown"
        }

        var value = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &value, &size, nil, 0)

        return String(cString: value)
    }

    private func sysctl(byName name: String) -> Int {
           var value: Int = 0
           var size = MemoryLayout<Int>.size
           if Darwin.sys.sysctlbyname(name, &value, &size, nil, 0) == 0 {
               return value
           } else {
               return 0
           }
       }
    
    func getCPUInfo() -> CPUInfo {
        var info = CPUInfo(model: "Unknown", cpuBrand: "Unknown", coreCount: 0, threadCount: 0)

        info.model = sysctl(byName: "hw.machine")
        info.cpuBrand = sysctl(byName: "machdep.cpu.brand_string")
        info.coreCount = UInt32(sysctl(byName: "hw.physicalcpu"))
        info.threadCount = UInt32(sysctl(byName: "hw.logicalcpu"))


        return info
    }

    func getMemoryInfo() -> MemoryInfo {
        var info = MemoryInfo(totalMemory: 0, freeMemory: 0)

        var totalMemory: UInt64 = 0
        var size = MemoryLayout.size(ofValue: totalMemory)
        if Darwin.sys.sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0) == 0 {
            info.totalMemory = totalMemory
        }

        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(HOST_VM_INFO64_COUNT)

        if host_statistics64(mach_host_self(), HOST_VM_INFO64, &vmStats, &count) == KERN_SUCCESS {
            let pageSize = vm_page_size
            info.freeMemory = UInt64(vmStats.free_count) * UInt64(pageSize)
        }

        return info
    }
}