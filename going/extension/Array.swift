//
//  Array.swift
//  going
//
//  Created by gzhang on 2021/3/26.
//

import Foundation

extension Array {
    
    func groupBy(key: (Element) -> String?) -> [String: [Element]]{
        var results = [String: [Element]]()
        for element in self {
            // print("beep[\(beep.name)] at \(Date(timeIntervalSince1970: Double(beep.end_time)).datetimeString)")
            if let label = key(element) {
                if !results.keys.contains(label) {
                    results[label] = [Element]()
                }
                
                results[label]?.append(element)
            }
        }
        
        return results
    }
    
    func asyncEach(
        _ arr: [Element],
        from: Int = 0,
        next: @escaping ((Element, @escaping () -> Void) -> Void),
        first: ((Element, @escaping () -> Void) -> Void)? = nil,
        last: ( (Element) -> Void)? = nil
    ) {
        
        
        
    }
    
}
