//
//  CoreDataService.swift
//  samulala
//
//  Created by gzhang on 2021/3/2.
//

import Foundation
import CoreData



class CoreDataService {
    
    static let going = CoreDataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
        CoreDataService.generateContainer()
    }()
    
    lazy var reader: NSPersistentContainer = {
        CoreDataService.generateContainer()
    }()
    
    static func generateContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "going")
        // 3
        container.loadPersistentStores { _, error in
            // 4
            if let error = error as NSError? {
                // You should add your own error handling code here.
                print("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }

    
    func once<T:NSManagedObject>(request: NSFetchRequest<T>, action: @escaping (NSPersistentContainer) -> Void){
        
        let container = CoreDataService.generateContainer()
        
        action(container)
    }
    
    func saveContext() {
        // 1
        let context = persistentContainer.viewContext
        
        
        // 2
        if context.hasChanges {
            do {
                // 3
                try context.save()
            } catch {
                // 4
                // The context couldn't be saved.
                // You should add your own error handling here.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func instance<T:NSManagedObject>() -> T? {
        return T(context: persistentContainer.viewContext)
    }
    
    func once<T:NSManagedObject>(request: NSFetchRequest<T>, action: @escaping (NSManagedObjectContext) -> Void){
        
        self.once(request: request) { (container: NSPersistentContainer) in
            action(container.viewContext)
        }
    }
    
    func query<T:NSManagedObject>(request: NSFetchRequest<T>, query: @escaping (Query<T>) -> Void){
        
        self.once(request: request) { (container: NSPersistentContainer) in
            query(Query(container: container, request:request))
        }
        
    }
    
    func getQuery<T:NSManagedObject>(request: NSFetchRequest<T>) -> Query<T> {
        return Query(container: CoreDataService.generateContainer(), request:request)
    }
    
    func read<T:NSManagedObject>(request: NSFetchRequest<T>, query: @escaping (Query<T>) -> Void){
        query(Query(container: self.reader, request: request))
    }
    
    class Query<T: NSManagedObject> {
        
        let container: NSPersistentContainer
        var request: NSFetchRequest<T>
        
        init(container: NSPersistentContainer, request: NSFetchRequest<T>){
            self.container = container
            self.request = request
        }
        
        func truncate() {
            let arr = self.findBy()
            for item in arr {
                self.delete(item)
            }
        }
        
        func findBy(conds: [String: String?] = [String:String]()) -> [T] {
            
            // let request = NSFetchRequest<T>(entityName: entityName.rawValue)
            
            // let request = T.fetchRequest()
            // let request: NSFetchRequest<EnCartItem> = EnCartItem.fetchRequest()
            let context = container.viewContext
            var results : [T]
            
            // request.predicate = NSPredicate(format: "name == %@", name)
            
            let predicate_str = conds.map { (kv: (key: String, value: String?)) -> String in
                
                if let v  = kv.value {
                    var op = "=="
                    if v.starts(with: ">") {
                        op = ">"
                    } else if v.starts(with: "<") {
                        op = "<"
                    }else{
                        op = "=="
                    }
                    return "\(kv.key)\(op)'\(kv.value!)'"
                }else{
                    return "\(kv.key)==nil"
                }
            }.joined(separator: " && ")
            
            if predicate_str.count > 0 {
                request.predicate = NSPredicate(format: predicate_str)
            }
            
            do {
                results = try context.fetch(request)
            }catch{
                return  [T]()
            }
            
            return  results
        }
        
        func findByOne(conds: [String: String] = [String:String]()) -> T? {
            let results = self.findBy(conds: conds)
            if results.count > 0 {
                return results[0]
            }else{
                return nil
            }
        }
        
        func findById(id: String) -> T? {
            // let r: Result = T.fetchRequest()
            return findByOne(conds: ["id": id])
        }
        
        func refresh(_ t: T){
            container.viewContext.refresh(t, mergeChanges: true)
        }
        
        func flush(){
            // 1
            let context = container.viewContext
            
            
            // 2
            if context.hasChanges {
                do {
                    // 3
                    try context.save()
                } catch {
                    // 4
                    // The context couldn't be saved.
                    // You should add your own error handling here.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        func instance(conds: [String: String]? = nil) -> T? {
            if let cri = conds {
                if let ins = self.findByOne(conds: cri) {
                    return ins
                }else{
                    return T(context: container.viewContext)
                }
            }else{
                return T(context: container.viewContext)
            }
        }
        
        func delete<T: NSManagedObject>(_ entity: T) {
            container.viewContext.delete(entity)
            flush()
        }
        
    }
    
    func findBy<T: NSManagedObject>(request: NSFetchRequest<T>, conds: [String: String] = [String:String]()) -> [T] {
        
        let query = Query(container: persistentContainer, request: request)
        
        return query.findBy(conds: conds)
    }
    
    func findByOne<T: NSManagedObject>(request: NSFetchRequest<T>, conds: [String: String] = [String:String]()) -> T? {
        
        let results = self.findBy(request: request, conds: conds)
        if results.count > 0 {
            return results[0]
        }else{
            return nil
        }
    }
    
    func findById<T: NSManagedObject>(request: NSFetchRequest<T>, id: String) -> T? {
        
        // let r: Result = T.fetchRequest()
        return findByOne(request: request, conds: ["id": id])
        
    }
    
    func delete<T: NSManagedObject>(_ entity: T) {
        persistentContainer.viewContext.delete(entity)
        saveContext()
    }
    
    
    
}
