//
//  LoRaAdvertisement.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Advertisment
public struct LoRaAdvertisement: Equatable, Hashable, LoRaMessage {
    
    public static let messageType: LoRaMessageType = .advertisement
    
    /// Source LoRa Device
    public let device: UUID
    
    public init(device: UUID) {
        self.device = device
    }
}

public extension LoRaAdvertisement {
    
    public init?(data: Data) {
        
        var data = DataIterator(data: data)
        
        guard let device = data.consume(UUID.length, { UUID(data: $0)?.littleEndian })
            else { return nil }
        
        self.device = device
    }
    
    public var data: Data {
        
        return Data(self)
    }
}

// MARK: - DataConvertible

extension LoRaAdvertisement: DataConvertible {
    
    
}
