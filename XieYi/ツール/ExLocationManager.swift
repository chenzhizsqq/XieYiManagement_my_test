//
//  ExLocationManager.swift
//  XieYi
//
//  Created by 写易 on 2020/11/09.
//

import UIKit
import CoreLocation

//MARK: - 根据角度计算弧度
func radian(d:Double) -> Double {
    return d * Double.pi/180.0
}

//MARK: - 根据弧度计算角度
func angle(r:Double) -> Double {
    return r * 180/Double.pi
}

//MARK: - 计算坐标间距离
func getDistance(lat1:Double,lng1:Double,lat2:Double,lng2:Double) -> Double {
    let EARTH_RADIUS:Double = 6378137.0
    
    let radLat1:Double = radian(d: lat1)
    let radLat2:Double = radian(d: lat2)
    
    let radLng1:Double = radian(d: lng1)
    let radLng2:Double = radian(d: lng2)
    
    let a:Double = radLat1 - radLat2
    let b:Double = radLng1 - radLng2
    
    var s:Double = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2), 2)))
    s = Double(String(format: "%.2f", s * EARTH_RADIUS))!
    //print("😈Distance = " + String(s))
    return s
}

//MARK: - 判断是否在本地存储地址范围内
func isInArea(lat:Double,lon:Double) -> String? {
    let DISTANCE = 20.0
    
    if UserDefaults.standard.object(forKey: "LOCATIONLIST") != nil {
        let locationArray = UserDefaults.standard.object(forKey: "LOCATIONLIST") as! Array<Dictionary<String, String>>
        //        print(locationArray)
        if locationArray.count > 0 {
            for item in locationArray {
                let tempLat = Double(item["latitude"]!) ?? 0.0
                let tempLon = Double(item["longitude"]!) ?? 0.0
                let dis = getDistance(lat1: lat, lng1: lon, lat2: tempLat, lng2: tempLon)
                if dis <= DISTANCE {
                    if (item["location"] ?? "").count > 0 {
                        return item["location"]!
                    }
                }
            }
        } else {
            return nil
        }
    } else {
        return nil
    }
    return nil
}
