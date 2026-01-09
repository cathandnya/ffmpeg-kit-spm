// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.9"

let frameworks = ["ffmpegkit": "f769a9534b840e0a55beaad3992c041a1cb4194561f1510d07a5e12024120405", "libavcodec": "53ae12592f4012186695282bc6b39c9fc33b464fb61205cfdeeb8666c5ac6fb1", "libavdevice": "d112623920cfac9a4f24ac6cfcd448c9bbaa0dededf69e3054c16d39d00d3393", "libavfilter": "c0f102407af7e89efc6566212bf9e3c66b32d00099602b397bca9855284e8c1f", "libavformat": "4a235a2e4a953d4c7a801a3234ea6756d362cf8e94a7680b86c227bb410edba4", "libavutil": "51d27ade6f23d38036fb547ca27ac4efe46efec371e79529569f93e76399e993", "libswresample": "597729ce063c0d39ba75c399e16039f700f9602b451cd5c311febe02ffb57217", "libswscale": "b560ceb6589e3575a204e693714c823626a0c4af721481465ae6ef3631583824"]

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
