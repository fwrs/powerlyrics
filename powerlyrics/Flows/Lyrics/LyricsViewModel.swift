//
//  LyricsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import RealmSwift
import UIKit

class LyricsViewModel: ViewModel {
    
    let geniusProvider: GeniusProvider
    
    let realmService: RealmServiceProtocol
    
    var song: SharedSong
    
    let lyrics = MutableObservableArray<SharedLyricsSection>()
    
    let genre: Observable<RealmLikedSongGenre?> = Observable(nil)
    
    let isLiked = Observable(false)
    
    var geniusID: Int?
    
    var geniusURL: URL?
    
    let isFailed = Observable(false)
    
    let producers = Observable([String]())
    
    let album = Observable("")
    
    let spotifyURL: Observable<URL?> = .init(nil)
    
    let description: Observable<String?> = .init(nil)
    
    let lyricsNotFound = Observable(false)
    
    init(geniusProvider: GeniusProvider, realmService: RealmServiceProtocol, song: SharedSong) {
        self.geniusProvider = geniusProvider
        self.realmService = realmService
        self.song = song
    }
    
    func loadData() {
        let onFailure = { [self] in
            isLoading.value = false
            isFailed.value = true
        }
        
        let onLyricsFetch: DefaultSharedLyricsResultAction = { [self] result in
            let newLyrics = result.lyrics
            genre.value = result.genre
            isLoading.value = false
            isFailed.value = false
            lyrics.batchUpdate { array in
                for item in newLyrics {
                    array.append(item)
                }
            }
        }
        
        let onSongFetch: (URL, Int) -> Void = { [self] url, id in
            GeniusProvider.scrape(url: url, completionHandler: onLyricsFetch, failureHandler: {
                onFailure()
            })
            
            geniusProvider.reactive
                .request(.getSong(id: id))
                .map(GeniusSongResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        if let producers = response.response.song.producerArtists?.prefix(2) {
                            self.producers.value = producers.map { $0.name.clean.typographized }
                        }
                        if let album = response.response.song.album {
                            self.album.value = album.name.clean.typographized
                            realmService.incrementDiscoveriesStat(with: album.id)
                        }
                        let artistId = response.response.song.primaryArtist.id
                        realmService.incrementViewedArtistsStat(with: artistId)
                        spotifyURL.value = response.response.song.media?.first { $0.provider == "spotify" }?.url
                        description.value = response.response.song.description?.plain
                    default:
                        break
                    }
                }
        }
        isLoading.value = true
        if let geniusURL = song.geniusURL, let geniusID = song.geniusID {
            self.geniusURL = geniusURL
            self.geniusID = geniusID
            isLiked.value = realmService.findLikedSong(geniusID: geniusID) != nil
            onSongFetch(geniusURL, geniusID)
            return
        }
        
        geniusProvider.reactive
            .request(.searchSongs(query: "\(song.strippedFeatures.name) - \(song.artists.first.safe)"))
            .map(GeniusSearchResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    let filteredData = response.response.hits.filter { ($0.result.url?.absoluteString).safe.hasSuffix("-lyrics") && !$0.result.primaryArtist.name.contains("Genius") && !$0.result.primaryArtist.name.contains("Spotify") }
                    guard filteredData.nonEmpty, let url = filteredData[0].result.url else {
                        lyricsNotFound.value = true
                        return
                    }
                    let id = filteredData[0].result.id
                    geniusID = id
                    geniusURL = url
                    song.geniusID = geniusID
                    song.geniusURL = geniusURL
                    isLiked.value = realmService.findLikedSong(geniusID: filteredData[0].result.id) != nil
                    onSongFetch(url, id)
                case .failed:
                    onFailure()
                default:
                    break
                }
            }
    }
    
    func likeSong() {
        guard let geniusID = geniusID, let geniusURL = geniusURL?.absoluteString, let genre = genre.value else { return }
        realmService.like(song: song, genre: genre, geniusID: geniusID, geniusURL: geniusURL)
        isLiked.value = true
    }
    
    func unlikeSong() {
        guard let geniusID = geniusID else { return }
        realmService.unlike(geniusID: geniusID)
        isLiked.value = false
    }
    
}
