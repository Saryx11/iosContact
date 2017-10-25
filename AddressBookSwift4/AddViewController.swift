//
//  AddViewController.swift
//  AddressBookSwift4
//
//  Created by Benjamin LOUIS on 25/10/2017.
//  Copyright © 2017 Benjamin LOUIS. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    weak var delegate: AddViewControllerDelegate?
    
    @IBOutlet weak var nomTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didPressValid(_ sender: Any) {
        guard let text: String = nomTextField.text else{
            return
        }
        print(text)
        delegate?.createContact(name: text)
        //self.navigationController?.popViewController(animated: true)
        
        
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

protocol AddViewControllerDelegate : AnyObject{
    
    func createContact(name : String)
}




