//
//  ExViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/12/04.
//

import Foundation
import UIKit

class ExMainViewController: UIViewController {
    var dataArray = Array<Dictionary<String, Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isLogin() {
            
        } else {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
}
