//
//  ViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

class ViewModel {
    
    let isLoading = Observable(false)
    
    let isRefreshing = Observable(false)
    
    let isFailed = Observable(false)
    
    let isEmpty = Observable(false)
    
    func startLoading(_ refresh: Bool) {
        if refresh {
            isRefreshing.value = true
        } else {
            isLoading.value = true
        }
    }
    
    func onLoadingEnd() {}
    
    func endLoading(_ refresh: Bool) {
        if refresh {
            isRefreshing.value = false
        } else {
            isLoading.value = false
        }
        onLoadingEnd()
    }
    
}
