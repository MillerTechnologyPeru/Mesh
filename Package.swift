// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let nativeBluetooth: Target.Dependency = "BluetoothLinux"
let nativeGATT: Target.Dependency = "GATT"
#elseif os(macOS)
let nativeBluetooth: Target.Dependency = "BluetoothDarwin"
let nativeGATT: Target.Dependency = "DarwinGATT"
#endif

let package = Package(
    name: "Mesh",
    products: [
        .library(
            name: "Mesh",
            targets: ["Mesh"]
        ),
        .executable(
            name: "meshutil",
            targets: ["meshutil"]
        ),
        .executable(
            name: "meshd",
            targets: ["meshd"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothLinux.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothDarwin.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/MillerTechnologyPeru/LoStik.git",
            .branch("swift")
        )
    ],
    targets: [
        .target(
            name: "Mesh",
            dependencies: ["Bluetooth", "GATT", "LoStik"]),
        .target(
            name: "meshutil",
            dependencies: ["Mesh"]),
        .target(
            name: "meshd",
            dependencies: [
                "Mesh",
                nativeBluetooth,
                nativeGATT
            ]),
        .testTarget(
            name: "MeshTests",
            dependencies: ["Mesh"]
        )
    ]
)
