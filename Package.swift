// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.8"

let frameworks = ["ffmpegkit": "5a38f362bc0dc8b2fa0edbf01189e1d39ea77a9e5b8692a95d302c0220119299", "libavcodec": "1a30e952cc81699c65af1adedbb87c43678991624166ba2d2ca2d95608c8f36f", "libavdevice": "8c3978629ea47cc100ab64fb52490d579fed64252a0dbca1afefad484ebba5fc", "libavfilter": "438936201e18cbf332ab088639c4885c8e106fa7b55aeab2f3bd32d6fc0da32e", "libavformat": "6f355bda13284de53cd86f8bcf18cc766bc8d9af1396c1ee27f43f3e39d29d42", "libavutil": "84edfe96c394d55d9f341d60a71b6e1cb428259621a3e353990e3fce4232be60", "libswresample": "12512a738865629d2b7c265bd1489ed90f03d348c94726f798c8593c2e31db6c", "libswscale": "ad3d2bcedd45ff33e26e55bcdf79898dae20bd4bad394b6116e2d6aecc8c147e"]

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
