//
//  ViewController.swift
//  Todoist
//
//  Created by Ervin on 3/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = ["Purchase iPhone XS", "Figure out Core Data", "Watch Google's Event"]
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = userDefaults.array(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }
    }
    
    //MARK: - Add Button Tapped
    @IBAction func addButtonTapped(_ sender: Any) {
                    print(itemArray)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add To-do", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter your to-do"
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let userInput = textField.text {
                guard userInput != "" else { return }
                self.itemArray.append(userInput)
                self.userDefaults.set(self.itemArray, forKey: "TodoListArray")
            }
            self.tableView.reloadData()
            print(self.itemArray)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}



extension ToDoListViewController {

    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    
    //MARK: - TableView Delegate Interactions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

