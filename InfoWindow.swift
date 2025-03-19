import UIKit

class InfoWindow: UIWindow {
    init(cpuInfo: CPUInfo, memoryInfo: MemoryInfo) {
        super.init(frame: CGRect(x: 80, y: 80, width: 250, height: 200))
        setupWindow()
        setupLabels(cpuInfo: cpuInfo, memoryInfo: memoryInfo)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        windowLevel = UIWindow.Level.alert
        backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        layer.cornerRadius = 10
        clipsToBounds = true
    }

    private func setupLabels(cpuInfo: CPUInfo, memoryInfo: MemoryInfo) {
        let cpuLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 230, height: 80))
        cpuLabel.numberOfLines = 0
        cpuLabel.textColor = .white
        cpuLabel.font = .systemFont(ofSize: 14)
        cpuLabel.text = "Model: \(cpuInfo.model)\nBrand: \(cpuInfo.cpuBrand)\nCores: \(cpuInfo.coreCount)\nThreads: \(cpuInfo.threadCount)"
        addSubview(cpuLabel)

        let memLabel = UILabel(frame: CGRect(x: 10, y: 100, width: 230, height: 80))
        memLabel.numberOfLines = 0
        memLabel.textColor = .white
        memLabel.font = .systemFont(ofSize: 14)
        memLabel.text = "Total Memory: \(memoryInfo.totalMemory) bytes\nFree Memory: \(memoryInfo.freeMemory) bytes"
        addSubview(memLabel)
    }
}