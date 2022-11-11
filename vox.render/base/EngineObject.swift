//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class EngineObject {
    private static var _instanceIdCounter: Int = 0

    /// Engine unique id.
    let instanceId: Int

    /// Engine to which the object belongs.
    var _engine: Engine
    var _destroyed: Bool = false

    /// Get the engine which the object belongs.
    var engine: Engine {
        get {
            _engine
        }
    }

    /// Whether it has been destroyed.
    var destroyed: Bool {
        get {
            _destroyed
        }
    }

    init(_ engine: Engine) {
        EngineObject._instanceIdCounter += 1
        instanceId = EngineObject._instanceIdCounter

        _engine = engine
    }

    /// Destroy self.
    func destroy() {
        if (_destroyed) {
            return;
        }

        // _engine.resourceManager?._deleteAsset(this);
        _destroyed = true;
    }
}