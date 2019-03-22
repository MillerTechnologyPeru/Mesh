//
//  Error.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/22/19.
//

import Foundation

public enum CommandError: Error {
    
    /// Bluetooth controllers not availible.
    case bluetoothUnavailible
    
    case invalidOption(String)
    
    case missingOption(Option)
    
    case optionMissingValue(Option)
    
    case invalidOptionValue(option: Option, value: String)
}
