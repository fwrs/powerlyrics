//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import RealmSwift

// MARK: - HomeSection

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
    
    let items = MutableObservableArray2D(Array2D<HomeSection, HomeCell>())
    
    var currentlyPlayingSong = [SharedSong]()
    
    var trendingSongs = [SharedSong]()
    
    var viralSongs = [SharedSong]()
    
    var isFailed = true
    
    var shouldSignUp: Bool {
        !spotifyProvider.loggedIn
    }
    
    // MARK: - Observables
    
    let isError = Observable(false)
    
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
        startLoading(refresh)
        isError.value = false
        
        let group = DispatchGroup()
        
        isFailed = true
        
        group.enter()
        spotifyProvider.reactive
            .request(.playerStatus)
            .map(SpotifyPlayingContextResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    currentlyPlayingSong = [response.item.asSharedSong]
                    group.leave()
                    isFailed = false
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
                    isFailed = false
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
                    isFailed = false
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
    
    // MARK: - Helper methods
    
    func checkSpotifyAccount() {
        let isSpotifyAccount: Bool? = keychainService.getDecodable(for: .spotifyAuthorizedWithAccount)
        
        self.isSpotifyAccount.value = isSpotifyAccount == true
    }
    
    func updateState() {
        if isFailed {
            isError.value = true
            items.set([])
            return
        }
        
        let currentlyPlayingSongsSection = currentlyPlayingSong.map { HomeCell.song(SongCellViewModel(song: $0, accessory: .spotifyLogo, shouldDisplayDominantColor: true)) }
        
        var trendingSongsSection = trendingSongs.prefix(3).enumerated().map { HomeCell.song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + 1))) }
        
        if trendingSongs.count > 3 {
            trendingSongsSection.append(.action(ActionCellViewModel(action: .seeTrendingSongs)))
        }
        
        let likedToday = realmService.likedSongs().filter { Calendar.current.isDateInToday($0.likeDate) }
        
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

// MARK: - HomeBinder

class HomeBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<HomeSection, HomeCell> {

    override init() {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            case .action(let actionCellViewModel):
                let cell = tableView.dequeue(ActionCell.self, indexPath: indexPath)
                cell.configure(with: actionCellViewModel)
                return cell
            default:
                fatalError("Invalid cell")
            }
        }
    }
    
    @objc func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        changeset?.collection[sectionAt: section].metadata.localizedTitle
    }
    
}

