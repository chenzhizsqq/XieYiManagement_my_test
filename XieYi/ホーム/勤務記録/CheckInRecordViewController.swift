//
//  CheckInRecordViewController.swift
//  XieYi
//
//  Created by 写易 on 2021/02/05.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class CheckInRecordViewController: ExSubViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func customUI() {
        table.delegate = self
        table.dataSource = self
        
        table.register(UINib.init(nibName: "StatusTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusTableViewCell")
        closeBtn.layer.cornerRadius = 18.0
        getStatusListRequest()
        
        self.title = "出勤記録"
    }
    
    func getStatusListRequest() {
        if getTokenFunc().count != 0 {
            
            struct Parameter: Encodable {
                let app: String
                let token: String
                let tenant: String
                let hpid: String
                let device: String
            }
            
            let para = Parameter(app: "EtOfficeGetStatusList", token: getTokenFunc(), tenant: getTenantidFunc(), hpid: getHpidFunc(), device: "iOS")
            
            AF.request(BaseURL, method: .post, parameters: para, encoder: JSONParameterEncoder.default).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let data):
                    print(data)
                    let jsonData = JSON(data)
                    
                    if (jsonData["status"].intValue == 0) {
                        self.dataArray = jsonData["result"]["recordlist"].object as! Array
                        self.table.reloadData()
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StatusTableViewCell = table.dequeueReusableCell(withIdentifier: "StatusTableViewCell", for: indexPath) as! StatusTableViewCell

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyyMMddHHmmss"
        let time = dataArray[indexPath.row]["statustime"]
        let date = dateFormatter.date(from: time as! String)
        
        cell.titleLabel.text = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm:ss")
        //cell.textLabel?.text = DateUtils.stringFromDate(date: date!, format: "yyyy.MM.dd HH:mm:ss")
        
        let statusText = dataArray[indexPath.row]["statustext"] as? String ?? ""
        let memoText = dataArray[indexPath.row]["memo"] as? String  ?? ""
        let detailText = statusText + " " + memoText
        cell.detailLabel.text = detailText
        //cell.detailTextLabel?.text = detailText
        
        cell.selectionStyle = .none
        
        return cell
    }
}
