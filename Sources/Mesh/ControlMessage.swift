//
//  ControlMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

public enum ControlMessage {
        
    case echoRequest
    case echoReply
    case error(ControlMessageError)
    case peerRequest
    case peerResponse(UInt8) // number of peers
    case pathRequest
    case pathResponse(UInt8) // number of hops
    case linkLayerRequest
    case linkLayerResponse(Set<LinkLayer>) // supported link layer technologies
}

public enum ControlMessageType: UInt8 {
    
    case echoRequest            = 0
    case echoReply              = 1
    case error                  = 2
    case peerRequest            = 3
    case peerResponse           = 4
    case pathRequest            = 5
    case pathResponse           = 6
    case linkLayerRequest       = 7
    case linkLayerResponse      = 8
}

public enum ControlMessageError: UInt8, Error {
    
    /// TTL == 0
    case hopLimit = 0
}
