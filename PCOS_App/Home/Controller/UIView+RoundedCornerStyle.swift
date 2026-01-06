import UIKit

extension UIView {
    /// Applies a corner radius to the view and masks its bounds so the corners appear rounded.
    /// - Parameter radius: The corner radius to apply.
    func RoundedCornerStyle(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
