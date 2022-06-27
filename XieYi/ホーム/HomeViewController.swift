//
//  MainViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/10/16.
//

import UIKit
import Reachability
import Alamofire
import SwiftyJSON
import AudioToolbox
import YYRefreshView

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collection: UICollectionView!
    
    var currentDate = ""
    var currentStatus = ""
    // 現在勤務状態
    var currentStatusValue = ""
    
    //var section1TextArray = ["勤務中", "勤務外", "休憩中", "移動中", "会議中"]
    var section1TextArray = ["勤務開始", "休憩開始", "会議開始", "移動開始", "勤務終了"]
    var section1ImageArray = ["person.fill.checkmark", "person.fill.xmark", "airplane", "car", "text.bubble"]

    var company = ""
//    ///选中了哪个页
//    var selectOptionMain = 0
    
    //    var section2TextArray = ["当日出勤", "组织架构", "我的审批"]
    //    var section2ImageArray = ["bag", "aspectratio", "tray.2"]
    
    let reachability = try! Reachability()
    
    var messageArray = Array<Dictionary<String, Any>>()
    var recordArray = Array<Dictionary<String, Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customHUD()
    }
    
    func customHUD() {
        // Collection Delegate
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = true
        collection.backgroundColor = UIColor.systemGroupedBackground
        
        // Collection Register
        collection.register(UINib.init(nibName: "HomeCollectionCell0", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell0")
        collection.register(UINib.init(nibName: "HomeCollectionCell1", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell1")
        collection.register(UINib.init(nibName: "HomeCollectionCell2", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell2")
        collection.register(UINib.init(nibName: "HomeCollectionCell3", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell3")
        collection.register(UINib(nibName: "HomeCollectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionHeader")
        
        // Collection Layout
        let layout = UICollectionViewFlowLayout.init()
        collection.collectionViewLayout = layout
        
        // Collection Refresh
        collection.addYYRefresh(position: .top) { (refresh) in
            print("refresh")
            self.getMessageRequest()
            refresh.endRefresh()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getMessageRequest), name: NSNotification.Name(rawValue: "UserSetStatus"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(getSelectOption(notification:)), name: .selectOptionName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // WIFI状态监测
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        
        if isLogin() {
            // 获取Tenant请求
            getTenantRequest()
            getMessageRequest()
        } else {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    // MARK: - 监测网络状况
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .unavailable:
            print("現在のネットワークは利用できません")
            Util.showMessageAlert(currentVC: self, title: NSLocalizedString("MESSAGE", comment: "Message"), msg: NSLocalizedString("MSG05", comment: "网络不可用"))
        case .none:
            print("none")
        }
    }
    
    // MARK: - 获取首页信息请求
    @objc func getMessageRequest() {
        print("token = " + getTokenFunc())
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
                let count: String
            }
            
            let para = Parameter(app: "EtOfficeGetMessage", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS", count: "5")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        self.messageArray = jsonData["result"]["messagelist"].object as! Array
                        self.recordArray = jsonData["result"]["recordlist"].object as! Array
                        if self.recordArray.count >= 1 {
                            //self.currentStatus = self.recordArray[0]["statustext"] as! String
                            self.currentStatus = self.getDispSattus(statusValue: self.recordArray[0]["statusvalue"] as! String)
                            self.currentStatusValue =  self.recordArray[0]["statusvalue"] as! String
                        }
                        self.collection.reloadData()
                    }
                case .failure(let error) :
                    print(error)
                }
                
            })
        }
    }
    
    // MARK: - 获取Tenant请求
    @objc func getTenantRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeGetTenant", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)

                if (jsonData["status"].intValue == 0) {

                        if(jsonData["result"].count != 0){
                            jsonData["result"]["tenantlist"].array?.forEach({ json in
                                if (json["startflg"] == "1" ) {
                                    
                                    self.company = json["tenantname"].stringValue
                                    
                                    self.collection.reloadData()

                                }
                            })
                        }
                } else {

                }
            })
        }
    }
    
    // MARK: - Collection Header
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionHeader", for: indexPath) as! HomeCollectionHeader
        
        if indexPath.section == 0 {
            header.textLabel.text = company
        } else if indexPath.section == 1 {
            //header.textLabel.text = "共通機能"
            header.textLabel.text = "勤務状態変更登録"
        } else if indexPath.section == 2 {
            //header.textLabel.text = "出勤記録"
            header.textLabel.text = "勤務状態変更履歴"
        } else if indexPath.section == 3 {
            header.textLabel.text = NSLocalizedString("MESSAGE", comment: "Message")
        } else {
            header.textLabel.text = "共通機能"
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 36)
    }
    
    // MARK: - Collection Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return section1TextArray.count
        } else if section == 2 {
            return 1
//            if recordArray.count == 2  {
//                return 1
//            }
//            return 0
        } else if section == 3 {
            return 1
            //return messageArray.count
            
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            let (buttonText, buttonEnable) = getButtonStatusText(statusValue: currentStatusValue, buttonIndex: indexPath.row)
            if !buttonEnable {
                return
            }
            
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            if indexPath.row == 0 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Status") as! StatusConfirmViewController
                nextView.code = 1
                nextView.currentStatusValue = currentStatusValue
                nextView.currentStatusText = buttonText
                //nextView.selectOption = selectOptionMain
                nextView.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(nextView, animated: true)

            } else if indexPath.row == 1 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Status") as! StatusConfirmViewController
                nextView.code = 2
                nextView.currentStatusValue = currentStatusValue
                nextView.currentStatusText = buttonText
                //nextView.selectOption = selectOptionMain
                nextView.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(nextView, animated: true)

            } else if indexPath.row == 2 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Status") as! StatusConfirmViewController
                nextView.code = 3
                nextView.currentStatusValue = currentStatusValue
                nextView.currentStatusText = buttonText
                //nextView.selectOption = selectOptionMain
                nextView.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(nextView, animated: true)

            } else if indexPath.row == 3 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Status") as! StatusConfirmViewController
                nextView.code = 4
                nextView.currentStatusValue = currentStatusValue
                nextView.currentStatusText = buttonText
                //nextView.selectOption = selectOptionMain
                nextView.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(nextView, animated: true)

            } else if indexPath.row == 4 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Status") as! StatusConfirmViewController
                nextView.code = 5
                nextView.currentStatusValue = currentStatusValue
                nextView.currentStatusText = buttonText
                //nextView.selectOption = selectOptionMain
                nextView.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(nextView, animated: true)

            }
        } else if indexPath.section == 2 {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "CheckIn") as! CheckInRecordViewController
            nextView.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(nextView, animated: true)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var tempCell = UICollectionViewCell()
        if indexPath.section == 0 {
            let cell : HomeCollectionCell0 = collection.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell0", for: indexPath) as! HomeCollectionCell0
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            // 获取当前时间⌚️
            let date = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy.MM.dd"
            let now = timeFormatter.string(from: date) as String
            
            cell.dateLabel.text = now
            cell.statusLabel.text = currentStatus
            cell.nameLabel.text = getUserNameFunc()
            
            tempCell = cell
            
        } else if indexPath.section == 1 {
            let cell : HomeCollectionCell1 = collection.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell1", for: indexPath) as! HomeCollectionCell1
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            //cell.textLabel.text = section1TextArray[indexPath.row]
            
            let (buttonText, buttonEnable) = getButtonStatusText(statusValue: currentStatusValue, buttonIndex: indexPath.row)
            cell.textLabel.text = buttonText
            if buttonEnable {
                cell.backgroundColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            
            cell.image.image = UIImage.init(systemName: section1ImageArray[indexPath.row])
            tempCell = cell
            
        } else if indexPath.section == 2 {
            let cell : HomeCollectionCell2 = collection.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell2", for: indexPath) as! HomeCollectionCell2
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            //「データがありません」を表示
            cell.tipsLabel.isHidden = true
            cell.text0.isHidden = false
            cell.text1.isHidden = false
            
            if recordArray.count == 2 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat="yyyyMMddHHmmss"
                
                let time = recordArray[0]["statustime"] as? String
                let date = dateFormatter.date(from: time!)
                let finalDate = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm")
                let status = recordArray[0]["statustext"] as? String ?? ""
                let memoText = recordArray[0]["memo"] as? String  ?? ""
                let text0 = "・" + finalDate + " " + status + " " + memoText
                cell.text0.text = text0
                
                let time1 = recordArray[1]["statustime"] as? String
                let date1 = dateFormatter.date(from: time1!)
                let finalDate1 = DateUtils.stringFromDate(date: date1!, format: "yyyy.MM.dd HH:mm")
                let status1 = recordArray[1]["statustext"] as? String ?? ""
                let memoText1 = recordArray[1]["memo"] as? String  ?? ""
                let text1 = "・" + finalDate1 + " " + status1 + " " + memoText1
                cell.text1.text = text1
            }else{
                
                //「データがありません」を表示
                cell.tipsLabel.isHidden = false
                cell.text0.isHidden = true
                cell.text1.isHidden = true
            }
            
            tempCell = cell
            
        } else if indexPath.section == 3 {
            let ID = "HomeCollectionCell3"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID, for: indexPath) as! HomeCollectionCell3
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            //「データがありません」を表示
            cell.tipsLabel.isHidden = true
            cell.titleLabel.isHidden = false
            cell.timeLabel.isHidden = false
            cell.detailLabel.isHidden = false
            
            if(messageArray.isEmpty){
                cell.tipsLabel.isHidden = false
                cell.titleLabel.isHidden = true
                cell.timeLabel.isHidden = true
                cell.detailLabel.isHidden = true
            }else{
                cell.titleLabel.text = messageArray[indexPath.row]["title"] as? String
                
                let tempStr = messageArray[indexPath.row]["content"] as? String
                var str = tempStr?.replacingOccurrences(of: "<br>", with: "")
                
                if (str?.contains("$") ?? false) as Bool {
                    str = str?.replacingOccurrences(of: "$", with: "￥")
                } else {
                    
                }
                cell.detailLabel.text = str
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat="yyyyMMddHHmmss"
                let time = messageArray[indexPath.row]["updatetime"]
                let date = dateFormatter.date(from: time as! String)
                cell.timeLabel.text = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm:ss")
                
            }
            tempCell = cell
        }
        return tempCell
    }
    
    // MARK: - 获取当前状态
    func getStatusvalue() -> String {
        if(recordArray.count > 0 ){
            return recordArray[0]["statusvalue"] as? String ?? ""
        }
        return "0"
    }
    
    
