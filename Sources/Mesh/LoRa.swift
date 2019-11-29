//
//  LoRa.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Device
public protocol LoRaSocket {
    
    /// Transmit Data
    func transmit(_ data: Data) throws
    
    /// Recieve Data
    func recieve(windowSize: UInt16) throws -> Data?
}

/// LoRa Message protocol
public protocol LoRaMessageProtocol {
    
    /// LoRa Message Type
    static var messageType: LoRaMessageType { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

/// LoRa Message Type
public enum LoRaMessageType: UInt8 {
    
    case advertisement          = 0
    case meshMessage            = 1
}

// LoRa Message
public enum LoRaMessage {
    
    case advertisement(LoRaAdvertisement)
    case meshMessage(LoRaMeshMessage)
}

extension LoRaMessage: RawRepresentable {
    
    public init?(rawValue: LoRaMessageProtocol) {
        
        if let message = rawValue as? LoRaAdvertisement {
            self = .advertisement(message)
        } else if let message = rawValue as? LoRaMeshMessage {
            self = .meshMessage(message)
        } else {
            return nil
        }
    }
    
    public var rawValue: LoRaMessageProtocol {
        switch self {
        case let .advertisement(message): return message
        case let .meshMessage(message): return message
        }
    }
}

public extension LoRaMessage {
    
    init?(data: Data) {
        
        guard let type = data.first,
            let messageType = LoRaMessageType(rawValue: type)
            else { return nil }
        
        switch messageType {
        case .advertisement:
            guard let message = LoRaAdvertisement(data: data)
                else { return nil }
            self = .advertisement(message)
        case .meshMessage:
            guard let message = LoRaMeshMessage(data: data)
                else { return nil }
            self = .meshMessage(message)
        }
    }
    
    var data: Data {
        
        switch self {
        case let .advertisement(message): return message.data
        case let .meshMessage(message): return message.data
        }
    }
}
