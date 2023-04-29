//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class Constants {
    public let maxVertsPerMesh = 65000
    public let maxInstancesPerBatch = 1023
}

public enum ObiUtils {
    public static let epsilon: Float = 0.0000001
    public static let sqrt3: Float = 1.73205080
    public static let sqrt2: Float = 1.41421356

    public static let FilterMaskBitmask = 0xFFFF_0000
    public static let FilterCategoryBitmask = 0x0000_FFFF
    public static let ParticleGroupBitmask = 0x00FF_FFFF

    public static let CollideWithEverything = 0x0000_FFFF
    public static let CollideWithNothing = 0x0

    public static let MaxCategory = 15
    public static let MinCategory = 0

    public struct ParticleFlags: OptionSet {
        public let rawValue: UInt32

        /// this initializer is required, but it's also automatically
        /// synthesized if `rawValue` is the only member, so writing it
        /// here is optional:
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let SelfCollide = ParticleFlags(rawValue: 1 << 24)
        public static let Fluid = ParticleFlags(rawValue: 1 << 25)
        public static let OneSided = ParticleFlags(rawValue: 1 << 26)
    }

    // Colour alphabet from https://www.aic-color.org/resources/Documents/jaic_v5_06.pdf
    public static let colorAlphabet: [Color32] = [
        Color32(r: 240, g: 163, b: 255, a: 255),
        Color32(r: 0, g: 117, b: 220, a: 255),
        Color32(r: 153, g: 63, b: 0, a: 255),
        Color32(r: 76, g: 0, b: 92, a: 255),
        Color32(r: 25, g: 25, b: 25, a: 255),
        Color32(r: 0, g: 92, b: 49, a: 255),
        Color32(r: 43, g: 206, b: 72, a: 255),
        Color32(r: 255, g: 204, b: 153, a: 255),
        Color32(r: 128, g: 128, b: 128, a: 255),
        Color32(r: 148, g: 255, b: 181, a: 255),
        Color32(r: 143, g: 124, b: 0, a: 255),
        Color32(r: 157, g: 204, b: 0, a: 255),
        Color32(r: 194, g: 0, b: 136, a: 255),
        Color32(r: 0, g: 51, b: 128, a: 255),
        Color32(r: 255, g: 164, b: 5, a: 255),
        Color32(r: 255, g: 168, b: 187, a: 255),
        Color32(r: 66, g: 102, b: 0, a: 255),
        Color32(r: 255, g: 0, b: 16, a: 255),
        Color32(r: 94, g: 241, b: 242, a: 255),
        Color32(r: 0, g: 153, b: 143, a: 255),
        Color32(r: 224, g: 255, b: 102, a: 255),
        Color32(r: 116, g: 10, b: 255, a: 255),
        Color32(r: 153, g: 0, b: 0, a: 255),
        Color32(r: 255, g: 255, b: 128, a: 255),
        Color32(r: 255, g: 255, b: 0, a: 255),
        Color32(r: 255, g: 80, b: 5, a: 255),
    ]

    public static let categoryNames: [String] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15",
    ]
}
