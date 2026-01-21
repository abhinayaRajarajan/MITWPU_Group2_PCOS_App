//
//  Extensions.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

//
//  UIImageView+FullRoundedCorner.swift
//

import UIKit

extension UIImageView {
    private struct AssociatedKeys {
        static var isFullRoundedKey: UInt8 = 0
    }

    private var isFullRounded: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isFullRoundedKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isFullRoundedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Makes the image view fully rounded (circular) if possible.
    /// This method is idempotent and can be called multiple times safely.
    func addFullRoundedCorner() {
        guard !isFullRounded else { return }
        isFullRounded = true
        clipsToBounds = true
        contentMode = .scaleAspectFill
        applyRoundedIfNeeded()
    }

    /// Applies corner radius based on current frame size if `addFullRoundedCorner()` was called.
    /// Should be called during layout updates to ensure correct rounding.
    func applyRoundedIfNeeded() {
        guard isFullRounded else { return }
        let radius = min(bounds.width, bounds.height) / 2
        if layer.cornerRadius != radius {
            layer.cornerRadius = radius
        }
    }
}
