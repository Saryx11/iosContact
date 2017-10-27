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
    
    /*func reloadDataFromDataBase(){
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
     //self.tableView.reloadData()
     }*/
    var resultController: NSFetchedResultsController<Person>!
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
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName, sortLastName]
        
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate().persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDataFromServer()
        // reloadDataFromDataBase()
    }
    
    @objc func addContactPress(){
        let addContactView = AddViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(addContactView, animated: true)
        addContactView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     //return 1
     }*/
    
    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> Int{
     return 55
     }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsViewController = DetailsViewController(nibName: nil, bundle: nil)
        guard let person = self.resultController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        detailsViewController.person = person
        self.navigationController?.pushViewController(detailsViewController, animated: true)
        detailsViewController.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath)
        
        if let contactCell = cell as? ContactsTableViewCell{
            guard let person = self.resultController?.object(at: indexPath) else {
                fatalError("Attempt to configure cell without a managed object")
            }
            contactCell.nameLabel.text = person.firstName! + " " + person.lastName!
        }
        // Configure the cell...
        
        return cell
    }
    
    func updateDataFromServer(){
        let urlString = "http://192.168.116.2:3000/persons"
        guard let requestUrl = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: requestUrl) {
            (data, response, error) in
            if error == nil,let usableData = data {
                //JSONSerialization
                let dictionary = try? JSONSerialization.jsonObject(with: usableData, options: JSONSerialization.ReadingOptions.mutableContainers)
                guard let jsonDict = dictionary as? [[String: Any]]else{
                    return
                }
                DispatchQueue.main.async {
                    self.updateFromJsonData(json: jsonDict)
                    
                    /*let context = self.appDelegate().persistentContainer.viewContext
                     for personObject in jsonDict{
                     let person = Person(entity: Person.entity(), insertInto: context)
                     person.firstName = personObject["surname"] as? String ?? "DefaultName"
                     person.lastName = personObject["lastname"] as? String ?? "DefaultName"
                     }
                     try? self.appDelegate().persistentContainer.viewContext.save()*/
                }
            }
        }
        task.resume()
    }
    
    func updateFromJsonData(json: [[String: Any]]){
        let sort = NSSortDescriptor(key: "id", ascending: true)
        let fetchrequest = NSFetchRequest<Person>(entityName: "Person")
        fetchrequest.sortDescriptors = [sort]
        
        let context = self.appDelegate().persistentContainer.viewContext
        let persons = try! context.fetch(fetchrequest)
        let personIds = persons.map({(person) -> Int32 in
            return person.id
        })
        let serversId = json.map{(dict)->Int in
            return dict["id"] as? Int ?? 0
        }
        //delete if not on server
        for person in persons{
            if !serversId.contains(Int(person.id)){
                context.delete(person)
            }
        }
        //Update or create
        for jsonPerson in json{
            let id = jsonPerson["id"] as? Int ?? 0
            if let index = personIds.index(of: Int32(id)){
                persons[index].lastName = jsonPerson["lastname"] as? String ?? "ERROR"
                persons[index].firstName = jsonPerson["surname"] as? String ?? "ERROR"
                persons[index].avatarURL = jsonPerson["pictureUrl"] as? String
            }else{
                let person = Person(context: context)
                person.lastName = jsonPerson["lastname"] as? String
                person.firstName = jsonPerson["surname"] as? String
                person.avatarURL = jsonPerson["pictureUrl"] as? String
                person.id = Int32(id)
            }
        }
        do{
            if context.hasChanges{
                try context.save()
            }
        }catch{
            print(error)
        }
    }
    
    func addOnServer(person: Person){
        var json = [String:String]()
        
        json["surname"] = person.firstName
        json["lastname"] = person.lastName
        json["pictureUrl"] = "https://www.raidghost.com/sources/avatar_defaut.png"
        let urlString = "http://192.168.116.2:3000/persons"
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        let task = session.dataTask(with: request){ data, response, error in
            
            if let data = data{
                
                let jsonDict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                guard let dict = jsonDict as? [String: Any]else{
                    return
                }
                DispatchQueue.main.async {
                    let personFromjson = Person(entity: Person.entity(), insertInto: self.appDelegate().persistentContainer.viewContext)
                    personFromjson.lastName = dict["surname"] as? String
                    personFromjson.firstName = dict["lastname"] as? String
                    personFromjson.avatarURL = dict["pictureUrl"] as? String
                    personFromjson.id = Int32(dict["id"] as? Int ?? 0)
                    try? self.appDelegate().persistentContainer.viewContext.save()
                }
                
            }
            
        }
        task.resume()
    }
    func deleteOnServer(person: Person){
    
        
       
        let urlString = "http://192.168.116.2:3000/persons/" + String(person.id)
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let task = session.dataTask(with: request){ data, response, error in
            if let data = data{
                let jsonDict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                guard let dict = jsonDict as? [String: Any]else{
                    return
                }
            }
        }
        task.resume()
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
            
            addOnServer(person: person)
            navigationController?.popViewController(animated: true)
            //tableView.reloadData()
        }
    }
}
extension ContactsTableViewController: DetailsViewControllerDelegate{
    func deleteContact(person: Person){
        let context = self.appDelegate().persistentContainer.viewContext
        deleteOnServer(person: person)
        context.delete(person)
        try? context.save()
        navigationController?.popViewController(animated: true)
        //tableView.reloadData()
    }
}

extension ContactsTableViewController: NSFetchedResultsControllerDelegate{
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = resultController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return resultController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = resultController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        tableView.reloadData()
    }
    
    /*func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     tableView.beginUpdates()
     }*/
    
}

