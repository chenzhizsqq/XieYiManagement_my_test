//
//  PopoverViewController.swift
//  XieYi
//
//  Created by 写易 on 2021/01/14.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class PersonPopoverViewController: ExSubViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var rooter: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customUI()
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        table.sectionFooterHeight = 0.0
        table.register(MemberSectionHeader.nib(), forHeaderFooterViewReuseIdentifier: MemberSectionHeader.identifier)
        getStuffListRequest()
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
                    self.dataArray = jsonData["result"]["sectionlist"].object as! Array
                    
                    self.table.reloadData()
                } else {
                    
                }
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionStuffDic = self.dataArray[section]
        let stuffList = sectionStuffDic["stufflist"] as! Array<Dictionary<String, Any>>
        return stuffList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionStuffDic = self.dataArray[section]
        let sectionName = sectionStuffDic["sectionname"] as! String
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MemberSectionHeader.identifier) as! MemberSectionHeader
        header.sectionName.text = sectionName
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let sectionStuffDic = self.dataArray[indexPath.section]
            let stuffList = sectionStuffDic["stufflist"] as! Array<Dictionary<String, Any>>
            let stuffInfoDic = stuffList[indexPath.row]
            
            let uid = stuffInfoDic["userid"] as? String
            let username = stuffInfoDic["username"] as? String
            
            if self.rooter == "Daily" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Daily"), object: nil, userInfo: ["uid":uid!, "username": username!])
                NotificationCenter.default.removeObserver(self)
            } else if self.rooter == "DailyDetail"  {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DailyDetail"), object: nil, userInfo: ["uid":uid!, "username": username!])
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell  = UITableViewCell.init(style: .value1, reuseIdentifier: "Popover")
        
        let sectionStuffDic = self.dataArray[indexPath.section]
        let stuffList = sectionStuffDic["stufflist"] as! Array<Dictionary<String, Any>>
        let stuffInfoDic = stuffList[indexPath.row]
        
        cell.textLabel?.text = stuffInfoDic["username"] as? String
        cell.textLabel?.textColor = UIColor.systemIndigo
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        cell.detailTextLabel?.text = stuffInfoDic["userkana"] as? String
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        cell.selectionStyle = .none
        
        return cell
    }
}
