//
//  PointView.swift
//  TestMap
//
//  Created by Marina on 16/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import UIKit

class PointView: UIView {
    
    private var radius: CGFloat = 10.0
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        construct()
    }
    
    convenience init(point: CGPoint, radius: CGFloat) {
        self.init(frame: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
        
        self.radius = radius
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        construct()
    }
    
    func construct() {
        
        layer.cornerRadius = radius
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        layer.backgroundColor = UIColor.red.cgColor
    }
}
