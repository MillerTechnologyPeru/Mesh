//
//  LinkLayer.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

public enum LinkLayer: UInt8 {
    
    case bluetooth  = 1
    case loRa       = 2
    case ip         = 3 // Ethernet, WiFi, 3G, etc
}
