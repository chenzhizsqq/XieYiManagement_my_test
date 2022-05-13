//
// StatusType.swift
//  EtOffice
//
//  勤務状態enum
//  Created by Qi Yu on 2021/09/29.
//

import Foundation

// 勤務状態種別
enum StatusType: Int {
    case  working = 1
    ,outWork = 2
    ,resting = 3
    ,moving = 4
    ,meeting = 5
    
    var description: String {
        switch self {
        case .working:  return "勤務中"
        case .outWork: return "勤務外"
        case .resting: return "休憩中"
        case .moving: return "移動中"
        case .meeting: return "会議中"
        }
    }
}
