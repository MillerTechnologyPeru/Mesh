//
//  ControlMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

public enum ControlMessage: MessagePayload {
    
    public static var payloadType: PayloadType { return .controlMessage }
        
    case echoRequest
    case echoResponse
    case pathRequest(UInt8)
    case pathResponse(UInt8) // number of hops
    case linkLayerRequest
    case linkLayerResponse(Set<LinkLayer>) // supported link layer technologies
}

public extension ControlMessage {
    
    public init?(data: Data) {
        
        guard let typeByte = data.first,
            let type = ControlMessageType(rawValue: typeByte)
            else { return nil }
        
        switch type {
        case .echoRequest:
            self = .echoRequest
        case .echoResponse:
            self = .echoResponse
        case .pathRequest:
            guard data.count == 2
                else { return nil }
            let hops = data[1]
            self = .pathRequest(hops)
        case .pathResponse:
            guard data.count == 2
                else { return nil }
            let hops = data[1]
            self = .pathResponse(hops)
        case .linkLayerRequest:
            self = .linkLayerRequest
        case .linkLayerResponse:
            guard data.count >= 2
                else { return nil }
            var layers = Set<LinkLayer>()
            layers.reserveCapacity(data.count - 1)
            for layerByte in data.suffix(from: 1) {
                guard let layer = LinkLayer(rawValue: layerByte)
                    else { return nil }
                layers.insert(layer)
            }
            self = .linkLayerResponse(layers)
        }
    }
    
    public var data: Data {
        
        var data = Data(capacity: 1)
        data += type.rawValue
        
        switch self {
        case let .pathRequest(hops):
            data += hops
        case let .pathResponse(hops):
            data += hops
        case let .linkLayerResponse(layers):
            layers.forEach { data += $0.rawValue }
        default:
            break
        }
        
        return data
    }
}

public extension ControlMessage {
    
    var type: ControlMessageType {
        switch self {
        case .echoRequest: return .echoRequest
        case .echoResponse: return .echoResponse
        case .pathRequest: return .pathRequest
        case .pathResponse: return .pathResponse
        case .linkLayerRequest: return .linkLayerRequest
        case .linkLayerResponse: return .linkLayerResponse
        }
    }
}

// MARK: - Supporting Types

public enum ControlMessageType: UInt8 {
    
    case echoRequest
    case echoResponse
    case pathRequest
    case pathResponse
    case linkLayerRequest
    case linkLayerResponse
}

public final class ControlMessageController {
    
    public static var payloadType: PayloadType { return .controlMessage }
    
    
}
