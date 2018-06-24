//
//  Vertex.swift
//  TestMap
//
//  Created by Marina on 16/06/2018.
//  Copyright © 2018 Marina. All rights reserved.
//

import Foundation


struct Floor: Decodable {
    
    let responseData: FeaturesCollectionContainer
    
    enum CodingKeys : String, CodingKey {
        case responseData = "response_data"
    }
}

struct FeaturesCollectionContainer: Decodable {
    let featuresCollection: FeaturesCollection
    
    enum CodingKeys : String, CodingKey {
        case featuresCollection = "features"
    }
}

struct FeaturesCollection: Decodable {
    let features: [Feature]
}

struct Feature: Decodable {
    let geometry: Geometry
}

struct Geometry: Decodable {
    let coordinates: [[Float]]
    let type: String
    
    enum CodingKeys : String, CodingKey {
        case coordinates
        case type
    }
    
    init(coordinates: [[Float]], type: String) {
        self.coordinates = coordinates
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "Point":
            if let coordinate = try container.decodeIfPresent([Float].self, forKey: .coordinates) {
                self.init(coordinates: [coordinate], type: type)
                return
            }
            
        case "LineString":
            if let coordinates = try container.decodeIfPresent([[Float]].self, forKey: .coordinates) {
                self.init(coordinates: coordinates, type: type)
                return
            }
            
        default:
            self.init(coordinates: [[]], type: type)
        }
        self.init(coordinates: [[]], type: type)
    }
}
