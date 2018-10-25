//
//  ViewController.swift
//  Todoist
//
//  Created by Ervin on 3/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    //MARK: - Global Variables + Lifecycle Method
    var toDoItemsArray: Results<ToDoItem>?
    var selectedCategory: Category? {
        didSet {
            loadToDoItems()
        }
    }
    var itemArray = [ToDoItem]()
    let realm = try! Realm()
    var alertTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - User Interactions Methods
    @IBAction func addButtonTapped(_ sender: Any) {
        presentAlert(alertTextField)
    }
    
    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItemsArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        
        if let item = toDoItemsArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isChecked ? .checkmark : .none
        }
        
        return cell
    }
    
    
    //MARK: TableView Delegate 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItemsArray?[indexPath.row] {
            
            do {
                try realm.write {
                    item.isChecked = !item.isChecked
                }
            } catch {
                print("Error updating isChecked property, \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    func loadToDoItems() {
        
        toDoItemsArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
    }
    
    
    //MARK: - Helper Methods for Table View
    func hideKeyboard(_ object: UIView) {
        DispatchQueue.main.async {
            object.resignFirstResponder()
            
        }
    }
    
    func presentAlert(_ textfield: UITextField) {
        let alert = UIAlertController(title: "Add To-do", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter your to-do"
            self.alertTextField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let userInput = self.alertTextField.text {
                guard userInput != "" else { return }
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newToDo = ToDoItem()
                            newToDo.title = userInput
                            newToDo.isChecked = false
                            newToDo.dateCreated = Date(timeIntervalSinceNow: 0)
                            currentCategory.items.append(newToDo)
                        }
                    } catch {
                        print("Error saving new to-dos to Realm: \(error)")
                    }
                }
                
                self.loadToDoItems()
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: -
extension ToDoListViewController: UISearchBarDelegate {
    
    //MARK: - SearchBar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearchQuery(with: searchBar)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearchQuery(with: searchBar)
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func performSearchQuery(with searchBar: UISearchBar) {
        if let userInput = searchBar.text {
            if userInput.count != 0 {
                loadToDoItems()
                toDoItemsArray = toDoItemsArray?.filter("title CONTAINS[cd] %@", userInput).sorted(byKeyPath: "dateCreated", ascending: true)
                tableView.reloadData()
            } else {
                loadToDoItems()
                tableView.reloadData()
            }
        }
    }
}
