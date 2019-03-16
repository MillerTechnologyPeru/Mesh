//
//  ControlMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

public enum ControlMessage {
    
    public static let payloadType: UUID = .zero
    
    case echoRequest
    case echoReply
    case error(ControlMessageError)
    case peerRequest
    case peerResponse(UInt8)
    case pathRequest
    case pathResponse(UInt8)
    case linkLayerRequest
    case linkLayerResponse(Set<LinkLayer>)
}

public enum ControlMessageType: UInt8 {
    
    case echoRequest    = 0
    case echoReply      = 1
    case error          = 2
    case peerRequest    = 3
    case peerResponse   = 4
    case pathRequest    = 5
    case pathResponse   = 6
}

public enum ControlMessageError: UInt8, Error {
    
    /// TTL == 0
    case hopLimit = 0
}

public struct PathInformation: Equatable, Hashable {
    
    /// Node identifier
    public let device: UUID
    
    /// Maximum transmission unit
    public let maximumTransmissionUnit: UInt16
}
