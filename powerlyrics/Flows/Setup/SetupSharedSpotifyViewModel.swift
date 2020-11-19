//
//  SetupSharedSpotifyViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/19/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - LoginResult

enum LoginResult<T: Error> {
    
    case ok(isLoading: Bool)
    case fail(T)
    
}

// MARK: - LoginError

enum LoginError: Error {
    
    case underage
    case networkError
    
}

typealias DefaultLoginErrorAction = (LoginError) -> Void

// MARK: - SetupSharedSpotifyViewModel

class SetupSharedSpotifyViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    let keychainService: KeychainServiceProtocol
    
    // MARK: - Observables
    
    let loginState = PassthroughSubject<LoginResult<LoginError>, Never>()
    
    // MARK: - Init
    
    init(
        spotifyProvider: SpotifyProvider,
        realmService: RealmServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
        self.keychainService = keychainService
    }
    
    // MARK: - Helper methods
    
    func appDidOpenURL(url: URL) {
        
        spotifyProvider.logout(reset: false)
        
        spotifyProvider.handle(url: url) { [weak self] in
            self?.loginState.on(.next(.ok(isLoading: true)))
            self?.loadUserData { [weak self] in
                guard let self = self else { return }
                self.loginState.on(.next(.ok(isLoading: false)))
                NotificationCenter.default.post(name: .appDidLogin, object: nil, userInfo: nil)
            } failure: { [weak self] error in
                guard let self = self else { return }
                self.spotifyProvider.logout(reset: true)
                self.loginState.on(.next(.fail(error)))
            }
        }
        
    }
    
    func loadUserData(success: @escaping DefaultAction, failure: @escaping DefaultLoginErrorAction) {
        spotifyProvider.reactive
            .request(.userInfo)
            .map(SpotifyUserInfoResponse.self)
            .start { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .value(let response):
                    if response.explicitContent.filterEnabled == true && response.explicitContent.filterLocked == true {
                        failure(.underage)
                        return
                    }
                    
                    self.realmService.saveUserData(spotifyUserInfo: response)
                    self.keychainService.setEncodable(true, for: .spotifyAuthorizedWithAccount)
                    success()
                case .failed:
                    failure(.networkError)
                default:
                    break
                }
            }
    }
    
}
