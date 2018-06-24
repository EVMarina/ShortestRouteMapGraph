//
//  Graph.swift
//  TestMap
//
//  Created by Marina on 16/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import UIKit

class Graph: NSObject {
    
    private var points = [CGPoint]()
    var lines = [Line]()
    
    var nodes = [Node]()
    
    func parseJson(completion: (() -> Swift.Void)? = nil) {
        do {
            if let file = Bundle.main.url(forResource: "a1s", withExtension: "rtf") {
                let attributedString = try NSAttributedString(url: file, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                
                guard let data = attributedString.string.data(using: .utf8), let floor = try? JSONDecoder().decode(Floor.self, from: data) else {
                    print("Error: Couldn't decode data into Floor")
                    return
                }
                
                floor.responseData.featuresCollection.features.compactMap { return $0.geometry }.forEach { geometry in
                    
                    var line = [CGPoint]()
                    geometry.coordinates.forEach({ point in
                        guard let first = point.first, let last = point.last else {
                            return
                        }
                        
                        let point = CGPoint(x: CGFloat(first), y: CGFloat(last))
                        if geometry.coordinates.count == 1 {
                            points.append(point)
                        }
                        else {
                            line.append(point)
                        }
                    })
                    
                    if line.count > 1 {
                        for i in 1 ..< line.count {
                            let distance = line[i-1].distance(line[i])
                            let newLine = Line(line: [line[i-1], line[i]], distance: distance)
                            lines.append(newLine)
                        }
                    }
                }
                
                if let firstPoint = lines.first?.line.first, let lastPoint = lines.first?.line.last {
                    let _ = self.node(from: firstPoint, with: lines)
                    let _ = self.node(from: lastPoint, with: lines)
                    
                }
                
                completion?()
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func node(from point: CGPoint, with lines: [Line]) -> Node {
        if let node = nodes.first(where: { $0.point == point }) {
            return node
        }
        
        let contiguousLines = lines.filter({ line -> Bool in
            return line.line.first == point || line.line.last == point
        })
        
        let node = Node(point: point)
        node.connections = contiguousLines.map({ (cLine) -> Connection? in
            guard let newPoint = cLine.line.first == point ? cLine.line.last : cLine.line.first, let index = lines.index(of: cLine) else {
                return nil
            }
            
            if let cNode = nodes.first(where: { $0.point == newPoint }) {
                return Connection(to: cNode, line: cLine)
            }
            
            var newLines = lines
            newLines.remove(at: index)
            
            let cNode = self.node(from: newPoint, with: newLines)
            cNode.connections.append(Connection(to: node, line: cLine))
            nodes.append(cNode)
            return Connection(to: cNode, line: cLine)
        }).compactMap { $0 }
        
        nodes.append(node)
        
        return node
    }
}

