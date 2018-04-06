//
//  DataManager.swift
//  DoIt
//
//  Created by Tristan on 30/03/2018.
//  Copyright © 2018 Tristan. All rights reserved.
//

import Foundation
import CoreData



protocol DataManagerProtocol :class {
    func saveData()
    func loadData()
    func moveItem(to sourceIndex : Int, at destinationIndex : Int)
    func getFilteredItemsByIndex(index: Int)-> Item
    func getItemsByIndex(index: Int) -> Item
    func getAllFilteredItems()->Array<Item>
    func getAllItems()->Array<Item>
    func getCountItems()-> Int
    func getCountFilteredItems()-> Int
    func setFilteredItems(filteredItems : Array<Item>)
    func appendToItems(item : Item)
    func appendToFilteredItems(item : Item)
    func removeToItems(index : Int)
    func remove(atIndex index: Int)
}


class DataManager : DataManagerProtocol{
    
    
    //MARK : - SINGLETON
    static let shared = DataManager()
    private init(){
        loadData()
    }
    
    
    
    // MARK: - VARS
    private var filteredItems = Array<Item>()
    private var items = Array<Item>()
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    //MARK: GETTERS
    public func getFilteredItemsByIndex(index: Int)-> Item{
        return filteredItems[index]
    }
    
    public func getItemsByIndex(index: Int) -> Item {
        return items[index]
    }
    
    public func getAllFilteredItems()->Array<Item>{
        return filteredItems
    }
    
    public func getAllItems()->Array<Item>{
        return items
    }
    
    public func getCountItems()-> Int{
        return self.items.count
    }
    
    public func getCountFilteredItems()-> Int{
        return self.filteredItems.count
    }
    
    
    //MARK: - SETTERS
    public func setFilteredItems(filteredItems : Array<Item>){
        self.filteredItems = filteredItems
    }
    
    
    //MARK: - APPENDS
    public func appendToFilteredItems(item : Item){
        filteredItems.append(item)
    }
    
    public func appendToItems(item : Item){
        items.append(item)
    }
    
    //MARK: - REMOVE
    public func removeToItems(index : Int){
        self.items.remove(at: index)
    }
    
    
    //MARK: - Save/Load data
    class var url: URL {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DoIt")
            .appendingPathExtension("json")
    }
    
    
    public func saveData() {
        saveContext()
        
    }
    
    
    
    public func loadData() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            items = try context.fetch(fetchRequest)
        } catch {
            debugPrint("Could not load items from CoreData")
        }
    }
    
    
    //MARK : - Remove to coreData
    public func remove(atIndex index: Int) {
        let item = self.items[index]
        
        context.delete(item)
        saveData()
    }
    
    
    //MARK: - Move items in datas after moving them in tableView
    public func moveItem(to sourceIndex : Int, at destinationIndex : Int){
        let sourceItem = items.remove(at: sourceIndex)
        items.insert(sourceItem, at: destinationIndex)
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DoIt-CoreData-KOPEC")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

