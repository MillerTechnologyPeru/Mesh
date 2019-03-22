//
//  LoStik.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/20/19.
//

#if canImport(LoStik)
import Foundation
import LoStik

public final class LoStikSocket: LoRaSocket {
    
    public let device: LoStik
    
    public init(device: LoStik) {
        self.device = device
    }
    
    public func transmit(_ data: Data) throws {
        
        try device.mac.pause()
        try device.radio.transmit(data)
    }
    
    public func recieve(windowSize: UInt16) throws -> Data? {
        
        try device.mac.pause()
        var responseData: Data?
        do { responseData = try device.radio.recieve(windowSize: windowSize) }
        catch LoStikError.errorCode(.radioError) { } // ignore time-out errors
        return responseData
    }
}

#endif
