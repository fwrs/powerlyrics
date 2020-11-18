//
//  RealmAccount.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAccount: Object {
    @objc dynamic var name = ""
    @objc dynamic var premium = false
    @objc dynamic var over18 = false
    @objc dynamic var registerDate = Date()
    @objc dynamic var avatarURL: String?
    @objc dynamic var thumbnailAvatarURL: String?
}
