//
//  Style.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/4/13.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

private var styleIDAssociationKey: UInt8 = 0

extension UIView {
    /// Style ID for UIView.
    public var styleID: String {
        get {
            return objc_getAssociatedObject(self, &styleIDAssociationKey) as? String ?? ""
        }
        set(newValue) {
            objc_setAssociatedObject(self, &styleIDAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Set style ID for the UIView object.
    ///
    /// - Parameters:
    ///   - styleID: Identifier for styles.
    func setStyle(styleID: String) {
        self.styleID = styleID
    }
}

private var btnNormalFontKey: UInt8 = 0
private var btnHighlightFontKey: UInt8 = 0
extension UIButton {
    public var normalFont: UIFont {
        get {
            return objc_getAssociatedObject(self, &btnNormalFontKey) as? UIFont ?? UIFont.systemFont(ofSize: 12)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &btnNormalFontKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var highlightFont: UIFont {
        get {
            return objc_getAssociatedObject(self, &btnHighlightFontKey) as? UIFont ?? UIFont.systemFont(ofSize: 12)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &btnHighlightFontKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override var isHighlighted: Bool{
        didSet {
            if isHighlighted {
                self.titleLabel?.font = highlightFont
            } else {
                self.titleLabel?.font = normalFont
            }
        }
    }
    
    
    /// Set the font for differernt states. Because 'state' is not KVO compliant, so we choose isHighlighted to observe. Thus, this method do not support the other flag of UIControlState.
    ///
    /// - Parameters:
    ///   - font: UIFont, you can set font family, font size, ... etc.
    ///   - state: UIControlState, only support .normal & .highlight. See the description above.
    func setFont(font: UIFont, for state: UIControlState) {
        switch state {
        case UIControlState.highlighted:
            self.highlightFont = font
        default:
            self.normalFont = font
        }
    }
}

struct StyleCollection {
    var name: String
    var styles: [HashableControlState: [StyleProperty]]
    
    init() {
        name = ""
        styles = [:]
    }
    
    func setup(view: UIView, animate: Bool = true) {
        DispatchQueue.main.async {
            for key in self.styles.keys {
                guard let styles = self.styles[key] else {
                    continue
                }
                let state = key.toControlState()
                
                self.applyStyle(withAnimation: animate, inView: view, for: state, styles: styles)
            }
        }
    }
    
    private func applyStyle(withAnimation: Bool, inView view: UIView, for state: UIControlState, styles: [StyleProperty]) {
        guard withAnimation else {
            for style in styles {
                style.apply(view: view, for: state)
            }
            return
        }
        
        let transStyle = styles.filter { x in return x is Font }
        let viewStyle = styles.filter { x in return x is Background }
        let borderStyle = styles.filter { x in return x is Border }        // Border animation wont work here.
        
        if transStyle.count > 0 {
            UIView.transition(with: view, duration: 0.3, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                for style in transStyle {
                    style.apply(view: view, for: state)
                }
            }, completion: nil)
        }
        
        if viewStyle.count > 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                for style in viewStyle {
                    style.apply(view: view, for: state)
                }
            }, completion: nil)
        }
        
        if borderStyle.count > 0 {
            for style in borderStyle {
                style.apply(view: view, for: state)
            }
        }
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
    var family: String          = "default"
    var size: CGFloat           = 12
    var color: UIColor          = UIColor.black
    var bold: Bool              = false                             // Only work for system font
    var font: UIFont            = UIFont.systemFont(ofSize: 12)
    
    init(propSet: [String: Any]) {
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "font" }
        for key in keys {
            switch key.lowercased() {
            case "font.color":
                guard let value = propSet[key] as? String else { break }
                self.setColor(valueString: value)
                
            case "font.size" :
                guard let value = propSet[key] as? CGFloat else { break }
                self.setSize(value)
                
            case "font.family" :
                guard let value = propSet[key] as? String else { break }
                self.setFamily(value)
                
            case "font.bold" :
                guard let value = propSet[key] as? Bool else { break }
                self.setBold(value)
                
            default:
                break
            }
        }
        
        if self.family.lowercased() == "default" {
            self.font = self.bold ? UIFont.boldSystemFont(ofSize: self.size) : UIFont.systemFont(ofSize: self.size)
        } else if let font = UIFont(name: self.family, size: self.size) {
            self.font = font
        }
    }
    
    func apply(view: UIView, for state: UIControlState = UIControlState.normal) {
        if view is UILabel || view is UITextView || view is UITextField {
            view.setValue(self.font, forKey: "font")
            view.setValue(self.color, forKey: "textColor")
        } else if let btn = view as? UIButton {
            btn.setFont(font: self.font, for: state)
            btn.setTitleColor(self.color, for: state)
            
            // to fire font setting.
            btn.isHighlighted = false
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
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "bg" }
        for key in keys {
            switch key.lowercased() {
            case "bg.color":
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
        let keys = propSet.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "border" }
        for key in keys {
            switch key.lowercased() {
            case "border.color":
                guard let value = propSet[key] as? String else { break }
                self.setColor(valueString: value)
                
            case "border.width":
                guard let value = propSet[key] as? CGFloat else { break }
                self.setWidth(value: value)
                
            case "border.roundcorner":
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
