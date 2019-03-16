//
//  LoRa.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Message
public protocol LoRaMessage {
    
    /// LoRa Message Type
    static var messageType: LoRaMessageType { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

/// LoRa Message Type
public enum LoRaMessageType: UInt8 {
    
    case advertisement      = 0
    case meshMessage        = 1
}
