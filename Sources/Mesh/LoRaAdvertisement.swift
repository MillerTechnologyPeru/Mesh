//
//  LoRaAdvertisement.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Advertisment
public struct LoRaAdvertisement: Equatable, Hashable, LoRaMessageProtocol {
    
    public static let messageType: LoRaMessageType = .advertisement
    
    /// LoRa Device identifier / Address
    public let identifier: UUID
    
    /// Device physical location
    public let location: Location?
    
    public init(identifier: UUID,
                location: Location? = nil) {
        
        self.identifier = identifier
        self.location = location
    }
}

internal extension LoRaAdvertisement {
    
    var flags: BitMaskOptionSet<Flag> {
        
        var flags = BitMaskOptionSet<Flag>()
        
        if location != nil {
            flags.insert(.location)
        }
        
        return flags
    }
}

public extension LoRaAdvertisement {
    
    public init?(data: Data) {
        
        var data = DataIterator(data: data)
        
        guard let messageType = data.consume({ LoRaMessageType(rawValue: $0) }),
            messageType == type(of: self).messageType,
            let identifier = data.consume(UUID.self)?.littleEndian,
            let flags = data.consume({ BitMaskOptionSet<Flag>(rawValue: $0) }),
            let location = data.consume(Location.self)
            else { return nil }
        
        self.identifier = identifier
        self.location = flags.contains(.location) ? location : nil
    }
    
    public var data: Data {
        
        return Data(self)
    }
}

// MARK: - DataConvertible

extension LoRaAdvertisement: DataConvertible {
    
    static func += <T: DataContainer> (data: inout T, value: LoRaAdvertisement) {
        
        data += type(of: value).messageType.rawValue
        data += value.identifier.littleEndian
        data += value.flags.rawValue
        data += value.location ?? Location(latitude: 0, longitude: 0)
    }
    
    var dataLength: Int {
        
        return 1 + UUID.length + 1 + Location.length
    }
}

// MARK: - Supporting Types

public extension LoRaAdvertisement {
    
    /// The latitude and longitude associated with a location, specified using the WGS 84 reference frame.
    public struct Location: Equatable, Hashable {
        
        /// A latitude or longitude value specified in degrees.
        public typealias Degrees = Double
        
        /// The latitude in degrees.
        public var latitude: Degrees
        
        /// The longitude in degrees.
        public var longitude: Degrees
        
        public init(latitude: Location.Degrees, longitude: Location.Degrees) {
            
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

extension LoRaAdvertisement.Location: DataConvertible {
    
    static func += <T: DataContainer> (data: inout T, value: LoRaAdvertisement.Location) {
        
        data += value.latitude.littleEndian
        data += value.longitude.littleEndian
    }
    
    var dataLength: Int {
        
        return type(of: self).length
    }
}

extension LoRaAdvertisement.Location: DataIterable {
    
    static var length: Int {
        
        return MemoryLayout<Double>.size * 2
    }
    
    init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        var data = DataIterator(data: data)
        
        guard let latitude = data.consume(Double.self)?.littleEndian,
            let longitude = data.consume(Double.self)?.littleEndian
            else { return nil }
        
        self.init(latitude: latitude, longitude: longitude)
    }
}

internal extension LoRaAdvertisement {
    
    internal enum Flag: UInt8, BitMaskOption {
        
        case location = 0b01
    }
}

