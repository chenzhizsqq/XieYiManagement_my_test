//
//  DailyTaskViewController.swift
//  XieYi
//
//  Created by 写易 on 2021/01/27.
//

import Foundation
import UIKit

class DailyTaskViewController: UIViewController {
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDatePicker.tintColor = UIColor.systemIndigo
        startDatePicker.minimumDate = .init(timeIntervalSinceNow: 0)
        
        endDatePicker.tintColor = UIColor.systemIndigo
        endDatePicker.minimumDate = .init(timeIntervalSinceNow: 0)
    }
    
    @IBAction func addBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
}
