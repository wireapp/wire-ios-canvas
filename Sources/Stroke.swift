//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import UIKit

public struct Brush {
    
    public init(size: Float, color: UIColor) {
        self.size = size
        self.color = color
    }
    
    let size: Float
    let color: UIColor
    
    public func change(toColor color: UIColor) -> Brush {
        return Brush(size: size, color: color)
    }
    
    public func change(toSize size: Float) -> Brush {
        return Brush(size: size, color: color)
    }
    
}

class Stroke : Renderable {
    
    private var samples: [StrokeSample]
    private let brush : Brush
    
    var bounds: CGRect {
        get {
            return bounds(from: 0)
        }
    }
    
    init(with initialSample: StrokeSample, brush: Brush) {
        self.brush = brush
        self.samples = [initialSample]
    }

    func addSamples(_ newSamples: [StrokeSample]) -> CGRect {
        samples.append(contentsOf: newSamples)//.map(smooth))
        return bounds(from: max(samples.count - newSamples.count, 0))
    }

    func end() {
        
    }
    
    func draw(context : CGContext) {

        context.setFillColor(brush.color.cgColor)
        context.setStrokeColor(brush.color.cgColor)

        guard samples.count > 1 else {
            let sample = samples[0]
            let point = sample.point
            let size = width(for: sample)

            let origin = CGPoint(x: point.x - CGFloat(size / 2), y: point.y - CGFloat(size / 2))
            context.addEllipse(in: CGRect(origin: origin, size: CGSize(width: Double(size), height: Double(size))))
            context.fillPath()

            return
        }

        var previousPoint = samples[0].point

        for sample in samples.suffix(from: 1) {

            let location = sample.point

            let path = UIBezierPath()
            path.lineWidth = width(for: sample)
            path.lineCapStyle = .round

            path.move(to: previousPoint)
            path.addLine(to: location)
            path.stroke()

            previousPoint = location

        }

    }

    func width(for sample: StrokeSample) -> CGFloat {
        return CGFloat(brush.size) * sample.brushFactor
    }

    func bounds(from index: Int) -> CGRect {
        var minX = Double.infinity
        var minY = Double.infinity
        var maxX = -Double.infinity
        var maxY = -Double.infinity
        
        for sample in samples.suffix(from: index) {
            minX = min(Double(sample.point.x), minX)
            minY = min(Double(sample.point.y), minY)
            maxX = max(Double(sample.point.x), maxX)
            maxY = max(Double(sample.point.y), maxY)
        }
        
        let outset = CGFloat(-brush.size)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY).insetBy(dx: outset, dy: outset)
    }
    
    func interpolateLinearPath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points.first!)
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }

    func smooth(_ sample: StrokeSample) -> StrokeSample {
        return smooth(sample, factor: 0.35)
    }

    func smooth(_ sample: StrokeSample, factor: CGFloat) -> StrokeSample {
        let previous = samples.last!.point
        let point = sample.point
        let smoothedPosition = CGPoint(x: previous.x * (1 - factor) + point.x * factor,
                                       y: previous.y * (1 - factor) + point.y * factor)
        return sample.moving(to: smoothedPosition)
    }
    
    func interpolateBeizerPath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points.first!)
        path.lineWidth = CGFloat(brush.size)
        
        let controlPoints = controlsPoints(points: points)
        
        for i in 1..<points.count {
            path.addCurve(to: points[i], controlPoint1: controlPoints[i-1].1, controlPoint2: controlPoints[i].0)
        }
        
        
        return path
    }
    
    func controlsPoints(points : [CGPoint]) -> [(CGPoint, CGPoint)] {
        
        let points = [points.first!] + points + [points.last!]
        var controlPoints : [(CGPoint, CGPoint)] = []
        
        for i in 1..<points.count-1 {
            let p0 = points[i-1]
            let p1 = points[i]
            let p2 = points[i+1]
            
            let v0 = CGPoint(x: p1.x - p0.x, y: p1.y - p0.y)
            let v1 = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
            
            let a0 = CGPoint(x: p0.x + 0.5 * v0.x, y: p0.y + 0.5 * v0.y)
            let a1 = CGPoint(x: p1.x + 0.5 * v1.x, y: p1.y + 0.5 * v1.y)
            
            let len0 = v0.x * v0.x + v0.y * v0.y
            let len1 = v1.x * v1.x + v1.y * v1.y
            let ratio =  len0 / (len0 + len1)
            
            let b0 = CGPoint(x: a0.x - a1.x, y: a0.y - a1.y)
            
            let d0 = CGPoint(x: b0.x * ratio, y: b0.y * ratio)
            let d1 = CGPoint(x: b0.x * (ratio - 1), y: b0.y * (ratio - 1))
            
            let cp0 = CGPoint(x: p1.x + d0.x, y: p1.y + d0.y)
            let cp1 = CGPoint(x: p1.x + d1.x, y: p1.y + d1.y)
            
            controlPoints.append((cp0, cp1))
        }
        
        return controlPoints
    }
    
}
