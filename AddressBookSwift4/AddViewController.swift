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
    @IBOutlet weak var familyNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addProgressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    var progress: Float=0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didPressValid(_ sender: Any) {
       
            showProgress()
    }
    
    func createPerson () {
        guard let familyName: String = familyNameTextField.text, let lastName: String = lastNameTextField.text else{
            return
        }
        delegate?.createContact(familyName: familyName, lastName: lastName)
    }
    
    func showProgress(){
        DispatchQueue.global(qos: .userInteractive).async {
            while self.progress<1{
                Thread.sleep(forTimeInterval: 0.1)
                DispatchQueue.main.async {
                    self.addProgressBar.setProgress(self.progress,animated: true)
                    self.progressLabel.text = String(self.progress)
                }
                self.progress += 0.1
            }
            DispatchQueue.main.async{
             self.createPerson()
            }
        }
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
    
    func createContact(familyName: String, lastName: String)
}




