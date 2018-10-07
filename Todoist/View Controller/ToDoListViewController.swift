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
    
    var itemArray = [ToDoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        self.loadArrayFromContext()
        
    }
    
    //MARK: - Add Button Tapped
    @IBAction func addButtonTapped(_ sender: Any) {
        print(self.itemArray)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add To-do", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter your to-do"
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let userInput = textField.text {
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
    
    func saveArrayToContext() {
        do {
            try context.save()
        } catch {
            print("Error saving to-do to context: \(error)")
        }
    }
    
    func loadArrayFromContext() {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        do {
        itemArray = try context.fetch(request)
        } catch {
            print("Error fetching to-do from context: \(error)")
        }
    }
    

}


extension ToDoListViewController {

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
    
    
    //MARK: - TableView Delegate Interactions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isChecked = !itemArray[indexPath.row].isChecked
        saveArrayToContext()
    
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}

