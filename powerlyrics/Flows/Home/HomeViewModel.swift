//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import ReactiveKit

enum HomeSection: Equatable {
    case nowPlaying
    case trending
    case viral
    
    var localizedTitle: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .trending:
            return "Trending"
        case .viral:
            return "Viral"
        }
    }
}

class HomeViewModel: ViewModel {
    
    let spotifyProvider: SpotifyProvider
    
    let items = MutableObservableArray2D(Array2D<HomeSection, HomeCell>())
    
    private var currentlyPlayingSong = [Shared.Song]()
    
    private var trendingSongs = [Shared.Song]()
    
    private var viralSongs = [Shared.Song]()
    
    init(spotifyProvider: SpotifyProvider) {
        self.spotifyProvider = spotifyProvider
    }
    
    var shouldSignUp: Bool {
        !spotifyProvider.loggedIn
    }

    func loadData(refresh: Bool = false) {
        self.startLoading(refresh)
        
        let group = DispatchGroup()
        
        group.enter()
        spotifyProvider.reactive
            .request(.playerStatus)
            .map(Spotify.PlayingContextResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    currentlyPlayingSong = [response.item.asSharedSong]
                    group.leave()
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
            .map(Spotify.PlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    trendingSongs = response.items.map(\.asSharedSong)
                    group.leave()
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
        
        group.enter()
        spotifyProvider.reactive
            .request(.viralSongs)
            .map(Spotify.PlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    viralSongs = response.items.map(\.asSharedSong)
                    group.leave()
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [self] in
            endLoading(refresh)
            
            let currentlyPlayingSongsSection = currentlyPlayingSong.map { HomeCell.song(SongCellViewModel(song: $0)) }
            
            var trendingSongsSection = trendingSongs.prefix(3).map { HomeCell.song(SongCellViewModel(song: $0)) }
            
            if trendingSongs.count > 3 {
                trendingSongsSection.append(.action(ActionCellViewModel(action: .seeTrendingSongs)))
            }
            
            var viralSongsSection = viralSongs.prefix(3).map { HomeCell.song(SongCellViewModel(song: $0)) }
            
            if viralSongs.count > 3 {
                viralSongsSection.append(.action(ActionCellViewModel(action: .seeViralSongs)))
            }
            
            items.set([
                (.nowPlaying, currentlyPlayingSongsSection),
                (.trending, trendingSongsSection),
                (.viral, viralSongsSection)
            ])
        }
    }
    
}
