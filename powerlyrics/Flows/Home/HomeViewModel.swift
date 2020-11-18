//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import ReactiveKit
import RealmSwift

enum HomeSection: Equatable {
    case nowPlaying
    case trending
    case viral
    case likedToday
    
    var localizedTitle: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .trending:
            return "Trending"
        case .viral:
            return "Viral"
        case .likedToday:
            return "Liked Today"
        }
    }
}

class HomeViewModel: ViewModel {
    
    let spotifyProvider: SpotifyProvider
    
    let items = MutableObservableArray2D(Array2D<HomeSection, HomeCell>())
    
    private var currentlyPlayingSong = [SharedSong]()
    
    var trendingSongs = [SharedSong]()
    
    var viralSongs = [SharedSong]()
    
    let isError = Observable(false)
    
    let isSpotifyAccount = Observable(true)
    
    init(spotifyProvider: SpotifyProvider) {
        self.spotifyProvider = spotifyProvider
    }
    
    var shouldSignUp: Bool {
        !spotifyProvider.loggedIn
    }
    
    private var fails = true
    
    func checkSpotifyAccount() {
        let isSpotifyAccount: Bool? = (Config.getResolver().resolve(KeychainStorageProtocol.self)!.getDecodable(for: .spotifyAuthorizedWithAccount) as Bool?)
        
        self.isSpotifyAccount.value = isSpotifyAccount == true
    }

    func loadData(refresh: Bool = false) {
        startLoading(refresh)
        isError.value = false
        
        let group = DispatchGroup()
        
        fails = true
        
        group.enter()
        spotifyProvider.reactive
            .request(.playerStatus)
            .map(SpotifyPlayingContextResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    currentlyPlayingSong = [response.item.asSharedSong]
                    group.leave()
                    fails = false
                case .failed:
                    currentlyPlayingSong = .init()
                    group.leave()
                default:
                    break
                }
            }
        
        group.enter()
        spotifyProvider.reactive
            .request(.trendingSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    trendingSongs = response.items.map(\.asSharedSong)
                    group.leave()
                    fails = false
                case .failed:
                    group.leave()
                default:
                    break
                }
            }
        
        group.enter()
        spotifyProvider.reactive
            .request(.viralSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    viralSongs = response.items.map(\.asSharedSong)
                    group.leave()
                    fails = false
                case .failed:
                    group.leave()
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [self] in
            endLoading(refresh)
            
            updateState()
        }
    }
    
    func updateState() {
        if fails {
            isError.value = true
            items.set([])
            return
        }
        
        let currentlyPlayingSongsSection = currentlyPlayingSong.map { HomeCell.song(SongCellViewModel(song: $0, accessory: .spotifyLogo, shouldDisplayDominantColor: true)) }
        
        var trendingSongsSection = trendingSongs.prefix(3).enumerated().map { HomeCell.song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + 1))) }
        
        if trendingSongs.count > 3 {
            trendingSongsSection.append(.action(ActionCellViewModel(action: .seeTrendingSongs)))
        }
        
        let likedToday = Realm.likedSongs().filter { Calendar.current.isDateInToday($0.likeDate) }
        
        let likedTodaySection = likedToday.map { HomeCell.song(SongCellViewModel(song: $0.asSharedSong, accessory: .likeLogo)) }
        
        var viralSongsSection = viralSongs.prefix(3).enumerated().map { HomeCell.song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + 1))) }
        
        if viralSongs.count > 3 {
            viralSongsSection.append(.action(ActionCellViewModel(action: .seeViralSongs)))
        }
        
        items.set([
            (.nowPlaying, currentlyPlayingSongsSection),
            (.trending, trendingSongsSection),
            (.viral, viralSongsSection),
            (.likedToday, likedTodaySection)
        ])
    }
    
}
