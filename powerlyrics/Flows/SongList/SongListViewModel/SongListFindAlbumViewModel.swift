//
//  SongListFindAlbumViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/22/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - SongListFindAlbumViewModel

class SongListFindAlbumViewModel: SongListViewModel {
    
    // MARK: - Instance properties
    
    let album: String
    
    let artist: String
    
    // MARK: - Init
    
    init(album: String, artist: String, spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.album = album
        self.artist = artist
        super.init(spotifyProvider: spotifyProvider, realmService: realmService)
    }
    
    // MARK: - Load data
    
    override func loadData(refresh: Bool = false, retry: Bool = false) {
        startLoading(refresh)
        isFailed.value = false
        
        let onAlbumFind = { [weak self] (album: SpotifyAlbum) in
            guard let self = self else { return }
            
            self.spotifyProvider.reactive
                .request(.albumSongs(albumID: album.id))
                .map(SpotifyAlbumSongsResponse.self)
                .start { [weak self] event in
                    guard let self = self else { return }
                    switch event {
                    case .value(let response):
                        let albumSongs = response.items
                        self.items.replace(
                            with: albumSongs
                                .map {
                                    .song(SongCellViewModel(
                                        song: $0.asSharedSong(with: album),
                                        isInsideModal: true
                                    ))
                                },
                            performDiff: true
                        )
                        self.endLoading(refresh)
                        self.isFailed.value = false
                        
                    case .failed:
                        self.items.replace(with: [], performDiff: true)
                        delay(Constants.defaultAnimationDuration) {
                            self.isFailed.value = true
                            self.endLoading(refresh)
                        }
                        
                    default:
                        break
                    }
                }
        }
        
        let formattedQuery = "\(album) - \(artist)"
        
        spotifyProvider.reactive
            .request(.searchAlbums(query: formattedQuery))
            .map(SpotifySearchAlbumsResponse.self)
            .start { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .value(let response):
                    let deduplicated = response.albums.items.dedup {
                        $0.name == $1.name && $0.artists == $1.artists
                    }
                    
                    if let album = deduplicated.first {
                        onAlbumFind(album)
                    } else {
                        self.couldntFindAlbumError.value = true
                        delay(Constants.defaultAnimationDuration) {
                            self.endLoading(refresh)
                        }
                    }
                    
                case .failed:
                    self.items.replace(with: [], performDiff: true)
                    delay(Constants.defaultAnimationDuration) {
                        self.isFailed.value = true
                        self.endLoading(refresh)
                    }
                    
                default:
                    break
                }
            }
    }
    
}
