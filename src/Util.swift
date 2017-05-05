//
//  Util.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/4/13.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /// Convienece sub string function, [from ~ to]
    ///
    /// - Parameters:
    ///   - start: index start from 0
    ///   - end: end start from 0
    /// - Returns: return cutted string or empty string if index out of range.
    func subString(from start: Int, to end: Int) -> String {
        if self.characters.count >= end + 1 && start < end + 1 {
            let startIndex = self.index(self.startIndex, offsetBy: start)
            let endIndex = self.index(self.startIndex, offsetBy: end + 1)
            return self.substring(with: startIndex..<endIndex)
        }
        return ""
    }
}

extension UIColor {
    /// Create UIColor directly from hex string.
    ///
    /// - Parameters:
    ///   - hex: the hex string without '#'.
    ///   - alpha: alpha number. value between 0 ~ 1.
    convenience init(hexString hex: String, alpha: CGFloat = 1) {
        guard let hexInt = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    /// Make a image that fill with same color.
    ///
    /// - Returns: UIImage.
    func toImage() -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        self.setFill()
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension Array {
    /// A safety way to get a element in array.
    ///
    /// - Parameter number: index that you want to get.
    /// - Returns: Element or nil(out of range).
    func get(_ number: Int) -> Element? {
        return (number > self.count - 1 || number < 0) ? nil : self[number]
    }
}

extension CGFloat {
    /// Initialization from string, for example: CGFloat("0.5").
    ///
    /// - Parameter str: the float number in string.
    init(string str: String) {
        guard let num = NumberFormatter().number(from: str) else {
            self = 0
            return
        }
        self = CGFloat(num)
    }
}

enum HashableControlState: UInt {
    case normal             = 0
    case highlighted        = 1
    case disabled           = 2
    case selected           = 4
    case focused            = 8
    
    func toControlState() -> UIControlState {
        return UIControlState(rawValue: self.rawValue)
    }
}
