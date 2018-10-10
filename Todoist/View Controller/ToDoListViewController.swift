//
//  ViewController.swift
//  Todoist
//
//  Created by Ervin on 3/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    //MARK: - Global Variables + Lifecycle Method
    var itemArray = [ToDoItem]()
    var selectedCategory: Category? {
        didSet {
            let categoryRequest = getCategoryRequest()
            loadArrayWithRequest(named: categoryRequest)
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: TableView Delegate 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isChecked = !itemArray[indexPath.row].isChecked
        
        saveArrayToContext()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - CoreData Methods
    func saveArrayToContext() {
        do {
            try context.save()
        } catch {
            print("Error saving to-do to context: \(error)")
        }
    }

    func loadArrayWithRequest(named request: NSFetchRequest<ToDoItem>?) {
        if let request = request {
            do {
                itemArray = try context.fetch(request)
            } catch {
                print("Error fetching to-do with request: \(error)")
            }
        } else {
            let defaultRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            itemArray = try! context.fetch(defaultRequest)
        }
        self.tableView.reloadData()
    }
    
    func getSearchRequest(from searchBar: UISearchBar) -> NSFetchRequest<ToDoItem> {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        if let userInput = searchBar.text {
            
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [
                NSPredicate(format: "title CONTAINS[cd] %@", userInput),
                NSPredicate(format: "parentCategory.name MATCHES[cd] %@", selectedCategory!.name!)])
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        return request
    }
    
    func getCategoryRequest() -> NSFetchRequest<ToDoItem> {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        if let selectedCategory = selectedCategory {
            request.predicate = NSPredicate(format: "parentCategory.name MATCHES[cd] %@", selectedCategory.name!)
        }
        return request
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
                let newToDo = ToDoItem(context: self.context)
                newToDo.title = userInput
                newToDo.isChecked = false
                newToDo.parentCategory = self.selectedCategory
                self.itemArray.append(newToDo)
                self.saveArrayToContext()
                
                self.tableView.reloadData()
                print(self.itemArray)
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
        
        if searchBar.text?.count == 0 {
            hideKeyboard(searchBar)
            let request = getCategoryRequest()
            loadArrayWithRequest(named: request)
        } else {
            hideKeyboard(searchBar)
            let request = getSearchRequest(from: searchBar)
            loadArrayWithRequest(named: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            let request = getCategoryRequest()
            loadArrayWithRequest(named: request)
        } else {
            let request = getSearchRequest(from: searchBar)
            loadArrayWithRequest(named: request)
        }
    }
}

