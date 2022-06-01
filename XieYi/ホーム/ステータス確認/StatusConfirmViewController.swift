//
//  StatusConfirmViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/11/25.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class StatusConfirmViewController: ExSubViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var registerAreaBtn: UIButton!
    @IBOutlet weak var Picker: UIDatePicker!
    
    // 緯度
    var latitudeN: String = "0"
    // 経度
    var longitudeN: String = "0"
    // ロケーションマネージャ
    var locationManager: CLLocationManager!
    // 别名
    var alias: String = ""
    var locationArray = Array<Dictionary<String, Any>>()
    
    var code: Int = 0
    var currentArea: String = ""
    var memo: String = ""
    var area: String = ""
    
    ///选中了哪个页
    var selectOption = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        
        CustomUI()
    }
    
    func CustomUI() {
        checkInBtn.layer.cornerRadius = 188 / 2.0
        cancelBtn.layer.cornerRadius = 18.0
        updateBtn.layer.cornerRadius = 18.0
        registerAreaBtn.layer.cornerRadius = 18.0
        noteTextField.delegate = self
        areaTextField.delegate = self
        
        latLabel.text = String(String(format: "%.6f", latitudeN))
        lonLabel.text = String(String(format: "%.6f", longitudeN))
        currentArea = isInArea(lat: Double(String(format: "%.6f", latitudeN)) ?? 0.0, lon: Double(String(format: "%.6f", longitudeN)) ?? 0.0)
        locationLabel.text = currentArea
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(code)
        checkInBtn.setTitle(codeToString(code: code), for: .normal)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //["勤務開始", "休憩開始", "勤務終了", "移動開始", "会議開始"]
    func codeToString(code: Int) -> String {
        if code == 1 {
            //return "勤務中"
            return "勤務開始"
        } else if code == 2 {
            //return "勤務外"
            //"休憩開始" "休憩終了"
            if(selectOption != 2){
                return "休憩開始"
            }else{
                return "休憩終了"
            }
        } else if code == 3 {
            //return "休憩中"
            //会議開始 会議終了
            if(selectOption != 3){
                return "会議開始"
            }else{
                return "会議終了"
            }
        } else if code == 4 {
            //return "移動中"
            //"移動開始" "移動終了"
            if(selectOption != 4){
                return "移動開始"
            }else{
                return "移動終了"
            }
        } else if code == 5 {
            //return "会議中"
            return "勤務終了"
        }
        return ""
    }
    
    @IBAction func checkInBtnClick(_ sender: UIButton) {
        noteTextField.resignFirstResponder()
        areaTextField.resignFirstResponder()
        confirmStatusRequest()
        
        uploadAreaRequest()
        
        print("!!! Picker :\(Picker.date)")
    }
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    
    @IBAction func registerAreaBtnClick(_ sender: UIButton) {
        noteTextField.resignFirstResponder()
        areaTextField.resignFirstResponder()
        
        if self.area.count == 0 {
            Util.showAlert(currentVC: self, msgKey: "MSG11")
        }
        
        uploadAreaRequest()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == noteTextField {
            memo = noteTextField.text ?? ""
            print(memo)
        }
        else if textField == areaTextField {
            area = areaTextField.text ?? ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTextField {
            noteTextField.resignFirstResponder()
        }
        else if textField == areaTextField {
            areaTextField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - 确认状态请求
    func confirmStatusRequest() {
        if getTokenFunc().count != 0 {
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let statusvalue: String
                let statustext: String
                let longitude: String
                let latitude: String
                let location: String
                let memo: String
            }
            
            let para = Parameter(
                app: "EtOfficeSetUserStatus",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                statusvalue: String(code),
                statustext: codeToString(code: code),
                longitude: String(format: "%.6f", Float(longitudeN)!),
                latitude: String(format: "%.6f", Float(latitudeN)!),
                location: currentArea,
                memo: memo
            )
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserSetStatus"), object: nil)
                        
                        if(self.selectOption == self.code){
                            self.selectOption = 0
                        }else{
                            self.selectOption = self.code
                        }
                        NotificationCenter.default.post(name: .selectOptionName, object: nil, userInfo: ["selectOption": self.selectOption ])

                        NotificationCenter.default.removeObserver(self)
                    } else {
                        Util.showMessageAlert(currentVC: self, msg: jsonData["message"].object as! String)
                        print(jsonData["message"].object as! String)
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    //MARK: - LocationManager
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
    
    //MARK: - 地名ロケーション登録
    func uploadAreaRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let longitude : String
                let latitude : String
                let location : String
            }
            
            let para = Parameter(app: "EtOfficeSetUserLocation", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", longitude: String(format: "%.6f", Float(longitudeN)!), latitude: String(format: "%.6f", Float(latitudeN)!), location: String(area))
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].intValue == 0) {
                    if (jsonData["result"].count != 0) {
                        self.locationArray = jsonData["result"]["locationlist"].object as! Array
                        UserDefaults.standard.setValue(self.locationArray, forKey: "LOCATIONLIST")
                    }
                    
                } else {
                    let message = jsonData["message"].string
                    let alertController = UIAlertController(title: message,message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
}

//MARK: - Extension
extension StatusConfirmViewController {
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
        
        latLabel.text = String(String(format: "%.6f", latitude!))
        lonLabel.text = String(String(format: "%.6f", longitude!))
        currentArea = isInArea(lat: Double(String(format: "%.6f", latitude!)) ?? 0.0, lon: Double(String(format: "%.6f", longitude!)) ?? 0.0)
        locationLabel.text = currentArea
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
