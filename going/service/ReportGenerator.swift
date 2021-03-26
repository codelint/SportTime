//
//  ReportGenerator.swift
//  going
//
//  Created by gzhang on 2021/3/25.
//

import Foundation

class ReportGenerator {
    
    var coreData = CoreDataService.going
    
    public func generate(start: Int = 0){
        print("generate....")

        let beeps =  coreData.findBy(request: BeepLog.fetchRequest(), conds: ["end_time": ">\(start)"])
        
        let groupedLog = beeps.groupBy(key: { $0.name })
        var reportData = [String:[String: [BeepLog]]]()
        for (label, beeps) in groupedLog {
            // print("k = \(kv.element.key), v = \(kv.element.value.count)")
            reportData[label] = beeps.groupBy(key: { Date(timeIntervalSince1970: Double($0.end_time)).dateString })
        }
        
        
        coreData.query(request: BeepReport.fetchRequest()) { query in
            
            for (label, timelines) in reportData {
                
                for (timeline, beeps) in timelines {
                    
                    var exist = query.findByOne(conds: ["label": label, "timeline": timeline])
                    
                    exist = exist == nil ? query.instance() : exist
                    
                    if let e = exist {
                        e.label = label
                        e.timeline = timeline
                        e.number = Int64(beeps.count)
                        e.elapsed = Int64(beeps.filter({ $0.elapsed_time != nil }).reduce(0, { $0 + $1.elapsed_time! }))
                        query.flush()
                    }
                }
            }
            
        }
        
        let reports = coreData.findBy(request: BeepReport.fetchRequest())
        
        for report in reports {
            print("\(report.label!), \(report.timeline!), \(report.number), \(report.elapsed)")
        }
        
    }
    
}
