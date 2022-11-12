//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class EngineObject {
    private static var _instanceIdCounter: Int = 0
    /// Engine to which the object belongs.
    internal var _engine: Engine

    /// Engine unique id.
    public let instanceId: Int

    /// Get the engine which the object belongs.
    public var engine: Engine {
        get {
            _engine
        }
    }

    public init(_ engine: Engine) {
        EngineObject._instanceIdCounter += 1
        instanceId = EngineObject._instanceIdCounter

        _engine = engine
    }

    deinit {
        // _engine.resourceManager?._deleteAsset(this);
    }
}