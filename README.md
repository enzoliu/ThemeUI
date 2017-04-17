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
Provide a `JSON` file in your project, like this:  
```JSON
{
    "Name" : "Orange",
    "Body" :
    {
        "Label" :
        [
            {
                "ID" : "LS01",
                "Style" :
                {
                    "Font.Color" : "414142, 1",
                    "Font.Size" : 13,
                    "Font.Family" : "Default",
                    "Font.Bold" : true
                }
            },
            {
                "ID" : "LS02",
                "Style" :
                {
                    "Font.Color" : "FB6D51, 1",
                    "Font.Size" : 13,
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
                    "BG.Color" : "FDE3D9, 0.7",
                    "Border.RoundConer" : 5,
                    "Border.Color" : "FB6D51, 1",
                    "Border.Width" : 0.5
                }
            }
        ],

        "Button" :
        [
            {
                "ID" : "BS01",
                "Style-Normal" :
                {
                    "BG.Color" : "FFFFFF, 0.5",
                    "Border.Color" : "FB6D51, 1",
                    "Border.Width" : 0.5,
                    "Border.RoundConer" : 5
                },
                "Style-Highlight" :
                {
                    "BG.Color" : "FB6D51, 1"
                }
            }
        ]
    }
}
```  
(You can find this demo JSON file in the resource folder.)  
**Please named this JSON file to `Theme.json`**  
And in your `ViewController`, you just need to set the `style ID` for each view, like :   
```swift
import ThemeUI

// you should use UIScrollViewDelegate here.
class ViewController: UIViewController, UIScrollViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.layout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func layout() {
        let bg = UIView(frame: CGRect(x: 20, y: 40, width: 200, height: 100))
        bg.setStyle(styleID: "VS01")
        
        let lb = UILabel(frame: CGRect(x: 20, y: 20, width: 160, height: 20))
        lb.text = "This is a test."
        lb.setStyle(styleID: "LS02")
        bg.addSubview(lb)
        
        let btn = UIButton(frame: CGRect(x: 60, y: lb.frame.maxY + 20, width: 80, height: 30))
        btn.setTitle("TestBTN", for: .normal)
        btn.setStyle(styleID: "BS01")
        bg.addSubview(btn)
        
        
        self.view.addSubview(bg)
        self.view.backgroundColor = UIColor.white
    }
}
```  
`Command + R` !  
You will see the result like this :  
<img src="http://i.imgur.com/Sv0UurB.png" />  

## Change log  
v0.1.0 - Initial release  

## License  
ThemeUI is available under the MIT license. See the LICENSE file for more info.
