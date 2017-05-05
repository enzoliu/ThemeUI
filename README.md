# ThemeUI

[![Version](https://img.shields.io/cocoapods/v/ThemeUI.svg?style=flat)](http://cocoapods.org/pods/ThemeUI)
[![License](https://img.shields.io/cocoapods/l/ThemeUI.svg?style=flat)](http://cocoapods.org/pods/ThemeUI)
[![Platform](https://img.shields.io/cocoapods/p/ThemeUI.svg?style=flat)](http://cocoapods.org/pods/ThemeUI)

**A JSON based UI style setting for iOS.**

## Requirements
## Installation

ThemeUI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
pod 'ThemeUI'
```

  
## Usage
**Swift 3**
There are different way to provide your Theme file.  
1. Local json file. (Name it to `Theme.json`)  
2. Json file from internet.  
3. Or just json string.  

Provide a `JSON` file in your project, like this:  
```JSON
{
    "Name" : "Orange",
    "Define" :
    [
        {
            "Name" : "White1",
            "Value" : "FFFFFF, 1"
        },
        {
            "Name" : "Black2",
            "Value" : "222222, 0.7"
        },
        {
            "Name" : "Orange1",
            "Value" : "FB6D51, 1"
        },
        {
            "Name" : "Orange2",
            "Value" : "FDE3D9, 0.7"
        },
        {
            "Name" : "Small",
            "Value" : 10.0
        },
        {
            "Name" : "Medium",
            "Value" : 13.0
        },
        {
            "Name" : "Large",
            "Value" : 20.0
        }
    ],
    "Body" :
    {
        "Label" :
        [
            {
                "ID" : "LS01",
                "Style" :
                {
                    "Font.Color" : "White1",
                    "Font.Size" : "Large",
                    "Font.Family" : "Default",
                    "Font.Bold" : true
                }
            },
            {
                "ID" : "LS02",
                "Style" :
                {
                    "Font.Color" : "Orange1",
                    "Font.Size" : "Medium",
                    "Font.Family" : "Default"
                }
            }
        ],

        "View" :
        [
            {
                "ID" : "VS01",
                "Style" :
                {
                    "BG.Color" : "Orange2",
                    "Border.RoundCorner" : 5,
                    "Border.Color" : "Orange1",
                    "Border.Width" : 0.5
                }
            },
            {
                 "ID" : "VS02",
                 "Style" :
                 {
                     "BG.Color" : "White1",
                     "Border.Color" : "000000, 1",
                     "Border.Width" : 0.5,
                     "Border.RoundCorner" : 0
                 }
            }
        ],

        "Button" :
        [
            {
                "ID" : "BS01",
                "Style-Normal" :
                {
                    "BG.Color" : "Orange1",
                    "Border.Color" : "FFFFFF, 1",
                    "Border.Width" : 0.5,
                    "Border.RoundCorner" : 5,
                    "Font.Size" : "Small",
                    "Font.Color" : "Black2"
                },
                "Style-Highlight" :
                {
                    "BG.Color" : "Orange2",
                    "Font.Size" : "Large",
                    "Font.Color" : "White1"
                }
            }
        ]
    }
}
```
(You can find this demo JSON file in the resource folder.)  
And in your `ViewController`, you need to : 
1. Init `Theme` object.
2. Set `RenderController` as it's delegate.  
3. Load theme json from your site / local.  
4. Set `style ID` for each view.  

For example :   
```swift
import ThemeUI

// you should use UIScrollViewDelegate here.
class ViewController: UIViewController, UIScrollViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTheme() -> Theme {
        let url = "YOUR_THEME_JSON_URL"
        let theme = Theme()
        self.theme = theme
        
        // !!IMPORTANT!! 
        // Set render controller as the theme's delegate.
        theme.delegate = RenderController.shared
        
        // Load theme file from URL.
        
        // !!IMPORTANT!! 
        // Replace this method to your HTTP request method.
        HTTPGet(url) { [unowned self] (data: Data?, errMsg: String?) -> Void in
            self.theme?.loadConfig(data)
            DispatchQueue.main.async {
                self.layout(theme)
            }
        }
        return theme
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
}
```
**Note :**
1. Replace `YOUR_THEME_JSON_URL` to your theme json URL.  
2. Replace `HTTPGet` to your HTTP request method.  
3. Please don't forget set the render controller as the theme's delegate.  

`Command + R` !  
You will see the result like this :  
![image](https://github.com/enzoliu/ThemeUI/tree/master/resources/ThemeUI.gif) 

## Change log
v0.1.0 - Initial release  
v0.2.0 - Support download theme from internet.    

## License

ThemeUI is available under the MIT license. See the LICENSE file for more info.
