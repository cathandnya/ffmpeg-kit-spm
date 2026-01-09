// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.10"

let frameworks = ["ffmpegkit": "2d98fae4dfc7414aa9f00858bf13a1d5163a71531f2b116843bf8732eabaf514", "libavcodec": "be0669da1a623d71a0e9f288271eabb79237073a50fa44729c265292860c97ed", "libavdevice": "1f6b94761290191a6364844bd86f6a14ca180594c8b3217652e9c70e7a132152", "libavfilter": "e9b51738375d342366074affaaa76ee151309ef59ea294bbde7ca5a6ff444508", "libavformat": "52665b7a3a2ce381d21c93f7d4e7e81ec96975c2ab7a8754dd2e96fba09ce68e", "libavutil": "3f87e4f061df96d6e3641eb3e6c1efd402242a767d9fd4367b6e21dd18e2d6b8", "libswresample": "b1c4fa39e0227831c7ce28eec3ab7879b953cae9e708d12a7294d76103782c40", "libswscale": "aab397c2149abdd105bfe871389b4dc4cefa072493238db24506f5567c9cb0af"]

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
