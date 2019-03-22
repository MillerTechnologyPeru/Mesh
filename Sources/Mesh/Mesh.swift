//
//  Mesh.swift
//  ColemanCDA
//
//  Created by Alsey Coleman Miller on 3/15/19.
//  Copyright © 2019 ColemanCDA. All rights reserved.
//

import Foundation

/// Socket for writing mesh messages / packets.
public protocol MeshInterface: class {
    
    static var linkLayer: LinkLayer { get }
    
    func write(_ message: Message) throws
    
    var read: (Message) -> () { get set }
}

public final class Mesh {
    
    public let identifier: UUID
    
    public var log: ((String) -> ())?
    
    public private(set) var interfaces = [MeshInterface]()
    
    public private(set) var protocols = [PayloadType: MeshProtocolController]()
    
    internal private(set) var sentMessages = Set<UUID>() // TODO: Cache limit
    
    public init(identifier: UUID = UUID()) {
        
        self.identifier = identifier
        loadStandardProtocols()
    }
    
    private func loadStandardProtocols() {
        
        load(protocol: ControlMessageProtocol.self)
    }
    
    public func load<T: MeshProtocolController>(protocol controllerType: T.Type) {
        
        let controller = T.init(identifier: identifier)
        protocols[T.payloadType] = controller
        controller.delegate = self
    }
    
    public func add(interface: MeshInterface) {
        
        interfaces.append(interface)
        interface.read = { [weak self] in self?.didReceive($0, from: interface) }
    }
    
    private func transmit(_ message: Message) {
        
        for interface in interfaces {
            
            do { try interface.write(message) }
            catch { log?("Could not send message \(message.identifier)") }
        }
        
        sentMessages.insert(message.identifier)
    }
    
    private func didReceive(_ message: Message, from interface: MeshInterface) {
        
        var message = message
        
        if message.destination == identifier {
            guard let controller = protocols[message.payloadType] else {
                log?("Cannot handle protocol \(message.payloadType) for message \(message.identifier)")
                return
            }
            controller.didReceiveMessage(message)
        } else {
            if message.hopLimit > 0 {
                message.hopLimit -= 1 // decrease TTL
            }
            guard message.hopLimit >= 1 else {
                log?("Too many hops, message \(message.identifier) will be discarded")
                return
            }
            guard sentMessages.contains(message.identifier) == false else {
                log?("Already forwarded, message \(message.identifier) will be discarded")
                return
            }
            // forward
            for forwardInterface in interfaces {
                guard forwardInterface !== interface
                    else { continue } // dont forward on same interface recieved from
                do { try forwardInterface.write(message) }
                catch { log?("Could not forward message \(message.identifier)") }
                sentMessages.insert(message.identifier)
            }
        }
    }
}

// MARK: - MeshProtocolControllerDelegate

extension Mesh: MeshProtocolControllerDelegate {
    
    public func protocolController(_ controller: MeshProtocolController, shouldTransmit message: Message) {
        
        transmit(message)
    }
    
    public func protocolControllerLinkLayers(_ controller: MeshProtocolController) -> Set<LinkLayer> {
        
        return Set(interfaces.map({ type(of: $0).linkLayer }))
    }
}

// MARK: - Supporting Types

public protocol MeshProtocolController: class {
    
    static var payloadType: PayloadType { get }
    
    var identifier: UUID { get }
    
    init(identifier: UUID)
    
    func didReceiveMessage(_ message: Message)
    
    var delegate: MeshProtocolControllerDelegate? { get set }
}

public protocol MeshProtocolControllerDelegate: class {
    
    func protocolController(_ controller: MeshProtocolController, shouldTransmit message: Message)
    
    func protocolControllerLinkLayers(_ controller: MeshProtocolController) -> Set<LinkLayer>
}
