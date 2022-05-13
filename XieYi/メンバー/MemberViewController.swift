//
//  MemberViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/11/05.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberViewController: ExMainViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    // 「データがありません」を表示
    @IBOutlet weak var tipsLabel: UILabel!
    
    // データ表示用Dictionary
    var sectionStuffDic = Dictionary<String, Any>()
    // 部門名格納用配列
    var sectionNameArray = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tipsLabel.isHidden = true
        customUI()
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        table.sectionFooterHeight = 0.0
        table.register(MemberSectionHeader.nib(), forHeaderFooterViewReuseIdentifier: MemberSectionHeader.identifier)
        table.register(UINib.init(nibName: "MemberTableViewCell", bundle: nil), forCellReuseIdentifier: "MemberTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserStatusRequest()
        getStuffListRequest()
    }
    
    @objc func getUserStatusRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeGetUserStatus", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        
                        self.dataArray = jsonData["result"]["userstatuslist"].object as! Array
                        self.getStuffListRequest()
                        
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    func getStuffListRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeGetStuffList", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                
                let jsonData = JSON(response.data as Any)
                
                if (jsonData["status"].int == 0) {
                    self.makeDataList(sectionList: jsonData["result"]["sectionlist"].object as! Array<Dictionary<String, Any>>)
                    self.table.reloadData()
                    
                    //「データがありません」を表示
                    if (jsonData["result"]["sectionlist"].isEmpty){
                        self.tipsLabel.isHidden = false
                    }else{
                        self.tipsLabel.isHidden = true
                    }
                    
                } else {
                    
                }
            })
        }
    }
    
    ///
    /// 表示用データ作成
    ///
    func makeDataList(sectionList: Array<Dictionary<String, Any>>) {
        sectionNameArray.removeAll()
        sectionStuffDic.removeAll()
        
        // 部門名リスト作成
        for section in sectionList {
            let sectionName = section["sectionname"] as! String
            sectionNameArray.append(sectionName)
        }
        
        // 表示用データ作成
        for i in 0...self.dataArray.count - 1 {
            let statusUserId = self.dataArray[i]["userid"] as? String ?? ""
            
            for section in sectionList {
                let sectionName = section["sectionname"] as! String
                let stuffList = section["stufflist"] as! Array<Dictionary<String, Any>>
                
                for stuffDic in stuffList {
                    let stuffUserId = stuffDic["userid"] as? String ?? ""
                    if statusUserId == stuffUserId {
                        let phone = stuffDic["phone"] as? String ?? ""
                        let mail = stuffDic["mail"] as? String ?? ""
                        self.dataArray[i]["phone"] = phone
                        self.dataArray[i]["mail"] = mail
                        
                        var stuffArray = sectionStuffDic[sectionName] as? Array<Dictionary<String, Any>>
                        if stuffArray == nil {
                            stuffArray = Array<Dictionary<String, Any>>()
                        }
                        stuffArray!.append(self.dataArray[i])
                        sectionStuffDic[sectionName] = stuffArray
                        
                        break
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNameArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionNameArray[section]
        let stuffList = sectionStuffDic[sectionName] as! Array<Dictionary<String, Any>>
        return stuffList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = sectionNameArray[section]
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MemberSectionHeader.identifier) as! MemberSectionHeader
        header.sectionName.text = sectionName
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionName = sectionNameArray[indexPath.section]
        let stuffList = sectionStuffDic[sectionName] as! Array<Dictionary<String, Any>>
        let stuffInfo = stuffList[indexPath.row]
        
        let phone = stuffInfo["phone"] as? String
        if phone != nil && phone!.count >= 5 {
            let alert = UIAlertController.init(
                title: "電話番号",
                message: nil ,
                preferredStyle: .actionSheet
            )
            alert.addAction(.init(title: phone, style: .default, handler: {
                action in
                self.callPhoneTel(phone: phone!)
            }))
            alert.addAction(.init(title: NSLocalizedString("CANCEL", comment: "取消"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 拨打电话方法
    func callPhoneTel(phone : String){
        let phoneUrlStr = "tel://" + phone
        
        if UIApplication.shared.canOpenURL(URL(string: phoneUrlStr)!) {
            UIApplication.shared.open(URL(string: phoneUrlStr)!, options: .init(), completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberTableViewCell = table.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        
        cell.selectionStyle = .none
        cell.statusView.layer.cornerRadius = 5.0
        
        
        let sectionName = sectionNameArray[indexPath.section]
        let stuffList = sectionStuffDic[sectionName] as! Array<Dictionary<String, Any>>
        let stuffInfo = stuffList[indexPath.row]
        
        cell.name.text = stuffInfo["username"] as? String
        cell.katakana.text  = stuffInfo["userkana"] as? String
        
        let statusText = stuffInfo["statustext"] as? String
        let statusValue = stuffInfo["statusvalue"] as? Int
        var workColor = UIColor(named: "working")
        switch (statusValue ?? -1) {
        case StatusType.working.rawValue:
            workColor = UIColor(named: "working")
            break
        case StatusType.outWork.rawValue,
             StatusType.resting.rawValue:
            workColor = UIColor(named: "outwork_resting")
            break
        case StatusType.moving.rawValue,
             StatusType.meeting.rawValue:
            workColor = UIColor(named: "meeting_working")
            break
        default:
            workColor = UIColor(named: "unknow")
            break
        }
        
        //出勤状态设置圆点颜色
        switch (statusText ?? "") {
        case "勤務中":
            workColor = UIColor.green
            break
        case "勤務外":
            workColor = UIColor.gray
            break
        case "休憩中":
            workColor = UIColor.gray
            break
        case "移動中":
            workColor = UIColor.blue
            break
        case "会議中":
            workColor = UIColor.blue
            break
        default:
            workColor = UIColor(named: "unknow")
            break
        }
        
        cell.statusView.backgroundColor = workColor
        
        let memoText = stuffInfo["memo"] as? String  ?? ""
        cell.status.text  = statusText?.count ?? 0 > 1 ? ((statusText ?? "") + " " + memoText) : NSLocalizedString("MSG10", comment: "未知状态")
        
        let location = stuffInfo["location"] as? String
        cell.location.text  = location?.count ?? 0 > 1 ? location : NSLocalizedString("MSG07", comment: "未登录工作地点")
        
        cell.phone.text  = stuffInfo["phone"] as? String
        cell.mail.text  = stuffInfo["mail"] as? String
        
        return cell
    }
}
