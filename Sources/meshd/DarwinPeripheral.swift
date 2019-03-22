//
//  DarwinPeripheral.swift
//  meshd
//
//  Created by Alsey Coleman Miller on 3/22/19.
//

import Foundation
import Bluetooth
import GATT

#if os(macOS)

import DarwinGATT

extension DarwinPeripheral {
    
    /// Wait for CoreBluetooth to be ready.
    func waitPowerOn(warning: Int = 3, timeout: Int = 10) throws {
        
        var powerOnWait = 0
        while state != .poweredOn {
            
            // inform user after 3 seconds
            if powerOnWait == warning {
                
                print("Waiting for CoreBluetooth to be ready, please turn on Bluetooth")
            }
            
            sleep(1)
            
            powerOnWait += 1
            
            guard powerOnWait < timeout
                else { throw CommandError.bluetoothUnavailible }
        }
    }
}

#endif
