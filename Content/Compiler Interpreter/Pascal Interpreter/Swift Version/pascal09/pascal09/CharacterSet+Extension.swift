//
//  CharacterSet+Extension.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation

extension CharacterSet {
    func contains(_ c:Character) -> Bool {
        let scalars = String(c).unicodeScalars
        guard scalars.count == 1 else {
            return false
        }
        return contains(scalars.first!)
    }
}

extension Character {
    func isspace()->Bool {
        return CharacterSet.whitespacesAndNewlines.contains(self)
    }
    
    func isdigit()->Bool {
        return CharacterSet.decimalDigits.contains(self)
    }
    
    func isalnum()->Bool {
        return CharacterSet.alphanumerics.contains(self)
    }
    
    func isalpha()->Bool{
        return CharacterSet.letters.contains(self)
    }
    
}
