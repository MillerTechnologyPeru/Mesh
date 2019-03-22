// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let nativeGATT = "DarwinGATT"
let nativeBluetooth = "BluetoothDarwin"
#elseif os(Linux)
let nativeGATT = "GATT"
let nativeBluetooth = "BluetoothLinux"
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
        .package(url: "https://github.com/PureSwift/\(nativeBluetooth).git", .branch("master")),
        .package(url: "https://github.com/PureSwift/GATT.git", .branch("master")),
        .package(url: "https://github.com/MillerTechnologyPeru/LoStik.git", .branch("swift")),
    ],
    targets: [
        .target(
            name: "Mesh",
            dependencies: ["GATT", "LoStik"]),
        .target(
            name: "meshutil",
            dependencies: ["Mesh"]),
        .target(
            name: "meshd",
            dependencies: [
                "Mesh",
                .byNameItem(name: nativeBluetooth),
                .byNameItem(name: nativeGATT)
            ]),
        .testTarget(
            name: "MeshTests",
            dependencies: ["Mesh"]),
    ]
)
