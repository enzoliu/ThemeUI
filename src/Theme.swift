//
//  Theme.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/4/14.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

protocol ThemeDelegate: class {
    func didFinishedLoadConfig()
}

class Theme {
    var viewStyle: [String: StyleCollection]    = [:]
    var defined: [String: Any]                  = [:]
    var name: String                            = ""
    var delegate: ThemeDelegate?                = nil
    var isLoaded: Bool                          = false
    
    init() {
    }
    
    init(jsonString: String) {
        self.loadConfig(jsonString)
    }
    
    init(data: Data) {
        self.loadConfig(data)
    }
    
    func loadConfig(_ jsonString: String? = nil) {
        var data = jsonString?.data(using: .utf8)
        if data == nil {
            if let file = Bundle.main.path(forResource: "Theme", ofType: "json") {
                data = try? Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe)
            }
        }
        self.loadConfig(data)
    }
    
    func loadConfig(_ data: Data?) {
        var jsonSerial: Any?
        
        guard let jsonData = data else {
            print("Load theme failed.")
            return
        }
        
        do {
            jsonSerial = try JSONSerialization.jsonObject(with: jsonData)
        } catch {
            print(error)
        }
        
        guard let json = jsonSerial as? [String: Any] else {
            print("Incorrect format.")
            return
        }
        
        guard let themeName = json["Name"] as? String else {
            print("Incorrect format.")
            return
        }
        
        guard let styles = json["Body"] as? [String: Any] else {
            print("Incorrect format.")
            return
        }
        
        self.setupDefinition(json)
        
        self.setupLabelStyle(styles)
        
        self.setupViewStyle(styles)
        
        self.setupButtonStyle(styles)
        
        self.name = themeName
        
        self.isLoaded = true
        
        self.delegate?.didFinishedLoadConfig()
    }
    
    func getStyleCollection(ID: String) -> StyleCollection? {
        return self.viewStyle[ID]
    }
    
    //
    // MARK:- Initialize style definition. The value type now support Int, CGFloat, String.
    //
    private func setupDefinition(_ json: [String: Any]) {
        if let definitions = json["Define"] as? [[String: Any]] {
            self.defined = [:]
            for dict in definitions {
                guard let name = dict["Name"] as? String else {
                    continue
                }
                
                if !self.defined.keys.contains(name) {
                    if let value = dict["Value"] as? CGFloat {
                        self.defined[name] = value
                    } else if let value = dict["Value"] as? String {
                        self.defined[name] = value
                    }
                } else {
                    print("Defined name [\(name)] cannot define again.")
                }
            }
        }
    }
    
    private func propertiesValueMapping(properties: [String: Any]) -> [String: Any] {
        guard self.defined.count > 0 else {
            return properties
        }
        
        var replacedProp: [String: Any] = [:]
        for property in properties {
            guard let val = property.value as? String else {
                replacedProp[property.key] = property.value
                continue
            }
            if self.defined.keys.contains(val) {
                replacedProp[property.key] = self.defined[val]
            } else {
                replacedProp[property.key] = property.value
            }
        }
        return replacedProp
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
                
                var styleCollectionConfig = StyleCollection()
                styleCollectionConfig.name = styleName
                styleCollectionConfig.styles[HashableControlState.normal] = fetchStyleProperties(properties)
                self.viewStyle[styleName] = styleCollectionConfig
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
                
                var styleCollectionConfig = StyleCollection()
                styleCollectionConfig.name = styleName
                styleCollectionConfig.styles[HashableControlState.normal] = fetchStyleProperties(properties)
                self.viewStyle[styleName] = styleCollectionConfig
            }
        }
    }
    
    private func setupButtonStyle(_ styles: [String: Any]) {
        if let btnStyle = styles["Button"] as? [[String: Any]] {
            for style in btnStyle {
                guard let styleName = style["ID"] as? String else {
                    continue
                }
                var styleCollectionConfig = StyleCollection()
                styleCollectionConfig.name = styleName
                
                if let propertiesNormal = style["Style-Normal"] as? [String: Any] {
                    styleCollectionConfig.styles[HashableControlState.normal] = fetchStyleProperties(propertiesNormal)
                }
                
                if let propertiesHighlight = style["Style-Highlight"] as? [String: Any] {
                    styleCollectionConfig.styles[HashableControlState.highlighted] = fetchStyleProperties(propertiesHighlight)
                }
                
                self.viewStyle[styleName] = styleCollectionConfig
            }
        }
    }
    
    private func fetchStyleProperties(_ styles: [String: Any]) -> [StyleProperty] {
        let mappedProperties = self.propertiesValueMapping(properties: styles)
        let fontProp = mappedProperties.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "font" }
        let borderProp = mappedProperties.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "border" }
        let bgProp = mappedProperties.keys.filter{ x in x.components(separatedBy: ".").get(0)?.lowercased() == "bg" }
        var styleProperties: [StyleProperty] = []
        
        if fontProp.count > 0 {
            let style = Font(propSet: mappedProperties)
            styleProperties.append(style)
        }
        
        if borderProp.count > 0 {
            let style = Border(propSet: mappedProperties)
            styleProperties.append(style)
        }
        
        if bgProp.count > 0 {
            let style = Background(propSet: mappedProperties)
            styleProperties.append(style)
        }
        
        return styleProperties
    }
}
