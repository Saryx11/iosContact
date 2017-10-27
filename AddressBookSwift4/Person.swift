//
//  Person.swift
//  AddressBookSwift4
//
//  Created by Benjamin LOUIS on 26/10/2017.
//  Copyright © 2017 Benjamin LOUIS. All rights reserved.
//

import Foundation

extension Person{
    var firstLetter: String{
        if let first = lastName?.characters.first{
            return String(first)
        }else{
            return "?"
        }
    }
    
}
