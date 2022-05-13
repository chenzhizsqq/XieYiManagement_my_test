//
//  UserInfoModel.swift
//  XieYi
//
//  Created by 写易 on 2020/10/22.
//

import Foundation
import HandyJSON
import SwiftyJSON

// MARK: - 不允许直接调用 只可以调用方法
private class UserInfoModel: HandyJSON {
    // 初始化
    required init() {}
    var hpid: String = ""
    var mail: String = ""
    var phone: String = ""
    var tenantid: String = ""
    var token: String = ""
    var usercode: String = ""
    var userid: String = ""
    var userkana: String = ""
    var username: String = ""
}

// MARK: - 获取数据并存储方法 成功返回true 失败返回false
func saveUserInfoFunc(jsonString:JSON) -> Bool {
    // 转换成原始json格式并序列化转模型
    let object = UserInfoModel.deserialize(from: jsonString.rawString(), designatedPath: "result")
    print("SAVING 😈")
    if (object != nil) {
        let user = UserDefaults()
        user.set(object?.hpid, forKey: "hpid")
        user.set(object?.mail, forKey: "mail")
        user.set(object?.phone, forKey: "phone")
        user.set(object?.tenantid, forKey: "tenantid")
        user.set(object?.token, forKey: "token")
        user.set(object?.usercode, forKey: "usercode")
        user.set(object?.userid, forKey: "userid")
        user.set(object?.userkana, forKey: "userkana")
        user.set(object?.username, forKey: "username")
        user.set(true, forKey: "isLogin")
        user.set(true, forKey: "isUserInfo")
        return true
    }
    return false
}


// MARK: - 保存当前用户信息
func saveUserInfoFunc(mail: String
                      , phone: String
                      , usercode: String
                      , userid: String
                      , userkana: String
                      , username: String)  {
    let user = UserDefaults()
    user.set(mail, forKey: "mail")
    user.set(phone, forKey: "phone")
    user.set(usercode, forKey: "usercode")
    user.set(userid, forKey: "userid")
    user.set(userkana, forKey: "userkana")
    user.set(username, forKey: "username")
    print(mail, phone,username)
}

// MARK: - 更改用户tenantid和hpid方法
func setTenantidAndHpidFunc(tenantid: String, hpid: String) {
    let user = UserDefaults()
    user.set(tenantid, forKey: "tenantid")
    user.set(hpid, forKey: "hpid")
    print(tenantid, hpid)
}

// MARK: - 获取用户tenantid方法
func getTenantidFunc() -> String {
    let user = UserDefaults()
    let tenantid = user.object(forKey: "tenantid") ?? ""
    return tenantid as! String
}

// MARK: - 获取用户hpid方法
func getHpidFunc() -> String {
    let user = UserDefaults()
    let hpid = user.object(forKey: "hpid") ?? ""
    return hpid as! String
}

// MARK: - 获取用户名方法
func getUserNameFunc() -> String {
    let user = UserDefaults()
    let userName = user.object(forKey: "username") ?? ""
    return userName as! String
}

// MARK: - 获取用户id方法
func getUserIdFunc() -> String {
    let user = UserDefaults()
    let userId = user.object(forKey: "userid") ?? ""
    return userId as! String
}

// MARK: - 获取phone方法
func getPhoneNumberFunc() -> String {
    let user = UserDefaults()
    let phone = user.object(forKey: "phone") ?? ""
    return phone as! String
}

// MARK: - 获取mail方法
func getMailAddressFunc() -> String {
    let user = UserDefaults()
    let mail = user.object(forKey: "mail") ?? ""
    return mail as! String
}

// MARK: - 获取token方法
func getTokenFunc() -> String {
    let user = UserDefaults()
    let token = user.object(forKey: "token") ?? ""
    return token as! String
}

// MARK: - 删除所有用户信息
func deleteAllUserInfoFunc() {
    let user = UserDefaults()
    user.removeObject(forKey: "hpid")
    user.removeObject(forKey: "mail")
    user.removeObject(forKey: "phone")
    user.removeObject(forKey: "tenantid")
    user.removeObject(forKey: "token")
    user.removeObject(forKey: "usercode")
    user.removeObject(forKey: "userid")
    user.removeObject(forKey: "userkana")
    user.removeObject(forKey: "username")
    user.set(false, forKey: "isLogin")
    user.set(false, forKey: "isUserInfo")
}

// MARK: - 判断是否登录
func isLogin() -> Bool {
    let user = UserDefaults()
    
    if user.object(forKey: "isLogin") == nil {
        return false
    }
    
    if (user.object(forKey: "isLogin")) as! Bool == true {
        return true
    } else {
        return false
    }
}

// MARK: - 判断是否写入用户信息
func isUserInfo() -> Bool {
    let user = UserDefaults()
    
    if user.object(forKey: "isUserInfo") == nil {
        return false
    }
    
    if (user.object(forKey: "isUserInfo")) as! Bool == true {
        return true
    } else {
        return false
    }
}
