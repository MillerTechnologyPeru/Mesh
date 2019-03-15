//
//  Message.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// Mesh Message
public struct Message {
    
    public static var version: Version { return .v1 }
    
    /**
     Unique identifier of the message.
     */
    public let identifier: UUID
    
    /**
     The address of the sending node.
     */
    public let source: UUID
    
    /**
     The address of the destination node.
     */
    public let destination: UUID
    
    /**
     Hop limit (time to live)
     
     To avoid looping in the network, every packet is sent with some TTL value set, which tells the network how many routers (hops) this packet can cross. At each hop, its value is decremented by one and when the value reaches zero, the packet is discarded.
     */
    public var hopLimit: UInt8
    
    public let payloadType: UUID
    
    /**
     The payload to send.
     */
    public let payload: Data
    
    public init(identifier: UUID = UUID(),
                source: UUID,
                destination: UUID,
                hopLimit: UInt8 = .max,
                payloadType: UUID,
                payload: Data) {
        
        self.identifier = identifier
        self.hopLimit = hopLimit
        self.source = source
        self.destination = destination
        self.payloadType = payloadType
        self.payload = payload
    }
}
