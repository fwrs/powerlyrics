//
//  GenreStatsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//

import Bond
import ReactiveKit

enum GenreStatsCell: Equatable {
    case song(SongCellViewModel)
    case genreInfo(GenreInfoCellViewModel)
}

class GenreStatsViewModel: ViewModel {
    
    let items = MutableObservableArray<GenreStatsCell>()
    
    override init() {
        super.init()
        items.replace(with: [
                        .genreInfo(GenreInfoCellViewModel()),
                        .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemRed)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil))), .song(SongCellViewModel(song: SharedSong(name: "uwu", artists: ["uwu"], albumArt: nil, thumbnailAlbumArt: .local(UIImage.from(color: .systemYellow)), geniusURL: nil)))], performDiff: true)
    }
    
}
