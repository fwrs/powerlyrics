//
//  LyricsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import RealmSwift
import UIKit

class LyricsViewModel: ViewModel {
    
    let geniusProvider: GeniusProvider
    
    let song: SharedSong
    
    let lyrics = MutableObservableArray<Shared.LyricsSection>()
    
    let genre = Observable(RealmLikedSongGenre.unknown)
    
    let isLiked = Observable(false)
    
    var geniusID: Int?
    
    var geniusURL: URL?
    
    init(geniusProvider: GeniusProvider, song: SharedSong) {
        self.geniusProvider = geniusProvider
        self.song = song
    }
    
    func loadData() {
        let onLyricsFetch: DefaultLyricsResultAction = { [self] result in
            let newLyrics = result.lyrics
            genre.value = result.genre
            isLoading.value = false
            lyrics.batchUpdate { array in
                for item in newLyrics {
                    array.append(item)
                }
            }
        }
        
        let onSongFetch: DefaultURLAction = { url in
            GeniusProvider.scrape(url: url, completionHandler: onLyricsFetch)
        }
        isLoading.value = true
        if let geniusURL = song.geniusURL, let geniusID = song.geniusID {
            self.geniusURL = geniusURL
            self.geniusID = geniusID
            isLiked.value = Realm.findLikedSong(geniusID: geniusID) != nil
            onSongFetch(geniusURL)
            return
        }
        
        geniusProvider.reactive
            .request(.searchSongs(query: "\(song.strippedFeatures.name) - \(song.artists.first.safe)"))
            .map(GeniusSearchResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    let filteredData = response.response.hits.filter { ($0.result.url?.absoluteString).safe.hasSuffix("-lyrics") && !$0.result.primaryArtist.name.contains("Genius") && !$0.result.primaryArtist.name.contains("Spotify") }
                    guard filteredData.nonEmpty, let url = filteredData[0].result.url else { return }
                    geniusID = filteredData[0].result.id
                    geniusURL = filteredData[0].result.url
                    isLiked.value = Realm.findLikedSong(geniusID: filteredData[0].result.id) != nil
                    onSongFetch(url)
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
    }
    
    func likeSong() {
        guard let geniusID = geniusID, let geniusURL = geniusURL?.absoluteString else { return }
        Realm.like(song: song, genre: genre.value, geniusID: geniusID, geniusURL: geniusURL)
        isLiked.value = true
    }
    
    func unlikeSong() {
        guard let geniusID = geniusID else { return }
        Realm.unlike(geniusID: geniusID)
        isLiked.value = false
    }
    
}
