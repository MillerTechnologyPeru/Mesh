//
//  ControlMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

public enum ControlMessage: Equatable, MessagePayload {
    
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

public enum ControlMessageError: Error {
    
    case timeout
}

public final class ControlMessageProtocol: MeshProtocolController {
    
    public static var payloadType: PayloadType { return .controlMessage }
    
    public typealias Payload = ControlMessage
    
    public let identifier: UUID
    
    public weak var delegate: MeshProtocolControllerDelegate?
    
    public var log: ((String) -> ())?
    
    private var requests = [Request]()
    
    public init(identifier: UUID) {
        
        self.identifier = identifier
    }
    
    public func didReceiveMessage(_ message: Message) {
        
        assert(message.destination == identifier)
        
        guard let controlMessage = ControlMessage(data: message.payload) else {
            log?("Invalid control message \(message.identifier)")
            return
        }
        
        // handle requests
        switch controlMessage {
        case .echoRequest:
            send(.echoResponse, to: message.source) // respond
        case let .pathRequest(hopLimit):
            // calculate how many hops
            let hops = hopLimit - message.hopLimit
            send(.pathRequest(hops), to: message.source)
        case .linkLayerRequest:
            // get supported link layers
            let layers = delegate?.protocolControllerLinkLayers(self) ?? Set()
            send(.linkLayerResponse(layers), to: message.source)
        default:
            // handle responses
            guard let requestIndex = requests.firstIndex(where: { $0.destination == message.source && $0.responseType == controlMessage.type }) else {
                log?("Unknown control message response \(message.identifier) \(controlMessage.type)")
                return
            }
            let request = requests[requestIndex]
            request.stopWaiting(response: controlMessage)
            requests.remove(at: requestIndex)
        }
    }
    
    private func send(_ message: ControlMessage, to destination: UUID) {
        
        guard let delegate = self.delegate
            else { assertionFailure(); return }
        
        let message = Message(
            source: identifier,
            destination: destination,
            payload: message)
        
        delegate.protocolController(self, shouldTransmit: message)
    }
    
    private func request(_ message: ControlMessage,
                         destination: UUID,
                         responseType: ControlMessageType,
                         timeout: TimeInterval) throws -> ControlMessage {
        
        send(message, to: destination)
        
        let request = Request(destination: destination,
                              requestType: message.type,
                              responseType: responseType)
        
        requests.append(request)
        
        return try request.wait(timeout: timeout)
    }
    
    public func echo(_ destination: UUID, timeout: TimeInterval) throws {
        
        let response = try request(.echoRequest, destination: destination, responseType: .echoResponse, timeout: timeout)
        
        assert(response == .echoResponse)
    }
}

private extension ControlMessageProtocol {
    
    final class Request {
        
        let date: Date = Date()
        
        let destination: UUID
        
        let requestType: ControlMessageType
        
        let responseType: ControlMessageType
        
        private var response: ControlMessage?
        
        init(destination: UUID, requestType: ControlMessageType, responseType: ControlMessageType) {
            
            self.destination = destination
            self.requestType = requestType
            self.responseType = responseType
        }
        
        private let semaphore = DispatchSemaphore(value: 0)
        
        func wait(timeout: TimeInterval) throws -> ControlMessage {
            
            let result = semaphore.wait(timeout: .now() + timeout)
            
            switch result {
            case .success:
                guard let response = self.response
                    else { fatalError("Missing response") }
                return response
            case .timedOut:
                throw ControlMessageError.timeout
            }
        }
        
        func stopWaiting(response: ControlMessage) {
            
            self.response = response
            semaphore.signal()
        }
    }
}
