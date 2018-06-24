//
//  Node.swift
//  TestMap
//
//  Created by Marina on 24/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import UIKit

struct Line: Equatable {
    let line: [CGPoint]
    let distance: CGFloat
    
    static func == (lhs: Line, rhs: Line) -> Bool {
        return (lhs.line.first == rhs.line.first && lhs.line.last == rhs.line.last) || (lhs.line.last == rhs.line.first && lhs.line.first == rhs.line.last)
    }
}

class Node: Equatable {
    let point: CGPoint
    var connections = [Connection]()
    var visited: Bool = false
    
    init(point: CGPoint) {
        self.point = point
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.point == rhs.point
    }
}

class Connection {
    let to: Node
    let line: Line
    
    init(to node: Node, line: Line) {
        self.to = node
        self.line = line
    }
}

class Route {
    let node: Node
    let weight: CGFloat
    let previous: Route?
    
    init(to: Node, via: Connection? = nil, previous: Route? = nil) {
        self.node = to
        self.previous = previous
        if let previous = previous, let connection = via?.line {
            self.weight = previous.weight + connection.distance
        }
        else {
            self.weight = 0
        }
    }
}
