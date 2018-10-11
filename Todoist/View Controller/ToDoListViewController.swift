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
    var toDoItems: Results<ToDoItem>?
    var selectedCategory: Category? {
        didSet {
            loadToDoItems()
        }
    }
    
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
        return toDoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isChecked ? .checkmark : .none
        }
        
        return cell
    }
    
    
    //MARK: TableView Delegate 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        //        toDoItems?[indexPath.row].isChecked = !toDoItems?[indexPath.row].isChecked
        //
        //        save(toDoItem: toDoItems?[indexPath.row])
        //
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Realm Methods
    //    func save(toDoItem: ToDoItem) {
    //        do {
    //            try realm.write {
    //                realm.add(toDoItem)
    //            }
    //        } catch {
    //            print("Error saving to-do to Realm: \(error)")
    //        }
    //    }
    
    func loadToDoItems() {
        toDoItems = realm.objects(ToDoItem.self).sorted(byKeyPath: "title", ascending: true)
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
        //
        //        if searchBar.text?.count == 0 {
        //            hideKeyboard(searchBar)
        //            let request = getCategoryRequest()
        //            loadArrayWithRequest(named: request)
        //        } else {
        //            hideKeyboard(searchBar)
        //            let request = getSearchRequest(from: searchBar)
        //            loadArrayWithRequest(named: request)
        //        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        if searchBar.text?.count == 0 {
        //            let request = getCategoryRequest()
        //            loadArrayWithRequest(named: request)
        //        } else {
        //            let request = getSearchRequest(from: searchBar)
        //            loadArrayWithRequest(named: request)
        //        }
        //    }
    }
    
}
