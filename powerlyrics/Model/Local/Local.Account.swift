//
//  Local.Account.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//

import Foundation
import RealmSwift

extension Local {
    
    class Account: Object {
        @objc dynamic var name = ""
        @objc dynamic var premium = false
        @objc dynamic var over18 = false
    }
    
}