//    // MARK: - 获取选中的选项
//    @objc func getSelectOption(notification: NSNotification?) {
//        selectOptionMain = notification?.userInfo?["selectOption"] as? Int ?? 0
//        print("!!! selectOptionMain getSelectOption(): \(selectOptionMain)")
//    }
    // MARK: - 勤務状態から表示するステータス文字列を取得
    func getDispSattus(statusValue: String) -> String {
        switch statusValue {
            // 勤務開始
        case "1":
            return "勤務中"
            // 勤務終了
        case "2":
            return "勤務外"
            // 休憩開始
        case "3":
            return "休憩中"
            // 休憩終了
        case "4":
            return "勤務中"
            // 会議開始
        case "5":
            return "会議中"
            // 会議終了
        case "6":
            return "勤務中"
            // 移動開始
        case "7":
            return "移動中"
            // 移動終了
        case "8":
            return "勤務中"
            
        default:
            return ""
        }

    }
    
    // MARK: - 勤務状態変更ボタン文字列およびボタン活性状態を取得
    func getButtonStatusText(statusValue: String, buttonIndex: Int) -> (String, Bool) {
        switch statusValue {
            // 勤務開始
        case "1":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", true)
            case 2:
                return ("会議開始", true)
            case 3:
                return ("移動開始", true)
            case 4:
                return ("勤務終了", true)
            default:
                return ("", false)
            }
            
            // 勤務終了
        case "2":
            switch buttonIndex {
            case 0:
                return ("勤務開始", true)
            case 1:
                return ("休憩開始", false)
            case 2:
                return ("会議開始", false)
            case 3:
                return ("移動開始", false)
            case 4:
                return ("勤務終了", false)
            default:
                return ("", false)
            }
            // 休憩開始
        case "3":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩終了", true)
            case 2:
                return ("会議開始", false)
            case 3:
                return ("移動開始", false)
            case 4:
                return ("勤務終了", false)
            default:
                return ("", false)
            }
            // 休憩終了
        case "4":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", true)
            case 2:
                return ("会議開始", true)
            case 3:
                return ("移動開始", true)
            case 4:
                return ("勤務終了", true)
            default:
                return ("", false)
            }
            // 会議開始
        case "5":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", false)
            case 2:
                return ("会議終了", true)
            case 3:
                return ("移動開始", false)
            case 4:
                return ("勤務終了", false)
            default:
                return ("", false)
            }
            // 会議終了
        case "6":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", true)
            case 2:
                return ("会議開始", true)
            case 3:
                return ("移動開始", true)
            case 4:
                return ("勤務終了", true)
            default:
                return ("", false)
            }
            // 移動開始
        case "7":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", false)
            case 2:
                return ("会議開始", false)
            case 3:
                return ("移動終了", true)
            case 4:
                return ("勤務終了", false)
            default:
                return ("", false)
            }
            // 移動終了
        case "8":
            switch buttonIndex {
            case 0:
                return ("勤務開始", false)
            case 1:
                return ("休憩開始", true)
            case 2:
                return ("会議開始", true)
            case 3:
                return ("移動開始", true)
            case 4:
                return ("勤務終了", true)
            default:
                return ("", false)
            }
            
        default:
            switch buttonIndex {
            case 0:
                return ("勤務開始", true)
            case 1:
                return ("休憩開始", false)
            case 2:
                return ("会議終了", false)
            case 3:
                return ("移動開始", false)
            case 4:
                return ("勤務終了", false)
            default:
                return ("", false)
            }
        }

    }
}

// MARK: - Collection Extension
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.size.width - 16
        
        if indexPath.section == 0 {
            return CGSize(width: collectionWidth, height: 76)
        } else if indexPath.section == 1 {
            return CGSize(width: (collectionWidth - 16) / 5.0, height: (collectionWidth - 16) / 5.0)
        } else if indexPath.section == 2 {
            return CGSize(width: collectionView.bounds.size.width - 16, height: 60)
        } else if indexPath.section == 3 {
            return CGSize(width: collectionView.bounds.size.width - 16, height: 74)
        }
        return CGSize(width: collectionView.bounds.size.width - 16, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
    }
}

// MARK: - Date converse to String
class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

//// MARK: - 选择项目的Key
//extension Notification.Name {
//   static let selectOptionName = Notification.Name("selectOptionName")
//}
