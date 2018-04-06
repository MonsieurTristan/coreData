//
//  ListViewController.swift
//  DoIt
//
//  Created by Tristan on 30/03/2018.
//  Copyright © 2018 Tristan. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    
    //MARK : - VARS
    var isSearching = false
    
    //MARK : - MANAGERS
    let dataManager : DataManagerProtocol = DataManager.shared
    
    
    
    //MARK : - OUTLETS
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    
    
    //MARK : - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.contentOffset = CGPoint(x: 0, y: 44)
        
    }
    
    
    
    //MARK: - Actions
    @IBAction func addAction(_ sender: Any) {
        let alertController = UIAlertController(title: "DoIt", message: "New Item", preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Name"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if let name = alertController.textFields?[0].text, name != ""{
                let item = Item(context: DataManager.shared.persistentContainer.viewContext)
                item.name = alertController.textFields?[0].text
                item.checked = false
                self.dataManager.appendToItems(item: item)
                self.dataManager.setFilteredItems(filteredItems: self.dataManager.getAllItems())
                self.searchBarSearchButtonClicked(self.searchBar)
                self.searchBar.text? = ""
                self.tableView.reloadData()
                self.dataManager.saveData()
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func editAction(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        let button = sender as! (UIBarButtonItem)
        button.title = tableView.isEditing ? "Done" : "Edit"
        if (tableView.isEditing == false) {
            dataManager.saveData()
        }
    }
    
 
    
    
}



//MARK: - TableViewDataSource
//MARK: - TableViewDelegate
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - UITableViewDataSource
    
    // Number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? self.dataManager.getCountFilteredItems() : self.dataManager.getCountItems()
    }
    
    // Create cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        let item = isSearching ? self.dataManager.getFilteredItemsByIndex(index: indexPath.row) : self.dataManager.getItemsByIndex(index: indexPath.row)
        cell?.textLabel?.text = item.name
        cell?.accessoryType = item.checked ? .checkmark : .none
        
        return cell!
    }
    
    // Remove an item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (!isSearching && editingStyle == .delete) {
            self.dataManager.remove(atIndex: indexPath.row)
            self.dataManager.removeToItems(index : indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isSearching
    }
    
    // Move an item
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.dataManager.moveItem(to: sourceIndexPath.row, at: destinationIndexPath.row)
    }
    
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let item = self.dataManager.getItemsByIndex(index: indexPath.row)
        item.checked = !item.checked
        cell?.accessoryType = item.checked ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dataManager.saveData()
        
    }
    
}



//MARK: - SearchBarDelegate
extension ListViewController : UISearchBarDelegate, UITextFieldDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        editButton.isEnabled = true
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty) {
            self.dataManager.setFilteredItems(filteredItems: self.dataManager.getAllItems().filter { (item) in
                return (item.name?.lowercased().contains(searchText.lowercased()))!
            })
        } else {
            self.dataManager.setFilteredItems(filteredItems: self.dataManager.getAllItems())
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        editButton.isEnabled = false
        searchBar.enablesReturnKeyAutomatically = false
    }
    
}






