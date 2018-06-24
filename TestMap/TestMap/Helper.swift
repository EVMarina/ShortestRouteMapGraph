//
//  Helper.swift
//  TestMap
//
//  Created by Marina on 24/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import UIKit

class Helper {
    
    struct Constants {
        static let width: CGFloat = 830
        static let height: CGFloat = 475
    }
    
    class func shortestRoute(point1: CGPoint, point2: CGPoint, nodes: [Node]) -> [CGPoint] {
        var route = [CGPoint]()
            
        let source = nodes.map({ (point1.distance($0.point), $0) }).min { (group1, group2) -> Bool in
            return group1.0 < group2.0
            }?.1
        
        let destination = nodes.map({ (point2.distance($0.point), $0) }).min { (group1, group2) -> Bool in
            return group1.0 < group2.0
            }?.1
        
        guard let node1 = source, let node2 = destination, let routePoints = Helper.route(node1: node1, node2: node2, nodes: nodes) else {
            return route
        }
        
        route = routePoints
        
        return route
    }
    
    class func route(node1: Node, node2: Node, nodes: [Node]) -> [CGPoint]? {
        nodes.forEach({ $0.visited = false })
        
        guard let route = Helper.shortestPath(source: node1, destination: node2) else { return nil }
        
        var points = [route.node.point]
        var currentRoute = route
        while let previous = currentRoute.previous {
            points.append(previous.node.point)
            currentRoute = previous
        }
        return points.reversed()
    }
    
    class func shortestPath(source: Node, destination: Node) -> Route? {
        var frontier: [Route] = [] {
            didSet { frontier.sort { return $0.weight < $1.weight } }
        }
        
        frontier.append(Route(to: source))
        
        while !frontier.isEmpty {
            let cheapestPathInFrontier = frontier.removeFirst()
            guard !cheapestPathInFrontier.node.visited else { continue }
            
            if cheapestPathInFrontier.node === destination {
                return cheapestPathInFrontier
            }
            
            cheapestPathInFrontier.node.visited = true
            
            for connection in cheapestPathInFrontier.node.connections where !connection.to.visited && connection.to != cheapestPathInFrontier.node {
                frontier.append(Route(to: connection.to, via: connection, previous: cheapestPathInFrontier))
            }
        }
    
        return nil
    }
    
    class func convert(point: CGPoint, size: CGSize, reversed: Bool = false) -> CGPoint {
        
        let widthRatio = pow(size.width / Constants.width, reversed ? -1 : 1)
        let heightRatio = pow(size.height / Constants.height, reversed ? -1 : 1)
        
        return CGPoint(x: point.x * widthRatio, y: point.y * heightRatio)
    }
    
    class func projection(from p: CGPoint, to line: [CGPoint]) -> CGPoint? {
        guard let p1 = line.first, let p2 = line.last else { return nil }
        
        let v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        var t: CGFloat = (p.x * v.x - p1.x * v.x + p.y * v.y - p1.y * v.y) / (v.x * v.x + v.y * v.y)
        if t < 0 { t = 0 }
        else if t > 1 { t = 1 }
        return CGPoint(x: p1.x + t * v.x, y: p1.y + t * v.y)
    }
}


public extension CGPoint {
    
    func distance(_ point: CGPoint) -> CGFloat {
        let dx = Float(x - point.x)
        let dy = Float(y - point.y)
        return CGFloat(sqrt((dx * dx) + (dy * dy)))
    }
    
    public static func  ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.distance(rhs) < 0.0001
    }
}
