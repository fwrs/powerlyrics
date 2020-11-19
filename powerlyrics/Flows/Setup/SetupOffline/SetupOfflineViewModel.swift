//
//  SetupOfflineViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - SetupOfflineValidationError

enum SetupOfflineValidationError: Error {
    
    case under18
    case nameEmpty
    
}

// MARK: - SetupOfflineNetworkError

enum SetupOfflineNetworkError: Error {
    
    case networkFailed
    
}

// MARK: - SetupOfflineError

enum SetupOfflineError: Error {
    
    case validation(SetupOfflineValidationError)
    case network(SetupOfflineNetworkError)
    
}

// MARK: - SetupOfflineViewModel

class SetupOfflineViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Observables
    
    let loginState = PassthroughSubject<Bool, SetupOfflineError>()
    
    // MARK: - Init
    
    init(spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
    }
    
    // MARK: - Helper methods
    
    func validate(name: String, over18: Bool) -> SetupOfflineValidationError? {
        if name.isEmpty {
            return .nameEmpty
        }
        
        if !over18 {
            return .under18
        }
        
        return nil
    }
    
    func login(name: String, over18: Bool) {
        if let error = validate(name: name, over18: over18) {
            loginState.on(.failed(.validation(error)))
            return
        }
        
        realmService.saveUserData(name: name, over18: over18)
        
        loginState.on(.next(true))
        
        spotifyProvider.loginWithoutUser { [weak self] success in
            guard let self = self else { return }
            if success {
                self.loginState.on(.next(false))
                NotificationCenter.default.post(name: .appDidLogin, object: nil, userInfo: nil)
            } else {
                self.loginState.on(.failed(.network(.networkFailed)))
                self.realmService.unsetUserData()
            }
        }
    }
    
}
