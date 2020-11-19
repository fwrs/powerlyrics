//
//  Notifications.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/19/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

public extension Notification.Name {
    
    static let appDidLogin = Notification.Name("appDidLogin")
    
    static let appDidLogout = Notification.Name("appDidLogout")
    
    static let appDidOpenURL = Notification.Name("appDidOpenURL")
    
}

public enum NotificationKey: String {
    
    case url
    
}
