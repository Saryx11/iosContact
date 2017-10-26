//
//  DetailsViewController.swift
//  AddressBookSwift4
//
//  Created by Benjamin LOUIS on 25/10/2017.
//  Copyright © 2017 Benjamin LOUIS. All rights reserved.
//

import UIKit

protocol DetailsViewControllerDelegate: AnyObject{
    func deleteContact(index: Int)
}



class DetailsViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    var index: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    weak var delegate: DetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deleteContact = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContactPress))
        self.navigationItem.rightBarButtonItem = deleteContact
        firstNameLabel.text = self.firstName
        lastNameLabel.text = self.lastName
        // Do any additional setup after loading the view.
    }

    @objc func deleteContactPress(){
        let alertController = UIAlertController(title: "Supprimer", message: "Voulez-vous vraiment supprimer ce contact ?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Non", style: .cancel){action in
            
        }
        let okAction = UIAlertAction(title: "Oui", style: .default){action in
            self.delegate?.deleteContact(index: self.index)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

