//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import ReactiveKit

enum HomeSection {
    case nowPlaying
    case trending
    
    var localizedTitle: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .trending:
            return "Trending"
        }
    }
}

class HomeViewModel: ViewModel {
    
    let spotifyProvider: SpotifyProvider
    
    let items = MutableObservableArray2D(Array2D<HomeSection, HomeCell>())
    
    private var currentlyPlayingSong: Shared.Song?
    
    private var trendingSongs = [Shared.Song]()
    
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
                    currentlyPlayingSong = response.item.asSharedSong
                    group.leave()
                case .failed:
                    currentlyPlayingSong = nil
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
                    trendingSongs = response.items.map { $0.asSharedSong }
                    group.leave()
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [self] in
            endLoading(refresh)
            
//            if let index = items.collection.sections.firstIndex(where: { $0.metadata == .nowPlaying }) {
//                if let currentlyPlayingSong = currentlyPlayingSong {
//                    items[sectionAt: index].items[.zero] = .song(SongCellViewModel(song: currentlyPlayingSong))
//                } else {
//                    items.removeSection(at: index)
//                }
//            } else if let currentlyPlayingSong = currentlyPlayingSong {
//                items.batchUpdate { array in
//                    array.insert(section: .nowPlaying, at: .zero)
//                    array.appendItem(.song(SongCellViewModel(song: currentlyPlayingSong)), toSectionAt: .zero)
//                }
//            }
            
            items.ensure(section: .nowPlaying, contents: currentlyPlayingSong.map { HomeCell.song(SongCellViewModel(song: $0)) })
            
            items.ensure(section: .trending, contents: trendingSongs.prefix(3).map { HomeCell.song(SongCellViewModel(song: $0)) })
            
            items.ensureOrder([
                HomeSection.nowPlaying,
                HomeSection.trending
            ])
            
//            if let index = items.collection.sections.firstIndex(where: { $0.metadata == .trending }) {
//                if let currentlyPlayingSong = currentlyPlayingSong {
//                    items[sectionAt: index].items[.zero] = .song(SongCellViewModel(song: currentlyPlayingSong))
//                } else {
//                    items.removeSection(at: index)
//                }
//            } else {
//                items.batchUpdate { array in
//                    array.insert(section: .nowPlaying, at: .zero)
//                    array.appendItem(.song(SongCellViewModel(song: currentlyPlayingSong)), toSectionAt: .zero)
//                }
//            }
            
//            items.removeAll()
//            items.appendSection(.nowPlaying)
//            items.appendItem(.song(SongCellViewModel(song: currentlyPlayingSong!)), toSectionAt: items.collection.sections.count - 1)
//            items.appendSection(.trending)
//            for song in trendingSongs.prefix(3) {
//                items.appendItem(.song(SongCellViewModel(song: song)), toSectionAt: items.collection.sections.count - 1)
//            }
//            items.appendItem(.action(ActionCellViewModel(action: .seeTrendingSongs)), toSectionAt: items.collection.sections.count - 1)
        }
    }
    
}
