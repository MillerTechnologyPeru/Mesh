//
//  Mesh.swift
//  ColemanCDA
//
//  Created by Alsey Coleman Miller on 3/15/19.
//  Copyright © 2019 ColemanCDA. All rights reserved.
//

import Foundation

/// Socket for writing mesh messages / packets.
public protocol MeshSocket {
    
    func write(_ message: Message) throws
    
    var read: (Message) -> () { get }
}
