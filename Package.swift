// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.10"

let frameworks = ["ffmpegkit": "f4ccf9208dced2b4774cc53f984b640447a877e97d8b8e972d676c2ee5411ee5", "libavcodec": "8130c36c9e09f824dcb6782f30a07e94003b4f2ea003616755782cd790cb362b", "libavdevice": "a45a8818a60f6a0cd56c9d0cf406ef47e6d63afa2da1783e00b7c5ef85853b2d", "libavfilter": "728a4f21eeafe4020a68e064032ea9447af28c24acfaee27008b1107b67664bf", "libavformat": "407e42f57dd8bf4f0a29b9e59468435c24b1a2a060981f55d217bba93e8cb063", "libavutil": "5dad7cb7c40885d58f73c92ac4eda9201ee31f3b45b923658bd6cec9771e78c6", "libswresample": "09b627066e7ecfef82b88cf528ea56f92b428c75af694572da94c38bfd0107a3", "libswscale": "d960f6497e5835021dfc7d87e54592f4136c24a6e4ac9ebe1f89ee15fe0ac7cf"]

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
