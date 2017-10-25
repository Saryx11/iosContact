//
//  Person.swift
//  AddressBookSwift4
//
//  Created by Benjamin LOUIS on 25/10/2017.
//  Copyright © 2017 Benjamin LOUIS. All rights reserved.
//

import Foundation
class Person{
    var familyName: String
    var lastName: String
    init(){
        self.familyName = ""
        self.lastName = ""
    }
    init(familyName: String, lastName: String){
        self.familyName = familyName
        self.lastName = lastName
    }
}
