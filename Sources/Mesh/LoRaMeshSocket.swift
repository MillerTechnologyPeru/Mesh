//
//  LoRaMeshSocket.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/20/19.
//

import Foundation

@available(macOS 10.12, *)
public final class LoRaMeshSocket <Socket: LoRaSocket> : MeshInterface {
    
    public static var linkLayer: LinkLayer { return .loRa }
    
    // MARK: - Properties
    
    public var read: (Message) -> () = { _ in }
    
    public let socket: Socket
    
    public let identifier: UUID
    
    public var recieveWindowSize: UInt16 = 10
    
    public var transmitWindowSize: UInt16 = 10
    
    public var log: ((String) -> ())?
    
    internal private(set) var transmitQueue = [LoRaMessage]()
    
    private lazy var queue = DispatchQueue(label: "LoRa Mesh Socket Queue")
    
    private var forwardedMessages = Set<UUID>()
    
    // MARK: - Initialization
    
    public init(identifier: UUID = UUID(), socket: Socket) {
        self.identifier = identifier
        self.socket = socket
        self.run()
    }
    
    // MARK: - Methods
    
    public func write(_ message: Message) throws {
        
        queue.async { [weak self] in
            self?.transmitQueue.append(.meshMessage(LoRaMeshMessage(message: message)))
        }
    }
    
    private func run() {
        
        queue.async { [weak self] in
            
            while let meshSocket = self {
                
                let loRa = meshSocket.socket
                
                //
                do {
                    if let recievedData = try loRa.recieve(windowSize: meshSocket.recieveWindowSize) {
                        
                        guard let message = LoRaMessage(data: recievedData) else {
                            meshSocket.log?("Could not parse LoRa message")
                            return
                        }
                        
                        switch message {
                        case let .advertisement(advertisement):
                            meshSocket.log?("Received advertisement for \(advertisement.identifier)")
                        case let .meshMessage(meshMessage):
                            meshSocket.log?("Recieved message \(meshMessage.message.identifier)")
                            meshSocket.read(meshMessage.message)
                            /*
                            // consume or forward
                            if meshMessage.message.destination == meshSocket.identifier {
                                meshSocket.read(meshMessage.message)
                            } else {
                                // add message to blacklist
                                meshSocket.forwardedMessages.insert(meshMessage.message.identifier)
                                
                            }*/
                        }
                    }
                } catch { meshSocket.log?("Could not recieve data: \(error)") }
                
                // write
                if let message = meshSocket.transmitQueue.first {
                    meshSocket.transmitQueue.removeFirst() // remove from queue
                    
                    for _ in 0 ..< meshSocket.transmitWindowSize {
                        
                        do { try loRa.transmit(message.data) }
                        catch { meshSocket.log?("Failed to transmit message") }
                    }
                }
            }
        }
    }
}
