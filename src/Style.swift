//
//  Style.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/4/13.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /// Set styles for the UIView object. This function will use singleton Theme instance by default.
    ///
    /// - Parameters:
    ///   - styleID: Identifier for styles.
    ///   - theme: (Optional) Instance of Theme object.
    func setStyle(styleID: String, theme: Theme = Theme.sharedInstance) {
        guard let style = theme.getStyle(ID: styleID) else {
            return
        }
        let keys = style.styles.keys
        for key in keys {
            guard let styles = style.styles[key] else {
                continue
            }
            let state = key.toControlState()
            
            for style in styles {
                if let s = style as? Font {
                    s.apply(view: self, for: state)
                } else if let s = style as? Background {
                    s.apply(view: self, for: state)
                } else if let s = style as? Border {
                    s.apply(view: self, for: state)
                }
            }
        }
    }
}

struct Style {
    var name: String
    var styles: [HashableControlState: [StyleProperty]]
    
    init() {
        name = ""
        styles = [:]
    }
}

protocol StyleProperty {
    func apply(view: UIView, for sate: UIControlState)
    init(propSet: [String: Any])
}

//
// MARK:- Font : StyleProlerty
//
struct Font : StyleProperty {
    var family: String          = "Default"
    var size: CGFloat           = 12
    var color: UIColor          = UIColor.black
    var bold: Bool              = false                             // Only work for system font
    var font: UIFont            = UIFont.systemFont(ofSize: 12)
    
    init(propSet: [String: Any]) {
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0) == "Font" }
        for key in keys {
            switch key {
            case "Font.Color":
                guard let value = propSet[key] as? String else { break }
                self.setColor(valueString: value)
                
            case "Font.Size" :
                guard let value = propSet[key] as? CGFloat else { break }
                self.setSize(value)
                
            case "Font.Family" :
                guard let value = propSet[key] as? String else { break }
                self.setFamily(value)
                
            case "Font.Bold" :
                guard let value = propSet[key] as? Bool else { break }
                self.setBold(value)
                
            default:
                break
            }
        }
        
        if self.family == "Default" {
            self.font = self.bold ? UIFont.boldSystemFont(ofSize: self.size) : UIFont.systemFont(ofSize: self.size)
        } else if let font = UIFont(name: self.family, size: self.size) {
            self.font = font
        }
    }
    
    func apply(view: UIView, for state: UIControlState = UIControlState.normal) {
        if view is UILabel || view is UITextView || view is UITextField {
            view.setValue(self.font, forKey: "font")
            view.setValue(self.color, forKey: "textColor")
        } else if let v = view as? UIButton {
            v.titleLabel?.font  = self.font
            v.setTitleColor(self.color, for: state)
        }
    }
    
    //
    // Property setter
    //
    
    private mutating func setColor(valueString: String) {
        let colorSetting = valueString.components(separatedBy: ",")
        var alpha: CGFloat = 1
        guard let color = colorSetting.get(0) else {
            return
        }
        if let alphaString = colorSetting.get(1) {
            alpha = CGFloat(string: alphaString)
        }
        self.color = UIColor(hexString: color, alpha: CGFloat(alpha))
    }
    
    private mutating func setSize(_ value: CGFloat) {
        self.size = value
    }
    
    private mutating func setFamily(_ value: String) {
        self.family = value
    }
    
    private mutating func setBold(_ value: Bool) {
        self.bold = value
    }
}

//
// MARK:- Background : StyleProlerty
//
struct Background : StyleProperty {
    var color: UIColor          = UIColor.clear
    
    init(propSet: [String: Any]) {
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0) == "BG" }
        for key in keys {
            switch key {
            case "BG.Color":
                guard let value = propSet[key] as? String else { break }
                self.setColor(valueString: value)
                
            default:
                break
            }
        }
    }
    
    func apply(view: UIView, for state: UIControlState = UIControlState.normal) {
        if let btn = view as? UIButton {
            btn.setBackgroundImage(self.color.toImage(), for: state)
        } else {
            view.backgroundColor = self.color
        }
    }
    
    //
    // Property setter
    //
    
    private mutating func setColor(valueString: String) {
        let colorSetting = valueString.components(separatedBy: ",")
        var alpha: CGFloat = 1
        guard let color = colorSetting.get(0) else {
            return
        }
        if let alphaString = colorSetting.get(1) {
            alpha = CGFloat(string: alphaString)
        }
        self.color = UIColor(hexString: color, alpha: CGFloat(alpha))
    }
}

//
// MARK:- Border : StyleProlerty
//
struct Border : StyleProperty {
    var color: UIColor          = UIColor.black
    var width: CGFloat          = 0
    var roundCorner: CGFloat?   = nil
    
    init(propSet: [String: Any]) {
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0) == "Border" }
        for key in keys {
            switch key {
            case "Border.Color":
                guard let value = propSet[key] as? String else { break }
                self.setColor(valueString: value)
                
            case "Border.Width":
                guard let value = propSet[key] as? CGFloat else { break }
                self.setWidth(value: value)
                
            case "Border.RoundConer":
                guard let value = propSet[key] as? CGFloat else { break }
                self.setCornerRadius(value: value)
                
            default:
                break
            }
        }
    }
    
    func apply(view: UIView, for sate: UIControlState = UIControlState.normal) {
        if let conerRadius = self.roundCorner {
            view.clipsToBounds = true
            view.layer.cornerRadius = conerRadius
        }
        
        view.layer.borderColor = self.color.cgColor
        view.layer.borderWidth = self.width
    }
    
    //
    // Property setter
    //
    
    private mutating func setColor(valueString: String) {
        let colorSetting = valueString.components(separatedBy: ",")
        var alpha: CGFloat = 1
        guard let color = colorSetting.get(0) else {
            return
        }
        if let alphaString = colorSetting.get(1) {
            alpha = CGFloat(string: alphaString)
        }
        self.color = UIColor(hexString: color, alpha: CGFloat(alpha))
    }
    
    private mutating func setWidth(value: CGFloat) {
        self.width = value
    }
    
    private mutating func setCornerRadius(value: CGFloat) {
        self.roundCorner = value
    }
}
