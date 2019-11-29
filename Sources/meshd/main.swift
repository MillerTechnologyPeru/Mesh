import Foundation
import CoreFoundation
import Bluetooth
import GATT
import Mesh
import LoStik

#if os(Linux)
import Glibc
import BluetoothLinux
#elseif os(macOS)
import Darwin
import BluetoothDarwin
import DarwinGATT
#endif

#if os(Linux)
typealias LinuxPeripheral = GATTPeripheral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>
#elseif os(macOS)
#endif

private var meshController: Mesh?
private var advertisingTimer: Timer?
private var enableAdvertising = true

@available(macOS 10.12, *)
func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    let arguments = Array(arguments.dropFirst())
    
    // parse commands
    let parameters = try Parameter.parse(arguments: arguments)
    
    let identifier: UUID
    
    if let identifierString = parameters.first(where: { $0.option == .identifier })?.value {
        
        guard let identifierValue = UUID(uuidString: identifierString)
            else { throw CommandError.invalidOptionValue(option: .identifier, value: identifierString) }
        
        identifier = identifierValue
        
    } else {
        
        identifier = UUID()
    }
    
    print("Identifier: \(identifier)")
    
    // Load LoRa Module
    guard let loStikPath = parameters.first(where: { $0.option == .loStik })?.value
        else { throw CommandError.missingOption(.loStik) }
    
    let loStik = try LoStik(port: loStikPath)
    
    let loRaInterface = LoRaMeshSocket(identifier: identifier, socket: LoStikSocket(device: loStik))
    
    // load mesh controller
    let mesh = Mesh(identifier: identifier)
    mesh.add(interface: loRaInterface)
    
    meshController = mesh // retain object
    
    // add gatt controller
    if let hostController = HostController.default {
        
        let address = try hostController.readDeviceAddress()
        
        print("Bluetooth Controller: \(address)")
        
        // enter and exit iBeacon at intervals
        let beacon = AppleBeacon(uuid: UUID(rawValue: "94D457BC-4F44-46DE-9EC6-1E3C8A045780")!, major: 0, minor: 0, rssi: 10)
        try hostController.iBeacon(beacon, flags: [.notSupportedBREDR, .lowEnergyGeneralDiscoverableMode])
        
        // TODO: Advertise alternative iBeacon when data is recieved.
        
        // advertise every 30 sec to refresh iBeacon status
        advertisingTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            do { try hostController.enableLowEnergyAdvertising(enableAdvertising) }
            catch HCIError.commandDisallowed { }
            catch { print("Could not enable / disable Bluetooth advertising") }
            enableAdvertising = !enableAdvertising
        }
        
        // initialize GATT Peripheral
        #if os(Linux)
        let serverSocket = try L2CAPSocket.lowEnergyServer(controllerAddress: hostController.address,
                                                           isRandom: false,
                                                           securityLevel: .low)
        let options = GATTPeripheralOptions(maximumTransmissionUnit: .max,
                                            maximumPreparedWrites: 1000)
        let peripheral = LinuxPeripheral(controller: hostController, options: options)
        peripheral.newConnection = {
            let socket = try serverSocket.waitForConnection()
            let central = Central(identifier: socket.address)
            print("Peripheral: [\(central)]: New \(socket.addressType) connection")
            return (socket, central)
        }
        #elseif os(macOS)
        let peripheral = DarwinPeripheral()
        #endif
        
        peripheral.log = { print("Peripheral:", $0) }
        
        #if os(macOS)
        // wait until XPC connection to bluetoothd is established and hardware is on
        try peripheral.waitPowerOn()
        #endif
        
        try peripheral.start()
        
        //mesh.add(interface: gattInterface)
    }
    
    // requests
    if let controlMessage = mesh.protocols[.controlMessage] as? ControlMessageProtocol {
        
        DispatchQueue.global().async {
            parameters
                .filter { $0.option == .ping }
                .compactMap { UUID(uuidString: $0.value) }
                .forEach {
                    print("Ping \($0)")
                    do { try controlMessage.echo($0, timeout: 30) }
                    catch { print("Unable to send ping to \($0)") }
            }
        }
    }
    
    RunLoop.main.run()
}

if #available(macOS 10.12, *) {
    do { try run() }
    catch { fatalError("\(error)") }
} else {
    fatalError("Cannot run on this platform")
}

extension POSIXError: CustomStringConvertible {
    
    public var description: String {
        return String(cString: strerror(CInt(code.rawValue)), encoding: .ascii)!
    }
}
