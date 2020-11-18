//
//  SpotifyProvider.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Moya
import RealmSwift
import SafariServices
import Swinject
import UIKit

typealias SpotifyProvider = MoyaProvider<Spotify>

extension SpotifyProvider {
    
    private static let keychain: KeychainStorageProtocol = Config.getResolver().resolve(KeychainStorageProtocol.self)!
    
    private static var token: SpotifyToken? {
        get {
            keychain.getDecodable(for: .spotifyToken)
        }
        set {
            keychain.setEncodable(newValue, for: .spotifyToken)
        }
    }

    static func spotifyRefreshFlowHandler() -> MoyaProvider<Target>.RequestClosure {
        { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            
            if let accessToken = token?.accessToken, token?.isExpired == false {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else if let data = "\(Tokens.Spotify.clientID):\(Tokens.Spotify.clientSecret)".data(using: .utf8) {
                request.setValue("Basic \(data.base64EncodedString(options: []))", forHTTPHeaderField: "Authorization")
            }
            
            guard let currentToken = token else {
                return closure(.success(request))
            }
            
            if !currentToken.isExpired || endpoint.url.contains("/api/token") {
                closure(.success(request))
                return
            }

            Config.getResolver().resolve(SpotifyProvider.self)!.request(currentToken.refreshToken == nil ? .newLocalToken : .refreshToken(oldToken: currentToken)) { result in
                switch result {
                case .success(let response):
                    token = SpotifyToken(data: response.data, refreshToken: token?.refreshToken) ?? token
                    request.setValue("Bearer \((token?.accessToken).safe)", forHTTPHeaderField: "Authorization")
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
            let code = queryItems.first(where: { item in item.name == "code" })?.value {
            
            Config.getResolver().resolve(SpotifyProvider.self)!.request(.newToken(authCode: code)) { result in
                if case .success(let response) = result {
                    SpotifyProvider.token = SpotifyToken(data: response.data)
                    finished?()
                }
            }
        }
    }
    
    func login(from presentingViewController: UIViewController) {
        if let url = URL(string: "https://accounts.spotify.com/authorize")?.with(
            parameters: [
                "client_id": Tokens.Spotify.clientID,
                "response_type": "code",
                "redirect_uri": Tokens.Spotify.redirectURL,
                "scope": "user-read-private user-read-email user-library-modify user-library-read user-read-currently-playing user-read-playback-state"
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
        Config.getResolver().resolve(SpotifyProvider.self)!.request(.newLocalToken) { result in
            if case .success(let response) = result {
                SpotifyProvider.token = SpotifyToken(data: response.data)
                completion(true)
                SpotifyProvider.keychain.setEncodable(false, for: .spotifyAuthorizedWithAccount)
                return
            }
            completion(false)
        }
    }
    
    func logout(reset: Bool = true) {
        SpotifyProvider.token = nil
        SpotifyProvider.keychain.delete(for: .spotifyToken)
        SpotifyProvider.keychain.delete(for: .spotifyAuthorizedWithAccount)
        
        Realm.unsetUserData(reset: reset)
    }
    
    var loggedIn: Bool {
        SpotifyProvider.token != nil
    }
        
}
