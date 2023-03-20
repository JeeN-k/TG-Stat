//
//  String+Extension.swift
//  TG Stat
//
//  Created by user on 18.03.2023.
//

import UIKit

extension String {
  func trunc(length: Int, trailing: String = "…") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func isLight() -> Bool {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            let brightness = (red * 299 + green * 587 + blue * 114) / 1000
            return brightness > 0.5
        }
}
