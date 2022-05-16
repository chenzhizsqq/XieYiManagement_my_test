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
    
    // 緯度
    var latitudeN: String = ""
    // 経度
    var longitudeN: String = ""
    // 地址管理
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocationManager()
        
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
    
    // MARK: - LocationManager
    /// ロケーションマネージャのセットアップ
    func setupLocationManager() {
        locationManager = CLLocationManager()
        // 権限をリクエスト
        guard let locationManager = locationManager else { return }
        locationManager.delegate = self
    }
    
    /// "位置情報を取得際、位置情報をラベルに反映する
    /// - Parameter sender: "位置情報を取得"ボタン
    func getLocationInfo() {
        // マネージャの設定
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            print("ERROR")
        } else if status == .authorizedWhenInUse {
            print(latitudeN, longitudeN)
        }
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

// MARK: - Extension
extension LoginViewController {
    /// 位置情報が更新された際、位置情報を格納する
    /// - Parameters:
    ///   - manager: ロケーションマネージャ
    ///   - locations: 位置情報
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        // 位置情報を格納する
        latitudeN = String(latitude!)
        longitudeN = String(longitude!)
    }
    
    /// 位置情報の許可のステータス変更で呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization status=\(status)")
        switch status {
        case .authorizedAlways:
            // 位置情報取得を開始
            manager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            // 位置情報取得を開始
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            break
        case .restricted:
            manager.requestAlwaysAuthorization()
            break
        case .denied:
            manager.requestAlwaysAuthorization()
            break
        default:
            break
        }
    }
}
