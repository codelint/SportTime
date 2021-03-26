//
//  BeepLog.swift
//  going
//
//  Created by gzhang on 2021/3/25.
//

import Foundation
import CoreData


extension BeepLog {
    var beepDate: String? {
        if self.end_time > 0 {
            return Date(timeIntervalSince1970: Double(self.end_time)).dateString
        }else{
            return nil
        }
    }
    
    var elapsed_time: Int? {
        return (start_time > 0 && end_time > start_time) ? Int(end_time - start_time) : nil
    }
}
