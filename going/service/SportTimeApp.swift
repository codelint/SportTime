//
//  SportTimeApp.swift
//  going
//
//  Created by gzhang on 2021/3/27.
//

import Foundation


class SportTime {
    
    static let shared = SportTime()
    
    let coreData = CoreDataService.going
    
    func cleanAllData() {
        coreData.query(request: BeepReport.fetchRequest(), query: { query in
            query.truncate()
        })
        
        coreData.query(request: BeepSession.fetchRequest(), query: { query in
            query.truncate()
        })
        
        coreData.query(request: BeepLog.fetchRequest(), query: { $0.truncate() })
    
    }
    
    func initAppData() {
        
        coreData.query(request: BeepSession.fetchRequest(), query: { query in
            let exists = query.findBy()
            for exist in exists {
                query.delete(exist)
            }
            if let first = query.findByOne() {
                print("\(first.name ?? "")/\(first.repeats)/\(first.beeps.count)")
                return
            }
            
            // 俯卧撑
            if let session = query.instance() {
                session.name = "俯卧撑训练"
                session.times = 1
                session.iterval_beep = Beep(text: "放松", time: 5, timeBeep: true)
                session.beeps = [
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false)
                ]
                query.flush()
            }
            
            if let session = query.instance() {
                session.name = "踝泵训练"
                session.times = 100
                // session.iterval_beep = nil
                session.beeps = [
                    Beep(text: "蹦脚", time: 3, timeBeep: true),
                    Beep(text: "勾脚", time: 3, timeBeep: true)
                ]
                query.flush()
            }
            
            if let session = query.instance() {
                session.name = "正抬腿"
                session.times = 15
                session.iterval_beep = Beep(text: "放松", time: 5, timeBeep: true)
                session.beeps = [
                    Beep(text: "正抬腿", time: 15, timeBeep: true),
                ]
                query.flush()
            }
            
            if let session = query.instance() {
                session.name = "侧抬腿"
                session.times = 15
                session.iterval_beep = Beep(text: "放松", time: 5, timeBeep: true)
                session.beeps = [
                    Beep(text: "侧抬腿", time: 15, timeBeep: true),
                ]
                query.flush()
            }
            
            if let session = query.instance() {
                session.name = "背抬腿"
                session.times = 15
                session.iterval_beep = Beep(text: "放松", time: 5, timeBeep: true)
                session.beeps = [
                    Beep(text: "背抬腿", time: 15, timeBeep: true),
                ]
                query.flush()
            }
            
            
        })
    }
}
