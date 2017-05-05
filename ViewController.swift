//
//  ViewController.swift
//  ThemeUIExample
//
//  Created by EnzoLiu on 2017/5/5.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import UIKit
import ThemeUI

class ViewController: UIViewController {
    weak var lb: UILabel?
    weak var sv: UIView?
    var theme: Theme?
    var indicator:UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        indicator.startAnimating()
        
        self.loadTheme()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        container.center = self.view.center
        container.addSubview(indicator)
        indicator.center = CGPoint(x: 100, y: 100)
        
        self.view.addSubview(container)
        self.view.backgroundColor = UIColor.white
        self.indicator = indicator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadTheme() {
        let url = "https://firebasestorage.googleapis.com/v0/b/themeuidemo.appspot.com/o/Theme.json?alt=media&token=adbdcf70-8d11-44ec-a6f8-e1138dfff501"
        let theme = Theme()
        self.theme = theme
        theme.delegate = RenderController.shared
        
        // Load theme file from URL
        HTTPGet(url) { [unowned self] (data: Data?, errMsg: String?) -> Void in
            self.theme?.loadConfig(data)
            DispatchQueue.main.async {
                self.layout(theme)
                self.indicator?.stopAnimating()
            }
        }
    }
    
    func layout(_ theme: Theme) {
        
        let bg = UIView(frame: CGRect(x: 20, y: 40, width: 200, height: 100))
        self.sv = bg
        
        let lb = UILabel(frame: CGRect(x: 20, y: 20, width: 160, height: 20))
        lb.text = "This is a test."
        bg.addSubview(lb)
        self.lb = lb
        
        let btn = UIButton(frame: CGRect(x: 60, y: lb.frame.maxY + 20, width: 80, height: 30))
        btn.setTitle("TestBTN", for: .normal)
        btn.addTarget(self, action: #selector(self.changeStyle(sender:)), for: .touchUpInside)
        bg.addSubview(btn)
        
        RenderController.shared.setStyle(target: bg, styleID: "VS01", theme: theme, animate: true)
        RenderController.shared.setStyle(target: lb, styleID: "LS01", theme: theme, animate: true)
        RenderController.shared.setStyle(target: btn, styleID: "BS01", theme: theme, animate: true)
        
        self.view.addSubview(bg)
        self.view.backgroundColor = UIColor.white
    }
    
    func changeStyle(sender: UIButton) {
        guard let theme = self.theme,
            let lb = self.lb,
            let sv = self.sv else {
                return
        }
        
        let lbStyle = (lb.styleID == "LS01") ? "LS02" : "LS01"
        RenderController.shared.setStyle(target: lb, styleID: lbStyle, theme: theme, animate: true)
        
        let vStyle = (sv.styleID == "VS01") ? "VS02" : "VS01"
        RenderController.shared.setStyle(target: sv, styleID: vStyle, theme: theme, animate: true)
    }
}

