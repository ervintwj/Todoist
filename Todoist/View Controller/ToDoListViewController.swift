//
//  ViewController.swift
//  Todoist
//
//  Created by Ervin on 3/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Table View Controller
class ToDoListViewController: UITableViewController {
    
    //MARK: - Global Variables + ViewDidLoad Method
    var itemArray = [ToDoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var alertTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadArrayFromContext()
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
    
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isChecked = !itemArray[indexPath.row].isChecked
        
        //        COREDATA: DESTROY FROM CONTEXT
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
        saveArrayToContext()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Core Data – Saving and Loading
    func saveArrayToContext() {
        do {
            try context.save()
        } catch {
            print("Error saving to-do to context: \(error)")
        }
    }
    
    func loadArrayFromContext() {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        fetchArrayWithRequest(named: request)
        
    }
    
    //MARK:  Helper Methods for Table View
    func fetchArrayWithRequest(named request: NSFetchRequest<ToDoItem>) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching to-do with request: \(error)")
        }
        tableView.reloadData()
    }
    
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

//MARK: - SearchBar Delegate
extension ToDoListViewController: UISearchBarDelegate {
    
    //MARK: - SearchBar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count == 0 {
            hideKeyboard(searchBar)
            loadArrayFromContext()
        } else {
            let request = getSearchRequest(from: searchBar)
            hideKeyboard(searchBar)
            fetchArrayWithRequest(named: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadArrayFromContext()
        } else {
            let request = getSearchRequest(from: searchBar)
            fetchArrayWithRequest(named: request)
        }
    }
    
    //MARK: - Helper Methods for Search Bar
    func getSearchRequest(from searchBar: UISearchBar) -> NSFetchRequest<ToDoItem> {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        if let userInput = searchBar.text {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", userInput)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        return request
    }
    
}

