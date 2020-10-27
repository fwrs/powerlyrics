//
//  LyricsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

class LyricsViewModel: ViewModel {
    
    let geniusProvider: GeniusProvider
    
    let song: Shared.Song
    
    let lyrics = MutableObservableArray<Shared.LyricsSection>()
    
    init(geniusProvider: GeniusProvider, song: Shared.Song) {
        self.geniusProvider = geniusProvider
        self.song = song
    }
    
    func loadData() {
        let onLyricsFetch: DefaultLyricsAction = { [self] newLyrics in
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
        if let geniusUrl = song.geniusURL {
            onSongFetch(geniusUrl)
            return
        }
        
        var songName = song.name
        if let range = songName.range(of: "(feat.") {
            songName = String(songName[..<range.lowerBound]).clean
        }
        
        geniusProvider.reactive
            .request(.searchSongs(query: "\(song.artists.first.safe) - \(songName)"))
            .map(Genius.SearchResponse.self)
            .start { event in
                switch event {
                case .value(let response):
                    let filteredData = response.response.hits.filter { ($0.result.url?.absoluteString).safe.hasSuffix("-lyrics") && !$0.result.primaryArtist.name.contains("Genius") && !$0.result.primaryArtist.name.contains("Spotify") }
                    guard filteredData.nonEmpty, let url = filteredData[0].result.url else { return }
                    onSongFetch(url)
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
    }
    
}
