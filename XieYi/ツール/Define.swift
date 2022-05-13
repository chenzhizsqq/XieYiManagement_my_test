//
//  Define.swift
//  XieYi
//
//  Created by 写易 on 2020/11/06.
//

import Foundation
import UIKit

let path = Bundle.main.path(forResource: "CustomProperty", ofType: "plist")!
let properties: NSDictionary = NSDictionary(contentsOfFile: path)!

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let BaseURL = (properties["BaseURL"] as? String)!

//#if DEBUG
////let BaseURL = (properties["TestURL"] as? String)!
//let BaseURL = (properties["BaseURL"] as? String)!
//#elseif RELEASE
//let BaseURL = (properties["BaseURL"] as? String)!
//#endif
