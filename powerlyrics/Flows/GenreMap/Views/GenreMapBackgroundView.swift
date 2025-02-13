//
//  GenreMapBackgroundView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let lineWidth: CGFloat = 2
    static let baseInset: CGFloat = 95
    static let extraInset: CGFloat = 60
    
    static let edgeColor = Asset.Colors.genreMapEdgeColor.color.cg
    static let guidingLineColor = Asset.Colors.genreMapGuidingLineColor.color.cg
    
}

// MARK: - GenreMapBackgroundView

class GenreMapBackgroundView: UIView {
    
    // MARK: - Lifecycle
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        guidingLines(context: context, inset: Constants.baseInset, rect: rect)
        
        octagon(context: context, inset: Constants.baseInset, rect: rect)
        octagon(context: context, inset: Constants.baseInset + Constants.extraInset, rect: rect)
        octagon(context: context, inset: Constants.baseInset + 2 * Constants.extraInset, rect: rect)
    }
    
    // MARK: - Helper methods
    
    func octagon(context: CGContext!, inset: CGFloat, rect: CGRect) {
        context.setLineWidth(Constants.lineWidth)
        
        let xCenter = rect.origin.x + rect.size.height / 2
        let yCenter = rect.origin.y + rect.size.width / 2
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / 2
        
        context.setFillColor(Constants.edgeColor)
        
        let vertices = CGFloat(RealmLikedSongGenre.total)
        
        context.setStrokeColor(Constants.edgeColor)
        
        let theta = .pi * (2 / vertices)
        
        context.move(to: CGPoint(x: xCenter, y: CGFloat(radius)+yCenter))
        
        for i in 1...Int(vertices) {
            let x = radius * sin(CGFloat(i) * theta)
            let y = radius * cos(CGFloat(i) * theta)
            
            let x1: CGFloat = x + xCenter
            let y1: CGFloat = y + yCenter
            context.addLine(to: CGPoint(x: x1, y: y1))
        }
        
        context.closePath()
        context.strokePath()
    }
    
    func guidingLines(context: CGContext!, inset: CGFloat, rect: CGRect) {
        context.setLineWidth(Constants.lineWidth)
        
        let xCenter = rect.origin.x + rect.size.height / 2
        let yCenter = rect.origin.y + rect.size.width / 2
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / 2
        
        context.setFillColor(Constants.guidingLineColor)
        
        let vertices = CGFloat(RealmLikedSongGenre.total)
        
        context.setStrokeColor(Constants.guidingLineColor)
        
        let theta = .pi * (2 / vertices)
        
        for i in 1...Int(vertices) {
            let x = radius * sin(CGFloat(i) * theta)
            let y = radius * cos(CGFloat(i) * theta)
            
            let x1: CGFloat = x + xCenter
            let y1: CGFloat = y + yCenter
            
            context.move(to: CGPoint(x: xCenter, y: yCenter))
            context.addLine(to: CGPoint(x: x1, y: y1))
            context.strokePath()
        }
    }

}
