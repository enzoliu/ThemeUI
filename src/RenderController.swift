//
//  RenderController.swift
//  ThemeUIOrigin
//
//  Created by EnzoLiu on 2017/5/4.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

public struct TransformConfig {
    weak var target: UIView?
    var styleID: String
    weak var theme: Theme?
    var animate: Bool
    
    public func render() {
        guard self.styleID.characters.count > 0 else {
            return
        }
        
        guard let styleCollection = self.theme?.getStyleCollection(ID: self.styleID) else {
            return
        }
        
        guard let view = self.target else {
            return
        }
        
        view.styleID = self.styleID
        styleCollection.setup(view: view, animate: self.animate)
    }
}

public class RenderController: ThemeDelegate {
    public static let shared: RenderController = RenderController()
    var viewStylingQueue: [TransformConfig] = []
    
    public func setStyle(target: UIView, styleID: String, theme: Theme, animate: Bool) {
        let config = TransformConfig(target: target, styleID: styleID, theme: theme, animate: animate)
        if theme.isLoaded {
            config.render()
        } else {
            self.viewStylingQueue.append(config)
        }
    }
    
    public func apply() {
        for config in viewStylingQueue {
            config.render()
        }
        self.viewStylingQueue = []
    }
    
    func didFinishedLoadConfig() {
        self.apply()
    }
}
