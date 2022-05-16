//
//  LocationViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/11/13.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class LocationViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    // 「データがありません」を表示
    @IBOutlet weak var tipsLabel: UILabel!
    
    // 緯度
    var latitudeN: String = "0"
    // 経度
    var longitudeN: String = "0"
    // ロケーションマネージャ
    var locationManager: CLLocationManager!
    // 别名
    var alias: String = ""
    
    var dataArray = Array<Dictionary<String, Any>>()
    
    override func viewDidLoad() {
        tipsLabel.isHidden = true
        CustomUI()
        setupLocationManager()
        getLocationListRequest()
    }
    
    func CustomUI() {
        table.delegate = self
        table.dataSource = self
        table.register(UINib.init(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func RightBtnClick(_ sender: UIBarButtonItem) {
        getLocationInfo()
    }
    
    // MARK: - 获取地址信息列表请求
    func getLocationListRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeGetUserLocation", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                print(response)
                let jsonData = JSON(response.data as Any)
                if (jsonData["status"].intValue == 0) {
                    if (jsonData["result"].count != 0) {
                        self.dataArray = jsonData["result"]["locationlist"].object as! Array
                        
                        UserDefaults.standard.setValue(self.dataArray, forKey: "LOCATIONLIST")
                        
                        self.table.reloadData()
                        
                        //「データがありません」を表示
                        if (self.dataArray.isEmpty){
                            self.tipsLabel.isHidden = false
                        }else{
                            self.tipsLabel.isHidden = true
                        }
                    }
                } else {
                    
                }
            })
        }
    }
    
    //MARK: - 上传别名请求
    func uploadAlistRequest() {
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
            
            let para = Parameter(app: "EtOfficeSetUserLocation", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", longitude: String(format: "%.6f", Float(longitudeN)!), latitude: String(format: "%.6f", Float(latitudeN)!), location: String(alias))
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].intValue == 0) {
                    if (jsonData["result"].count != 0) {
                        self.dataArray = jsonData["result"]["locationlist"].object as! Array
                        
                        UserDefaults.standard.setValue(self.dataArray, forKey: "LOCATIONLIST")
                        
                        self.table.reloadData()
                    }
                    
                } else {
                    let message = jsonData["message"].string
                    let alertController = UIAlertController(title: message,message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.dismiss(animated: true) {}
                    }
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
    
    /// "位置情報を取得"ボタンを押下した際、位置情報をラベルに反映する
    /// - Parameter sender: "位置情報を取得"ボタン
    func getLocationInfo() {
        // マネージャの設定
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            print(latitudeN, longitudeN)
            locationHandler()
        }
        else  {
            print("ERROR")
        }
    }
    
    //MARK: - 坐标判断处理
    func locationHandler() {
        if latitudeN.count == 0 || longitudeN.count == 0 {
            let alert = UIAlertController.init(title: NSLocalizedString("MESSAGE", comment: "提示信息"), message: NSLocalizedString("MSG08", comment: "获取权限失败提示信息"), preferredStyle: .alert)
            alert.addAction(.init(title: "はい", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController.init(title: NSLocalizedString("MESSAGE", comment: "提示信息"), message: NSLocalizedString("MSG04", comment: "请输入当前位置的别名"), preferredStyle: .alert)
            alert.addTextField(configurationHandler: ({ (textField: UITextField!) -> Void in
                textField.placeholder = NSLocalizedString("ALIAS", comment: "当前场所的别名")
                self.alias = textField.text ?? ""
            }))
            alert.addAction(.init(title: NSLocalizedString("OK", comment: "确定"), style: .default, handler: {
                action in
                let textFieldArray = alert.textFields
                let textField = textFieldArray?[0]
                self.alias = textField?.text ?? ""
                
                if self.alias.count == 0 {
                    let alertController = UIAlertController(title: NSLocalizedString("MSG09", comment: "输入正确的别名"),message: nil, preferredStyle: .alert)
                    // 显示提示框
                    self.present(alertController, animated: true, completion: nil)
                    // 两秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.dismiss(animated: true) {}
                    }
                } else {
                    self.uploadAlistRequest()
                }
            }))
            alert.addAction(.init(title: NSLocalizedString("CANCEL", comment: "取消"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITableViewDelegate & DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("REGIESTERED", comment: "已登录")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LocationTableViewCell = table.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        
        cell.locationLabel.text = dataArray[indexPath.row]["location"] as? String
        
        return cell
    }
}

//MARK: - Extension
extension LocationViewController {
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
