//
//  Theme.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/4/14.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static let sharedInstance = Theme()
    var viewStyle: [String: Style] = [:]
    var name: String = ""
    
    init() {
        self.loadConfig()
    }
    
    func loadConfig() {
        if let file = Bundle.main.path(forResource: "Theme", ofType: "json") {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe) else {
                print("Cannot open theme file.")
                return
            }
            
            var jsonSerial: Any?
            
            do {
                jsonSerial = try JSONSerialization.jsonObject(with: data)
            } catch {
                print(error)
            }
            
            guard let json = jsonSerial as? [String: Any] else {
                print("Incorrect format in theme file.")
                return
            }
            
            guard let themeName = json["Name"] as? String else {
                print("Incorrect format in theme file.")
                return
            }
            
            guard let styles = json["Body"] as? [String: Any] else {
                print("Incorrect format in theme file.")
                return
            }
            
            self.setupLabelStyle(styles)
            
            self.setupViewStyle(styles)
            
            self.setupButtonStyle(styles)
            
            self.name = themeName
        }
    }
    
    func getStyle(ID: String) -> Style? {
        return self.viewStyle[ID]
    }
    
    //
    // MARK:- Setup function for each defined view object.
    //
    
    private func setupLabelStyle(_ styles: [String: Any]) {
        if let labelStyles = styles["Label"] as? [[String: Any]] {
            for style in labelStyles {
                guard let styleName = style["ID"] as? String else {
                    continue
                }
                guard let properties = style["Style"] as? [String: Any] else {
                    continue
                }
                
                let fontStyle = Font(propSet: properties)
                let borderStyle = Border(propSet: properties)
                let bgStyle = Background(propSet: properties)
                
                var styleConfig = Style()
                styleConfig.name = styleName
                styleConfig.styles = [ HashableControlState.normal : [fontStyle, bgStyle, borderStyle]]
                self.viewStyle[styleName] = styleConfig
            }
        }
    }
    
    private func setupViewStyle(_ styles: [String: Any]) {
        if let viewStyles = styles["View"] as? [[String: Any]] {
            for style in viewStyles {
                guard let styleName = style["ID"] as? String else {
                    continue
                }
                guard let properties = style["Style"] as? [String: Any] else {
                    continue
                }
                
                let bgStyle = Background(propSet: properties)
                let borderStyle = Border(propSet: properties)
                
                var styleConfig = Style()
                styleConfig.name = styleName
                styleConfig.styles = [ HashableControlState.normal : [bgStyle, borderStyle]]
                self.viewStyle[styleName] = styleConfig
            }
        }
    }
    
    private func setupButtonStyle(_ styles: [String: Any]) {
        if let btnStyle = styles["Button"] as? [[String: Any]] {
            for style in btnStyle {
                guard let styleName = style["ID"] as? String else {
                    continue
                }
                var styleConfig = Style()
                styleConfig.name = styleName
                
                if let propertiesNormal = style["Style-Normal"] as? [String: Any] {
                    let fontStyle = Font(propSet: propertiesNormal)
                    let borderStyle = Border(propSet: propertiesNormal)
                    let bgStyle = Background(propSet: propertiesNormal)
                    
                    styleConfig.styles = [ HashableControlState.normal : [fontStyle, bgStyle, borderStyle]]
                }
                
                if let propertiesHighlight = style["Style-Highlight"] as? [String: Any] {
                    let fontStyle = Font(propSet: propertiesHighlight)
                    let borderStyle = Border(propSet: propertiesHighlight)
                    let bgStyle = Background(propSet: propertiesHighlight)
                    
                    styleConfig.styles[HashableControlState.highlighted] = [fontStyle, bgStyle, borderStyle]
                }
                
                self.viewStyle[styleName] = styleConfig
            }
        }
    }
}
