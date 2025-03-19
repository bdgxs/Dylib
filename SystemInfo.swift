import Foundation
import UIKit
import Darwin // Import Darwin for sysctl, etc.

// Global variables (try to minimize these)
var infoWindow: InfoWindow?
var floatingButton: FloatingButton?

// %group SystemInfo // You might need this for Theos

%hook UIWindow

    // Method swizzling is generally discouraged in Swift.
    //  It's often better to use delegation or other patterns.
    //  However, for a tweak, it might be necessary.
    //  Be VERY careful with this!
    
    //  Here's how you might approach it (this is illustrative and might need tweaking):
    
    override func makeKeyAndVisible() {
        orig() // Call the original implementation
        
        DispatchQueue.once { // Use DispatchQueue.once to ensure setup happens only once
            setupFloatingButton()
        }
    }
    
    func setupFloatingButton() {
        floatingButton = FloatingButton()
        floatingButton!.addTarget(self, action: #selector(toggleInfo), for: .touchUpInside)

        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(floatingButton!)
        }
    }
    
    @objc func toggleInfo() {
        if let window = infoWindow {
            hideInfo()
        } else {
            showInfo()
        }
    }
    
    func showInfo() {
        let cpuInfo = CPUInfoProvider.shared.getCPUInfo()
        let memoryInfo = MemoryInfoProvider.shared.getMemoryInfo()
        
        infoWindow = InfoWindow(cpuInfo: cpuInfo, memoryInfo: memoryInfo)
        infoWindow?.makeKeyAndVisible()
    }
    
    func hideInfo() {
        infoWindow?.removeFromSuperview()
        infoWindow = nil
    }

%end