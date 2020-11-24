//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - HomeSection

enum HomeSection: Equatable {
    
    case nowPlaying
    case trending
    case viral
    case likedToday
    
    var localizedTitle: String {
        switch self {
        case .nowPlaying:
            return Strings.Home.Section.nowPlaying
            
        case .trending:
            return Strings.Home.Section.trending
            
        case .viral:
            return Strings.Home.Section.viral
            
        case .likedToday:
            return Strings.Home.Section.likedToday
        }
    }
    
}

// MARK: - HomeCell

enum HomeCell: Equatable {
    
    case song(SongCellViewModel)
    case action(ActionCellViewModel)
    
}

// MARK: - HomeViewModel

class HomeViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    let keychainService: KeychainServiceProtocol
    
    // MARK: - Instance properties
        
    var currentlyPlayingSong = [SharedSong]()
    
    var trendingSongs = [SharedSong]()
    
    var viralSongs = [SharedSong]()
    
    var isAtLeastOneRequestFailed = true
    
    var shouldSignUp: Bool {
        !spotifyProvider.loggedIn
    }
    
    // MARK: - Observables
    
    let items = MutableObservableArray2D(Array2D<HomeSection, HomeCell>())
    
    let isSpotifyAccount = Observable(true)
    
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
    
    // MARK: - Load data

    func loadData(refresh: Bool = false) {
        isSpotifyAccount.value = keychainService.getDecodable(for: .spotifyAuthorizedWithAccount) == true
        
        startLoading(refresh)
        isFailed.value = false
        
        let group = DispatchGroup()
        isAtLeastOneRequestFailed = true
        
        group.enter()
        spotifyProvider.reactive
            .request(.playerStatus)
            .map(SpotifyPlayingContextResponse.self)
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    self?.currentlyPlayingSong = [response.item.asSharedSong]
                    group.leave()
                    self?.isAtLeastOneRequestFailed = false
                    
                case .failed:
                    self?.currentlyPlayingSong = .init()
                    group.leave()
                    
                default:
                    break
                }
            }
        
        group.enter()
        spotifyProvider.reactive
            .request(.trendingSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    self?.trendingSongs = response.items.map(\.asSharedSong)
                    self?.isAtLeastOneRequestFailed = false
                    group.leave()
                    
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
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    self?.viralSongs = response.items.map(\.asSharedSong)
                    self?.isAtLeastOneRequestFailed = false
                    group.leave()
                    
                case .failed:
                    group.leave()
                    
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [weak self] in
            self?.updateState(shouldEndLoading: true, endLoadingRefresh: refresh)
        }
    }
    
    // MARK: - Helper methods
    
    func updateState(shouldEndLoading: Bool = false, endLoadingRefresh: Bool = false) {
        if isAtLeastOneRequestFailed {
            delay(Constants.defaultAnimationDuration) { [weak self] in
                self?.isFailed.value = true
                self?.items.set([])
                
                if shouldEndLoading {
                    self?.endLoading(endLoadingRefresh)
                }
            }
            return
        }
        
        let currentlyPlayingSongsSection = currentlyPlayingSong
            .map { HomeCell.song(SongCellViewModel(
                song: $0,
                accessory: .spotifyLogo,
                shouldDisplayDominantColor: true
            )) }
        
        var trendingSongsSection = trendingSongs.prefix(Constants.maxPlaylistPreviewCount)
            .enumerated()
            .map { HomeCell.song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + .one))) }
        
        if trendingSongs.count > Constants.maxPlaylistPreviewCount {
            trendingSongsSection.append(.action(ActionCellViewModel(action: .seeTrendingSongs)))
        }
        
        let likedToday = realmService.likedSongs()
            .filter { Calendar.current.isDateInToday($0.likeDate) }

        var likedTodaySection = likedToday
            .prefix(Constants.maxPlaylistPreviewCount)
            .map { HomeCell.song(SongCellViewModel(song: $0.asSharedSong, accessory: .likeLogo)) }

        if likedToday.count > Constants.maxPlaylistPreviewCount {
            likedTodaySection.append(.action(ActionCellViewModel(action: .seeSongsLikedToday)))
        }
                
        var viralSongsSection = viralSongs.prefix(Constants.maxPlaylistPreviewCount)
            .enumerated()
            .map { HomeCell.song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + .one))) }
        
        if viralSongs.count > Constants.maxPlaylistPreviewCount {
            viralSongsSection.append(.action(ActionCellViewModel(action: .seeViralSongs)))
        }
        
        items.set([
            (.nowPlaying, currentlyPlayingSongsSection),
            (.trending, trendingSongsSection),
            (.viral, viralSongsSection),
            (.likedToday, likedTodaySection)
        ])
        
        if shouldEndLoading {
            endLoading(endLoadingRefresh)
        }
    }
    
}
