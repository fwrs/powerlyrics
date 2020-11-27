//
//  LyricsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let lyricsSuffix = "-lyrics"
    static let spotifyAuthor = "Spotify"
    static let geniusAuthor = "Genius"
    
}

// MARK: - LyricsViewModel

class LyricsViewModel: ViewModel {
    
    // MARK: - DI
    
    let geniusProvider: GeniusProvider
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Instance properties
    
    var fixedAlbumInfo: (String, String)? {
        guard let albumInfo = albumInfo.value else { return nil }
        
        let fixedAlbum = albumInfo.0.components(separatedBy: Constants.startingParenthesis).first.mapEmptyToNil ?? albumInfo.0
        
        let fixedArtist = albumInfo.1.components(separatedBy: Constants.comma).first.mapEmptyToNil?
            .components(separatedBy: Constants.startingParenthesis).first.mapEmptyToNil?
            .components(separatedBy: Constants.ampersand).first.mapEmptyToNil ?? albumInfo.1
        
        return (fixedAlbum.clean, fixedArtist.clean)
    }
    
    var cleanSongName: String { song.name.clean.typographized }
    
    var cleanArtistName: String { song.artistsString.clean.typographized }
    
    var cleanCompactSongName: String {
        let fixed = song.name
            .components(separatedBy: Constants.startingParenthesis)
            .first.mapEmptyToNil ?? song.name
        
        return fixed.clean.typographized
    }
    
    var song: SharedSong
    
    var geniusID: Int?
    
    var geniusURL: URL?
    
    // MARK: - Observables
    
    let lyrics = MutableObservableArray<SharedLyricsSection>()
    
    let genre: Observable<RealmLikedSongGenre?> = Observable(nil)
    
    let isLiked = Observable(false)
    
    let producers = Observable([String]())
    
    let albumInfo: Observable<(String, String)?> = Observable(nil)
    
    let spotifyURL: Observable<URL?> = .init(nil)
    
    let description: Observable<String?> = .init(nil)
    
    let lyricsNotFound = Observable(false)
    
    // MARK: - Init
    
    init(geniusProvider: GeniusProvider, realmService: RealmServiceProtocol, song: SharedSong) {
        self.geniusProvider = geniusProvider
        self.realmService = realmService
        self.song = song
    }
    
    // MARK: - Load data
    
    func loadData() {
        let onFailure = { [weak self] in
            delay(Constants.defaultAnimationDuration) { [weak self] in
                self?.endLoading()
                self?.isFailed.value = true
            }
        }
        
        let onLyricsFetch: DefaultSharedLyricsResultAction = { [weak self] result in
            let newLyrics = result.lyrics
            self?.genre.value = result.genre
            self?.lyrics.batchUpdate { array in
                for item in newLyrics {
                    array.append(item)
                }
            }
            self?.endLoading()
            self?.isFailed.value = false
        }
        
        let onSongFetch: (URL, Int) -> Void = { [weak self] url, id in
            GeniusProvider.scrape(url: url, completionHandler: onLyricsFetch, failureHandler: {
                onFailure()
            })
            
            self?.geniusProvider.reactive
                .request(.getSong(id: id))
                .map(GeniusSongResponse.self)
                .start { [weak self] event in
                    guard let self = self else { return }
                    switch event {
                    case .value(let response):
                        if let producers = response.response.song.producerArtists?.prefix(.two) {
                            self.producers.value = producers.map { $0.name.clean.typographized }
                        }
                        if let album = response.response.song.album, let artist = album.artist {
                            self.albumInfo.value = (album.name.clean.typographized, artist.name.clean.typographized)
                            self.realmService.incrementDiscoveriesStat(with: album.id)
                        } else {
                            self.albumInfo.value = nil
                        }
                        let artistId = response.response.song.primaryArtist.id
                        self.realmService.incrementViewedArtistsStat(with: artistId)
                        self.spotifyURL.value = response.response.song.media?.first { $0.provider == Constants.spotifySystemName }?.url
                        self.description.value = response.response.song.description?.plain
                        
                    default:
                        break
                    }
                }
        }
        startLoading()
        isFailed.value = false
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
            .start { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .value(let response):
                    let filteredData = response.response.hits.filter {
                        ($0.result.url?.absoluteString).safe.hasSuffix(Constants.lyricsSuffix) &&
                            !$0.result.primaryArtist.name.contains(Constants.geniusAuthor) &&
                            !$0.result.primaryArtist.name.contains(Constants.spotifyAuthor)
                    }
                    guard filteredData.nonEmpty, let url = filteredData[.zero].result.url else {
                        self.endLoading()
                        self.lyricsNotFound.value = true
                        return
                    }
                    let id = filteredData[.zero].result.id
                    self.geniusID = id
                    self.geniusURL = url
                    self.song.geniusID = id
                    self.song.geniusURL = url
                    self.isLiked.value = self.realmService.findLikedSong(geniusID: filteredData[.zero].result.id) != nil
                    onSongFetch(url, id)
                    
                case .failed:
                    onFailure()
                    
                default:
                    break
                }
            }
    }
    
    // MARK: - Helper methods
    
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
    
    func updateLikeState() {
        isLiked.value = realmService.likedSongs().contains { [weak self] in
            guard let self = self else { return false }
            return $0.geniusID == self.geniusID
        }
    }
    
}
