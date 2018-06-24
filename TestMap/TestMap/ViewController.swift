//
//  ViewController.swift
//  TestMap
//
//  Created by Marina on 16/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var points = [PointView]()
    
    private let graph = Graph()
    
    private var currentRoadsLayer = CAShapeLayer()
    
    private var currentRouteLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "BackgroundImage")
        self.view.addSubview(backgroundImageView)
        
        backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
        
        DispatchQueue.global().async {
            self.graph.parseJson {
                DispatchQueue.main.async {
                    self.drawRoads()
                }
            }
        }
    }
    
    private func drawRoads() {
        let aPath = UIBezierPath()
        self.graph.lines.forEach({ points in
            guard let startPoint = points.line.first else {
                return
            }
            
            aPath.move(to: Helper.convert(point: startPoint, size: self.view.bounds.size))
            points.line.forEach({ point in
                
                aPath.addLine(to: Helper.convert(point: point, size: self.view.bounds.size))
            })
        })
        
        currentRoadsLayer.removeFromSuperlayer()
        
        currentRoadsLayer = CAShapeLayer()
        currentRoadsLayer.fillColor = UIColor.clear.cgColor
        currentRoadsLayer.strokeColor = UIColor.lightGray.cgColor
        currentRoadsLayer.lineWidth = 4
        currentRoadsLayer.path = aPath.cgPath
        
        // animate it
        
        self.view.layer.addSublayer(currentRoadsLayer)
    }
    
    @objc private func tapped(_ tap: UITapGestureRecognizer) {
        
        if points.count >= 2 {
            points.forEach { (pointView) in
                pointView.removeFromSuperview()
            }
            
            points.removeAll()
            
            currentRouteLayer.removeFromSuperlayer()
        }
        else {
            let point = tap.location(in: self.view)
            let pointView = PointView(point: point, radius: 10)
            self.view.addSubview(pointView)
            
            points.append(pointView)
            
            if points.count == 2 {
                self.drawRoute()
            }
        }
    }
    
    private func drawRoute() {
        guard let first = points.first?.frame.origin, let last = points.last?.frame.origin, let width = points.first?.bounds.width else {
            return
        }
        
        let convertedPoint1 = Helper.convert(point: CGPoint(x: first.x + width / 2, y: first.y + width / 2), size: self.view.bounds.size, reversed: true)
        let convertedPoint2 = Helper.convert(point: CGPoint(x: last.x + width / 2, y: last.y + width / 2), size: self.view.bounds.size, reversed: true)
        
        let route = Helper.shortestRoute(point1: convertedPoint1, point2: convertedPoint2, nodes: graph.nodes)
        guard let firstRoutePoint = route.first  else {
            return
        }
        
        let aPath = UIBezierPath()
        aPath.move(to: Helper.convert(point: firstRoutePoint, size: self.view.bounds.size))
        route.forEach { (point) in
            
            let correctPoint = Helper.convert(point: point, size: self.view.bounds.size)
            aPath.addLine(to: correctPoint)
            aPath.move(to: correctPoint)
        }
        
        currentRouteLayer.removeFromSuperlayer()
        
        currentRouteLayer = CAShapeLayer()
        currentRouteLayer.fillColor = UIColor.clear.cgColor
        currentRouteLayer.strokeColor = UIColor.green.cgColor
        currentRouteLayer.lineWidth = 8
        currentRouteLayer.path = aPath.cgPath
        currentRouteLayer.zPosition = 1
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.3
        currentRouteLayer.add(animation, forKey: "MyAnimation")

        self.view.layer.addSublayer(currentRouteLayer)
    }
}

