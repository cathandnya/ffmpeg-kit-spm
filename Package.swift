// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.7"

let frameworks = ["ffmpegkit": "1e4d0c80cd3af9a88682df4de6e261717820d09bd4dbb34fe143b8ad21023d06", "libavcodec": "5457510c64a4e7fa3a6da73b091d9068af2fb587cb865588e226ba0651d606bb", "libavdevice": "cfa27986c72ba39a8d85a9f0af9a8bdb06afd3f401a5a06967d4099541f523ab", "libavfilter": "f2e905ad68a328f5966e714106350bac852fd7c527754cd5aa1d5330b189fc74", "libavformat": "cc2351ed2dc11a10975147b8b720b11312b4fa54b5c6521822db9644e0d9adf7", "libavutil": "c004468f9ccfccf029cd7a12bbf7acc908b3965e70b68e97ed8aa6fdd228ac58", "libswresample": "579b6d83cef796f76b3efb719d7640128b59b89ab8114bcfdf4f1c7b910fa36a", "libswscale": "ed26fb4bd4648a8e391a3818f958efccbdd8a2bc45e1eca14a9cbf561167ca4c"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/cathandnya/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
