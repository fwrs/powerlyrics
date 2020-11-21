//
//  SpotifyProvider.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Moya
import SafariServices
import Swinject

// MARK: - Constants

fileprivate extension Constants {
    
    static let authorizationHeader = "Authorization"
    static let authorizationBasic = "Basic"
    static let authorizationBearer = "Bearer"
    
    static let code = "code"
    static let scopes = "user-read-private user-read-email user-library-modify user-library-read user-read-currently-playing user-read-playback-state"
    static let authorizeURL = "https://accounts.spotify.com/authorize"
    
}

// MARK: - SpotifyProvider

typealias SpotifyProvider = MoyaProvider<Spotify>

extension SpotifyProvider {
    
    static let keychainService: KeychainServiceProtocol = Config.getResolver().resolve(KeychainServiceProtocol.self)!
    
    var keychainService: KeychainServiceProtocol {
        SpotifyProvider.keychainService
    }
    
    static let realmService: RealmServiceProtocol = Config.getResolver().resolve(RealmServiceProtocol.self)!
    
    var realmService: RealmServiceProtocol {
        SpotifyProvider.realmService
    }
    
    static var token: SpotifyToken? {
        get {
            keychainService.getDecodable(for: .spotifyToken)
        }
        set {
            keychainService.setEncodable(newValue, for: .spotifyToken)
        }
    }

    static func spotifyRefreshFlowHandler() -> MoyaProvider<Target>.RequestClosure {
        { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            
            if let accessToken = token?.accessToken, token?.isExpired == false {
                request.setValue(
                    "\(Constants.authorizationBearer) \(accessToken)",
                    forHTTPHeaderField: Constants.authorizationHeader
                )
            } else if let data = "\(Tokens.Spotify.clientID):\(Tokens.Spotify.clientSecret)".data(using: .utf8) {
                request.setValue(
                    "\(Constants.authorizationBasic) \(data.base64EncodedString(options: []))",
                    forHTTPHeaderField: Constants.authorizationHeader
                )
            }
            
            guard let currentToken = token else {
                return closure(.success(request))
            }
            
            if !currentToken.isExpired || endpoint.url.contains(Spotify.newLocalToken.path) {
                closure(.success(request))
                return
            }

            Config.getResolver().resolve(SpotifyProvider.self)!.request(currentToken.refreshToken == nil ? .newLocalToken : .refreshToken(oldToken: currentToken)) { result in
                switch result {
                case .success(let response):
                    token = SpotifyToken(data: response.data, refreshToken: token?.refreshToken) ?? token
                    request.setValue("\(Constants.authorizationBearer) \((token?.accessToken).safe)", forHTTPHeaderField: Constants.authorizationHeader)
                    closure(.success(request))
                case .failure(let error):
                    closure(.failure(error))
                }
            }
        }
    }
    
    func handle(url: URL, finished: DefaultAction?) {
        if let urlComponents = URLComponents(string: url.absoluteString),
            let queryItems = urlComponents.queryItems,
            let code = queryItems.first(where: { item in item.name == Constants.code })?.value {
            
            request(.newToken(authCode: code)) { result in
                if case .success(let response) = result {
                    SpotifyProvider.token = SpotifyToken(data: response.data)
                    finished?()
                }
            }
        }
    }
    
    func login(from presentingViewController: UIViewController) {
        if let url = URL(string: Constants.authorizeURL)?.with(
            parameters: [
                "client_id": Tokens.Spotify.clientID,
                "response_type": Constants.code,
                "redirect_uri": Tokens.Spotify.redirectURL,
                "scope": Constants.scopes
            ]
        ) {
            DispatchQueue.main.async {
                let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
                safariViewController.preferredControlTintColor = .tintColor
                safariViewController.dismissButtonStyle = .cancel
                presentingViewController.present(safariViewController, animated: true)
            }
        }
    }
    
    func loginWithoutUser(completion: @escaping DefaultBoolAction) {
        request(.newLocalToken) { [weak self] result in
            if case .success(let response) = result {
                SpotifyProvider.token = SpotifyToken(data: response.data)
                completion(true)
                self?.keychainService.setEncodable(false, for: .spotifyAuthorizedWithAccount)
                return
            }
            completion(false)
        }
    }
    
    func logout(reset: Bool = true) {
        SpotifyProvider.token = nil
        keychainService.delete(for: .spotifyToken)
        keychainService.delete(for: .spotifyAuthorizedWithAccount)
        
        realmService.unsetUserData(reset: reset)
    }
    
    var loggedIn: Bool {
        SpotifyProvider.token != nil
    }
        
}
