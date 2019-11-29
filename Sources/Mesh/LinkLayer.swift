//
//  LinkLayer.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

public enum LinkLayer: UInt8, CaseIterable {
    
    case bluetooth  = 1
    case loRa       = 2
    case ip         = 3 // Ethernet, WiFi, 3G, etc
}

public extension LinkLayer {
    
    var maximumTransmissionUnit: UInt16 {
        
        switch self {
        case .loRa: return 255
        case .bluetooth: return 512
        case .ip: return .max
        }
    }
}
