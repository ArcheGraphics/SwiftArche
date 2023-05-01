//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiEmitterShapeCube: ObiEmitterShape {
    public enum SamplingMethod {
        /// distributes particles in the surface of the object.
        case SURFACE
        /// distributes particles in the volume of the object.
        case VOLUME
    }

    public var samplingMethod = SamplingMethod.VOLUME

    public var size = Vector3.one * 0.25

    override public func GenerateDistribution() {}
}
