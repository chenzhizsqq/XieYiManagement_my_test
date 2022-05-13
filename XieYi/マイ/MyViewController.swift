//
//  MyViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/10/19.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MyViewController: ExMainViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    
    var nameArray = [
        NSLocalizedString("NAME", comment: "用户名"),
        NSLocalizedString("MOBILE", comment: "手机号码"),
        NSLocalizedString("MAIL", comment: "邮箱地址"),
        NSLocalizedString("PLACEMANAGE", comment: "工作地点管理"),
        NSLocalizedString("CHANGECOMPANY", comment: "公司切换")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        
        nameLabel.text = getUserNameFunc()
        mailLabel.text = getMailAddressFunc()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        /// 先判断是否登录token 再判断是否接入用户信息 否则网络请求
        if isLogin() {
            print("isLogin")
            if isUserInfo() {
                print("isUserInfo")
            } else {
//                getUserInfoRequest()
            }
        } else {
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
        
        customUI()
        table.reloadData()
    }
    
    // MARK: - 获取用户信息请求
    func getUserInfoRequest() {
        let token = UserDefaults().object(forKey: "token") as! String
        
        struct Parameter: Encodable {
            let app: String
            let token: String
            let tenant: String
            let hpid: String
            let device: String
        }
        let para = Parameter(app: "EtOfficeUserInfo", token: token, tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
        
        AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
            
            switch response.result {
            case .success(let data):
                print(data)
                let jsonData = JSON(data)
                
                if (jsonData["status"].intValue == 0) {
                    if saveUserInfoFunc(jsonString: jsonData) {
                        self.table.reloadData()
                        self.nameLabel.text = getUserNameFunc()
                        self.mailLabel.text = getMailAddressFunc()
                    }
                }
            case .failure(let error) :
                print(error)
            }
        })
    }
    
    // MARK: - UITableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return nameArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("PERSONALINFO", comment: "个人信息")
        }
        return NSLocalizedString("SYSTEM", comment: "系统")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempCell = UITableViewCell()
        
        if indexPath.section == 0 {
            let ID = "cell"
            var cell = tableView.dequeueReusableCell(withIdentifier: ID)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: ID)
            }
            
            cell?.selectionStyle = .none
            cell?.textLabel?.text = nameArray[indexPath.row]
            
            if indexPath.row == 0 {
                cell?.detailTextLabel?.text = getUserNameFunc()
            } else if indexPath.row == 1 {
                cell?.detailTextLabel?.text = getPhoneNumberFunc()
            } else if indexPath.row == 2 {
                cell?.detailTextLabel?.text = getMailAddressFunc()
            } else if indexPath.row == 3 {
                cell?.detailTextLabel?.text = ""
            } else if indexPath.row == 4 {
                cell?.detailTextLabel?.text = ""
            } else {
                cell?.detailTextLabel?.text = "..."
            }
            
            if indexPath.row == 3 || indexPath.row == 4 {
                cell?.accessoryType = .disclosureIndicator
            }
            else {
                cell?.accessoryType = .none
            }
            
            tempCell = cell!
        }
        else {
            let ID = "cell"
            var cell = tableView.dequeueReusableCell(withIdentifier: ID)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: ID)
            }
            
            cell?.selectionStyle = .none
            cell?.textLabel?.text = NSLocalizedString("SIGNOUT", comment: "登出")
            cell?.detailTextLabel?.text = ""
            tempCell = cell!
        }
        return tempCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Location")
                self.navigationController?.pushViewController(nextView, animated: true)
            } else if indexPath.row == 4 {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Change")
                self.navigationController?.pushViewController(nextView, animated: true)
            }
        } else if indexPath.section == 1 {
            if isLogin() {
                if indexPath.row == 0 {
                    let alert = UIAlertController.init(title: NSLocalizedString("CONFIRM", comment: "Message"), message: NSLocalizedString("MSG00", comment: "是否登出？"), preferredStyle: .alert)
                    alert.addAction(.init(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: {
                        action in
                        
                        deleteAllUserInfoFunc()
                        
                        self.table.reloadData()
                        
                        let storyboard = self.storyboard!
                        let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
                        self.navigationController?.pushViewController(nextView, animated: true)
                    }))
                    alert.addAction(.init(title: NSLocalizedString("CANCEL", comment: "取消"), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let storyboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "Login")
                self.navigationController?.pushViewController(nextView, animated: true)
            }
        }
    }
}
