//
//  Image+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

fileprivate extension Constants {
    
    static let colorComponentsCount = 4
    
    static let maxColorValue: CGFloat = 255
    
    static let red = 0
    
    static let green = 1
    
    static let blue = 2
    
    static let alpha = 3
    
}

extension UIImage {
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )
        
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
        ) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: .zero, count: Constants.colorComponentsCount)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: Constants.colorComponentsCount,
            bounds: CGRect(
                x: .zero,
                y: .zero,
                width: CGFloat.one,
                height: CGFloat.one
            ),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return UIColor(
            red: CGFloat(bitmap[Constants.red]) / Constants.maxColorValue,
            green: CGFloat(bitmap[Constants.green]) / Constants.maxColorValue,
            blue: CGFloat(bitmap[Constants.blue]) / Constants.maxColorValue,
            alpha: CGFloat(bitmap[Constants.alpha]) / Constants.maxColorValue
        )
    }
    
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: .zero, y: .zero, width: CGFloat.one, height: CGFloat.one)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cg)
        context!.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}

// swiftlint:disable all

struct UIImageColors {
    var background: UIColor!
    var primary: UIColor!
    var secondary: UIColor!
    var detail: UIColor!
    
    init(background: UIColor, primary: UIColor, secondary: UIColor, detail: UIColor) {
        self.background = background
        self.primary = primary
        self.secondary = secondary
        self.detail = detail
    }
}

enum UIImageColorsQuality: CGFloat {
    case lowest = 50
    case low = 100
    case high = 250
    case highest = 0
}

fileprivate struct UIImageColorsCounter {
    let color: Double
    let count: Int
    init(color: Double, count: Int) {
        self.color = color
        self.count = count
    }
}

