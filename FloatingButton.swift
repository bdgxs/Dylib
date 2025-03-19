import UIKit

class FloatingButton: UIButton {
    init() {
        super.init(frame: CGRect(x: 20, y: 60, width: 60, height: 60))
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        setTitle("Info", for: .normal)
        backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        layer.cornerRadius = 30
        clipsToBounds = true
        windowLevel = UIWindow.Level.alert + 1
    }
}