//
//  LoginViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/10/16.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.CustomUI()
    }
    
    func CustomUI() {
        nameTextfield.delegate = self
        passwordTextfield.delegate = self
        
        loginBtn.layer.cornerRadius = 6.0
        loginBtn.layer.masksToBounds = true
        loginBtn.layer.borderColor = UIColor.lightGray.cgColor
        loginBtn.layer.borderWidth = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextfield {
            passwordTextfield.becomeFirstResponder()
        } else {
            passwordTextfield.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - 登录按钮点击事件
    @IBAction func loginBtnClick(_ sender: UIButton) {
        
        let uid = nameTextfield.text
        let password = passwordTextfield.text
        
        struct Login: Encodable {
            let app: String
            let uid: String
            let password: String
            let device: String
        }
        
//        let para = Login(app: "EtOfficeLogin", uid: "demo1@xieyi.co.jp", password: "root", device: "iOS")
                let para = Login(app: "EtOfficeLogin", uid: uid!, password: password!, device: "iOS")
        
        if uid!.count > 0 && password!.count > 0 {
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        if saveUserInfoFunc(jsonString: jsonData) {
                            print("token = " + getTokenFunc())
//                            let alertController = UIAlertController(title: NSLocalizedString("MSG02", comment: "ログイン成功"),message: nil, preferredStyle: .alert)
//                            self.present(alertController, animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                self.dismiss(animated: true) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else {
                            
                        }
                    } else {
                        Util.showAlert(currentVC: self, msgKey: "MSG01")
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        } else {
            Util.showAlert(currentVC: self, msgKey: "MSG01")
        }
    }
}