fileprivate extension Double {
    
    private var r: Double {
        return fmod(floor(self/1000000),1000000)
    }
    
    private var g: Double {
        return fmod(floor(self/1000),1000)
    }
    
    private var b: Double {
        return fmod(self,1000)
    }
    
    var isDarkColor: Bool {
        return (r*0.2126) + (g*0.7152) + (b*0.0722) < 127.5
    }
    
    var isBlackOrWhite: Bool {
        return (r > 232 && g > 232 && b > 232) || (r < 23 && g < 23 && b < 23)
    }
    
    func isDistinct(_ other: Double) -> Bool {
        let _r = self.r
        let _g = self.g
        let _b = self.b
        let o_r = other.r
        let o_g = other.g
        let o_b = other.b
        
        return (fabs(_r-o_r) > 63.75 || fabs(_g-o_g) > 63.75 || fabs(_b-o_b) > 63.75)
            && !(fabs(_r-_g) < 7.65 && fabs(_r-_b) < 7.65 && fabs(o_r-o_g) < 7.65 && fabs(o_r-o_b) < 7.65)
    }
    
    func with(minSaturation: Double) -> Double {
        let _r = r/255
        let _g = g/255
        let _b = b/255
        var H, S, V: Double
        let M = fmax(_r,fmax(_g, _b))
        var C = M-fmin(_r,fmin(_g, _b))
        
        V = M
        S = V == .zero ? .zero : C/V
        
        if minSaturation <= S {
            return self
        }
        
        if C == .zero {
            H = .zero
        } else if _r == M {
            H = fmod((_g-_b)/C, 6)
        } else if _g == M {
            H = 2+((_b-_r)/C)
        } else {
            H = 4+((_r-_g)/C)
        }
        
        if H < .zero {
            H += 6
        }

        C = V*minSaturation
        let X = C*(1-fabs(fmod(H,2)-1))
        var R, G, B: Double
        
        switch H {
        case 0...1:
            R = C
            G = X
            B = Double.zero
        case 1...2:
            R = X
            G = C
            B = Double.zero
        case 2...3:
            R = Double.zero
            G = C
            B = X
        case 3...4:
            R = Double.zero
            G = X
            B = C
        case 4...5:
            R = X
            G = Double.zero
            B = C
        case 5..<6:
            R = C
            G = Double.zero
            B = X
        default:
            R = Double.zero
            G = Double.zero
            B = Double.zero
        }
        
        let m = V-C
        
        return (floor((R + m)*255)*1000000)+(floor((G + m)*255)*1000)+floor((B + m)*255)
    }
    
    func isContrasting(_ color: Double) -> Bool {
        let bgLum = (0.2126*r)+(0.7152*g)+(0.0722*b)+12.75
        let fgLum = (0.2126*color.r)+(0.7152*color.g)+(0.0722*color.b)+12.75
        if bgLum > fgLum {
            return 1.6 < bgLum/fgLum
        } else {
            return 1.6 < fgLum/bgLum
        }
    }
    
    var uicolor: UIColor {
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
    
    var pretty: String {
        return "\(Int(self.r)), \(Int(self.g)), \(Int(self.b))"
    }
}

extension UIImage {
    private func resizeForUIImageColors(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(x: .zero, y: .zero, width: newSize.width, height: newSize.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("UIImageColors.resizeForUIImageColors failed: UIGraphicsGetImageFromCurrentImageContext returned nil.")
        }
        
        return result
    }
    
    func getColors(quality: UIImageColorsQuality = .high, _ completion: @escaping (UIImageColors?) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors(quality: quality)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func getColors(quality: UIImageColorsQuality = .high) -> UIImageColors? {
        var scaleDownSize: CGSize = self.size
        if quality != .highest {
            if self.size.width < self.size.height {
                let ratio = self.size.height/self.size.width
                scaleDownSize = CGSize(width: quality.rawValue/ratio, height: quality.rawValue)
            } else {
                let ratio = self.size.width/self.size.height
                scaleDownSize = CGSize(width: quality.rawValue, height: quality.rawValue/ratio)
            }
        }
        
        guard let resizedImage = self.resizeForUIImageColors(newSize: scaleDownSize) else { return nil }
        
        
        guard let cgImage = resizedImage.cgImage else { return nil }
        
        let width: Int = cgImage.width
        let height: Int = cgImage.height
        
        let threshold = Int(CGFloat(height)*0.01)
        var proposed: [Double] = [-1,-1,-1,-1]
        
        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("UIImageColors.getColors failed: could not get cgImage data.")
        }
        
        let imageColors = NSCountedSet(capacity: width*height)
        for x in 0..<width {
            for y in 0..<height {
                let pixel: Int = ((width * y) + x) * 4
                if 127 <= data[pixel+3] {
                    imageColors.add((Double(data[pixel+2])*1000000)+(Double(data[pixel+1])*1000)+(Double(data[pixel])))
                }
            }
        }
        
        let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
            let m = main as! UIImageColorsCounter, o = other as! UIImageColorsCounter
            if m.count < o.count {
                return .orderedDescending
            } else if m.count == o.count {
                return .orderedSame
            } else {
                return .orderedAscending
            }
        }
        
        var enumerator = imageColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: imageColors.count)
        while let K = enumerator.nextObject() as? Double {
            let C = imageColors.count(for: K)
            if threshold < C {
                sortedColors.add(UIImageColorsCounter(color: K, count: C))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        var proposedEdgeColor: UIImageColorsCounter
        if 0 < sortedColors.count {
            proposedEdgeColor = sortedColors.object(at: .zero) as! UIImageColorsCounter
        } else {
            proposedEdgeColor = UIImageColorsCounter(color: .zero, count: .one)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite && .zero < sortedColors.count {
            for i in 1..<sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! UIImageColorsCounter
                if Double(nextProposedEdgeColor.count)/Double(proposedEdgeColor.count) > .pointThree {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        proposed[.zero] = proposedEdgeColor.color
        
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !proposed.first.safe.isDarkColor
        
        while var next = enumerator.nextObject() as? Double {
            next = next.with(minSaturation: 0.15)
            if next.isDarkColor == findDarkTextColor {
                let count = imageColors.count(for: next)
                sortedColors.add(UIImageColorsCounter(color: next, count: count))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        for color in sortedColors {
            let color = (color as! UIImageColorsCounter).color
            
            if proposed[1] == -1 {
                if color.isContrasting(proposed[0]) {
                    proposed[1] = color
                }
            } else if proposed[2] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[2] = color
            } else if proposed[3] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[2].isDistinct(color) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[3] = color
                break
            }
        }
        
        let isDarkBackground = proposed[0].isDarkColor
        for i in 1...3 where proposed[i] == -1 {
            proposed[i] = isDarkBackground ? 255255255:0
        }
        
        return UIImageColors(
            background: proposed[0].uicolor,
            primary: proposed[1].uicolor,
            secondary: proposed[2].uicolor,
            detail: proposed[3].uicolor
        )
    }
}
