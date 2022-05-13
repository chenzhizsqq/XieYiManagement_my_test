//
//  ChangeCompanyViewController.swift
//  XieYi
//
//  Created by 写易 on 2020/12/17.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ChangeCompanyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var dataArray = Array<Dictionary<String, Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        getTenantRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
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

                if (jsonData["status"].int == 0) {
                    self.dataArray = jsonData["result"]["tenantlist"].object as! Array
                    self.table.reloadData()
                } else {

                }
            })
        }
    }
    
    // MARK: - 设置Tenant请求
    @objc func setTenantRequest(tenant: String) {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenantid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeSetTenant", token: getTokenFunc(), tenantid: tenant, device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                debugPrint(response)
                
//                let jsonData = JSON(response.data as Any)
//
//                if (jsonData["status"].int == 0) {
//                    self.dataArray = jsonData["result"]["tenantlist"].object as! Array
//                    self.table.reloadData()
//                } else {
//
//                }
                
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        if(jsonData["result"].count != 0){
                            jsonData["result"]["tenantlist"].array?.forEach({ json in
                                if (json["startflg"] == "1" ) {
                                    
                                    //EtOfficeUserInfo 数据更新
                                    self.getUserInfoRequest()
                                    
                                    self.table.reloadData()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                        self.dismiss(animated: true) {

                                            self.navigationController?.popViewController(animated: true)

                                        }
                                    }
                                }
                            })
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    
    // MARK: - EtOfficeUserInfo 数据更新
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
                    let mail = jsonData["result"]["mail"]
                    let phone = jsonData["result"]["phone"]
                    let usercode = jsonData["result"]["usercode"]
                    let userid = jsonData["result"]["userid"]
                    let userkana = jsonData["result"]["userkana"]
                    let username = jsonData["result"]["username"]
                    
                    saveUserInfoFunc(mail: mail.rawValue as! String
                                     ,phone: phone.rawValue as! String
                                     ,usercode: usercode.rawValue as! String
                                     ,userid: userid.rawValue as! String
                                     ,userkana: userkana.rawValue as! String
                                     ,username: username.rawValue as! String
                    )
                }
            case .failure(let error) :
                print(error)
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let str1 = getTenantidFunc()
        let str2 = getHpidFunc()
        let str3 = "Tenantid = " + str1 + " Hpid = " + str2
        
        return str3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tenantid = dataArray[indexPath.row]["tenantid"] as? String ?? ""
        let hpid = dataArray[indexPath.row]["hpid"] as? String ?? ""
        setTenantidAndHpidFunc(tenantid: tenantid, hpid: hpid)
        
        //等待json处理后再返回前一个页面
        //self.navigationController?.popViewController(animated: true)
        setTenantRequest(tenant: tenantid)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = dataArray[indexPath.row]["tenantname"] as? String
        cell.detailTextLabel?.text = dataArray[indexPath.row]["posturl"] as? String
        
        if getTenantidFunc() == dataArray[indexPath.row]["tenantid"] as? String {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
