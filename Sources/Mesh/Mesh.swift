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
    
    internal private(set) var forwardedMessages = Set<UUID>()
    
    public init(identifier: UUID = UUID()) {
        
        self.identifier = identifier
    }
    
    public func add(interface: MeshInterface) {
        
        interfaces.append(interface)
        interface.read = { [weak self] in self?.didReceive($0, from: interface) }
    }
    
    private func didReceive(_ message: Message, from interface: MeshInterface) {
        
        var message = message
        
        if message.destination == identifier {
            guard let controller = protocols[message.payloadType] else {
                log?("Cannot handle protocol \(message.payloadType)")
                return
            }
            controller.didReceiveMessage(message)
        } else {
            if message.hopLimit > 0 {
                message.hopLimit -= 1 // decrease TTL
            }
            guard message.hopLimit >= 1 else {
                log?("Too many hops, message will be discarded")
                return
            }
            // forward
            for forwardInterface in interfaces {
                guard forwardInterface !== interface
                    else { continue } // dont forward on same interface recieved from
                do { try forwardInterface.write(message) }
                catch { log?("Could not forward message \(message)") }
                forwardedMessages.insert(message.identifier)
            }
        }
    }
}

public protocol MeshProtocolController: class {
    
    static var payloadType: PayloadType { get }
    
    func didReceiveMessage(_ message: Message)
    
    var transmitMessage: (Message) -> () { get }
}
