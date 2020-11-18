//
//  GenreMapBackgroundView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class GenreMapBackgroundView: UIView {
    
    func octagon(context: CGContext!, inset: CGFloat, rect: CGRect) {
        let aSize: CGFloat = 2
        let color: [CGFloat] = [ 121.0 / 255.0, 121.0 / 255.0, 121.0 / 255.0, 0.6 ]
        let aColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: color)!
        context.setLineWidth(aSize)
        let xCenter = rect.origin.x + rect.size.height / 2
        let yCenter = rect.origin.y + rect.size.width / 2
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / 2.0
        
        context.setFillColor(aColor)
        
        let things: CGFloat = 8
        
        context.setStrokeColor(aColor)
        
        let theta = .pi * (2.0 / things)
        
        context.move(to: CGPoint(x: xCenter, y: CGFloat(radius)+yCenter))
        
        for i in 1...Int(things) {
            let x = radius * sin(CGFloat(i) * theta)
            let y = radius * cos(CGFloat(i) * theta)
            
            let x1: CGFloat = x+xCenter
            let y1: CGFloat = y+yCenter
            context.addLine(to: CGPoint(x: x1, y: y1))
        }
        
        context.closePath()
        context.strokePath()
    }
    
    func guidingLines(context: CGContext!, inset: CGFloat, rect: CGRect) {
        let aSize: CGFloat = 2
        let color: [CGFloat] = [ 20.0 / 255.0, 20.0 / 255.0, 20.0 / 255.0, 1.0 ]
        let aColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: color)!
        context.setLineWidth(aSize)
        let xCenter = rect.origin.x + rect.size.height / 2
        let yCenter = rect.origin.y + rect.size.width / 2
        
        let width: CGFloat = rect.size.width - inset
        let radius: CGFloat = width / 2.0
        
        context.setFillColor(aColor)
        
        let things: CGFloat = 8
        
        context.setStrokeColor(aColor)
        
        let theta = .pi * (2.0 / things)
        
        for i in 1...Int(things) {
            let x = radius * sin(CGFloat(i) * theta)
            let y = radius * cos(CGFloat(i) * theta)
            
            let x1: CGFloat = x+xCenter
            let y1: CGFloat = y+yCenter
            context.move(to: CGPoint(x: xCenter, y: yCenter))
            context.addLine(to: CGPoint(x: x1, y: y1))
            context.strokePath()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let extraInset: CGFloat = 60
        let baseInset: CGFloat = 95
        let context = UIGraphicsGetCurrentContext()
        guidingLines(context: context, inset: baseInset, rect: rect)
        octagon(context: context, inset: baseInset, rect: rect)
        octagon(context: context, inset: baseInset + extraInset, rect: rect)
        octagon(context: context, inset: baseInset + 2 * extraInset, rect: rect)
    }

}
