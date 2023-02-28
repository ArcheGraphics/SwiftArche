//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public struct KCCSettings {
    /// Determines if the system simulates automatically.
    /// If true, the simulation is done on FixedUpdate
    public var AutoSimulation = true
    /// Should interpolation of characters and PhysicsMovers be handled
    public var Interpolate = true

    /// Initial capacity of the system's list of Motors (will resize automatically if needed, but setting a high initial capacity can help preventing GC allocs)
    public var MotorsListInitialCapacity = 100
    /// Initial capacity of the system's list of Movers (will resize automatically if needed, but setting a high initial capacity can help preventing GC allocs)
    public var MoversListInitialCapacity = 100
}
