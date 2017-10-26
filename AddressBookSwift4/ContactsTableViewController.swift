//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Benjamin LOUIS on 25/10/2017.
//  Copyright © 2017 Benjamin LOUIS. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
    var persons = [Person]()

    func reloadDataFromDataBase(){
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName, sortLastName]
        let context = self.appDelegate().persistentContainer.viewContext
        //print(try? context.fetch(fetchRequest))
        guard let personsDB = try? context.fetch(fetchRequest) else{
            return
        }
        persons=personsDB
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* HOW TO USE PLIST FILES
         let namesPlist = Bundle.main.path(forResource: "names.plist", ofType: nil)
        if let namesPath = namesPlist{
            let url = URL(fileURLWithPath: namesPath)
            let dataArray = NSArray(contentsOf: url)
            
            for dict in dataArray!{
                if let dictionnary = dict as?[String: String]{
                    let person = Person(firstName: dictionnary["lastname"]!, lastName: dictionnary["name"]!)
                    persons.append(person)
                    print(dictionnary)
                }
            }
            print(dataArray)
        }*/
        self.title = "Contacts"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadDataFromDataBase()
    }

    @objc func addContactPress(){
        let addContactView = AddViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(addContactView, animated: true)
        addContactView.delegate = self
        //create and push addViewController
        //set the delegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return persons.count
    }
    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> Int{
        return 55
    }*/

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsViewController = DetailsViewController(nibName: nil, bundle: nil)
        let person = persons[indexPath.row]
        detailsViewController.person = person
        self.navigationController?.pushViewController(detailsViewController, animated: true)
        detailsViewController.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath)

        if let contactCell = cell as? ContactsTableViewCell{
            let person: Person = persons[indexPath.row]
            contactCell.nameLabel.text = person.firstName! + " " + person.lastName!
        }
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContactsTableViewController: AddViewControllerDelegate{
    func createContact(firstName: String, lastName: String) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let person = Person(entity: Person.entity(), insertInto: context)
            person.firstName = firstName
            person.lastName = lastName
            do{
                try context.save()
            }catch{
                print(error.localizedDescription)
            }
            navigationController?.popViewController(animated: true)
            tableView.reloadData()
        }
    }
}
extension ContactsTableViewController: DetailsViewControllerDelegate{
    func deleteContact(person: Person){
        let context = self.appDelegate().persistentContainer.viewContext
        context.delete(person)
        try? context.save()
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}

