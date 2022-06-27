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
    
//    @IBOutlet weak var latLabel: UILabel!
//    @IBOutlet weak var lonLabel: UILabel!
//    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    //@IBOutlet weak var registerAreaBtn: UIButton!
    @IBOutlet weak var Picker: UIDatePicker!
    @IBOutlet weak var checkBoxBtn: CheckBox!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var toSetGpsBtn: UIButton!
    
    // 緯度
    var latitudeN: String = "0"
    // 経度
    var longitudeN: String = "0"
    // ロケーションマネージャ
    var locationManager: CLLocationManager!
    // 别名
    var alias: String = ""
    var locationArray = Array<Dictionary<String, Any>>()
    
    // 位置情報設定有効、無効フラグ
    var gpsEnable = false
    
    var currentStatusValue: String = ""
    var currentStatusText: String = ""
    var code: Int = 0
    var currentArea: String?
    var memo: String = ""
    var area: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        
        CustomUI()
    }
    
    func CustomUI() {
        checkInBtn.layer.cornerRadius = 188 / 2.0
        cancelBtn.layer.cornerRadius = 18.0
        updateBtn.layer.cornerRadius = 18.0
        //registerAreaBtn.layer.cornerRadius = 18.0
        noteTextField.delegate = self
        areaTextField.delegate = self
        //noteTextField.placeholder = "aaa"
        
//        latLabel.text = String(String(format: "%.6f", latitudeN))
//        lonLabel.text = String(String(format: "%.6f", longitudeN))
        currentArea = isInArea(lat: Double(String(format: "%.6f", latitudeN)) ?? 0.0, lon: Double(String(format: "%.6f", longitudeN)) ?? 0.0)
//        locationLabel.text = currentArea
        
        checkBoxBtn.isEnabled = false
        gpsLabel.isHidden = true
        // デフォルト日付
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let modifiedDate = Calendar.current.date(byAdding: .minute, value: 14, to: currentDate)!
        Picker.date = modifiedDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(code)
        //checkInBtn.setTitle(codeToString(code: code), for: .normal)
        checkInBtn.setTitle(currentStatusText, for: .normal)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func refreshGpsIndicator() {
        if gpsEnable {
            gpsLabel.isHidden = false
            gpsLabel.text = NSLocalizedString("ADD_ON", comment: "")
            toSetGpsBtn.isHidden = true
        } else {
            gpsLabel.isHidden = false
            checkBoxLabel.isHidden = true
            checkBoxBtn.isHidden = true
            gpsLabel.text = NSLocalizedString("ADD_OFF", comment: "")
            toSetGpsBtn.isHidden = false
        }
    }
    
    @IBAction func checkInBtnClick(_ sender: UIButton) {
        noteTextField.resignFirstResponder()
        areaTextField.resignFirstResponder()
        
        confirmStatusRequest()
        
        if !checkBoxBtn.isHidden && checkBoxBtn.isChecked {
            uploadAreaRequest()
        }
        
        print("!!! Picker :\(Picker.date)")
    }
    
    @IBAction func gotoSettingBtnClick(_ sender: UIButton) {
        try? UIApplication.shared.open(UIApplication.openSettingsURLString.asURL())
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == areaTextField {
            if textField.text?.count ?? 0 > 0 {
                checkBoxBtn.isEnabled = true
                gpsLabel.isHidden = false
            } else {
                checkBoxBtn.isEnabled = false
                gpsLabel.isHidden = true
            }
        }
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
                let statustime: String
                let longitude: String
                let latitude: String
                let location: String
                let memo: String
            }
            
            var updateStatusValue = ""
            switch code {
            case 1:
                // 勤務開始
                updateStatusValue = "1"
            case 2:
                // 休憩開始の場合、休憩終了に更新
                if currentStatusValue == "3" {
                    updateStatusValue = "4"
                }
                // 休憩開始に更新
                else {
                    updateStatusValue = "3"
                }
            case 3:
                // 会議開始の場合、会議終了に更新
                if currentStatusValue == "5" {
                    updateStatusValue = "6"
                }
                // 会議開始に更新
                else {
                    updateStatusValue = "5"
                }
            case 4:
                // 移動開始の場合、移動終了に更新
                if currentStatusValue == "7" {
                    updateStatusValue = "8"
                }
                // 移動開始に更新
                else {
                    updateStatusValue = "7"
                }
            case 5:
                // 勤務終了
                updateStatusValue = "2"
            default:
                updateStatusValue = ""
            }
            
            let date = Picker.date
            let statustime = DateUtils.stringFromDate(date: date, format: "yyyyMMddHHmm")
            
            let para = Parameter(
                app: "EtOfficeSetUserStatus",
                token: getTokenFunc(),
                tenant: getTenantidFunc(),
                hpid: getHpidFunc(),
                device: "iOS",
                statusvalue: updateStatusValue,
                statustext: "",
                statustime: statustime,
                longitude: String(format: "%.6f", Float(longitudeN)!),
                latitude: String(format: "%.6f", Float(latitudeN)!),
                location: currentArea ?? "",
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
        
//        latLabel.text = String(String(format: "%.6f", latitude!))
//        lonLabel.text = String(String(format: "%.6f", longitude!))
        currentArea = isInArea(lat: Double(String(format: "%.6f", latitude!)) ?? 0.0, lon: Double(String(format: "%.6f", longitude!)) ?? 0.0)
//        locationLabel.text = currentArea
        
        if currentArea != nil {
            areaTextField.text = currentArea!
            areaTextField.isEnabled = false
            checkBoxBtn.isHidden = true
            checkBoxLabel.isHidden = true
            gpsLabel.isHidden = false
            gpsLabel.text = NSLocalizedString("ADD_REGISTERED", comment: "")
            toSetGpsBtn.isHidden = true
        } else {
            areaTextField.isEnabled = true
            checkBoxBtn.isHidden = false
            checkBoxLabel.isHidden = false
        }
    }
    
    /// 位置情報の許可のステータス変更で呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization status=\(status)")
        gpsEnable = false
        switch status {
        case .authorizedAlways:
            gpsEnable = true
            // 位置情報取得を開始
            manager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            gpsEnable = true
            // 位置情報取得を開始
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .restricted:
            manager.requestWhenInUseAuthorization()
            break
        case .denied:
            manager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
        
        self.refreshGpsIndicator()
    }
}
