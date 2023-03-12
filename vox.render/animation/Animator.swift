//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// The controller of the animation system.
public class Animator: Component {
    var _nativeAnimator: CAnimator
    var _onUpdateIndex: Int = -1
    private var _rootState: AnimationState?
    private var _entityBindingMap: [UInt32: Set<Entity>] = [:]


    public var rootState: AnimationState? {
        get {
            _rootState
        }
        set {
            _rootState = newValue
            _nativeAnimator.setRootState(newValue?._nativeState)
        }
    }

    public var localToModelFromExcluded: Bool {
        get {
            _nativeAnimator.localToModelFromExcluded
        }
        set {
            _nativeAnimator.localToModelFromExcluded = newValue
        }
    }

    public var localToModelFrom: Int {
        get {
            Int(_nativeAnimator.localToModelFrom)
        }
        set {
            _nativeAnimator.localToModelFrom = Int32(newValue)
        }
    }

    public var localToModelTo: Int {
        get {
            Int(_nativeAnimator.localToModelTo)
        }
        set {
            _nativeAnimator.localToModelTo = Int32(newValue)
        }
    }

    public required init(_ entity: Entity) {
        _nativeAnimator = CAnimator()
        super.init(entity)
    }

    override func _onDestroy() {
        _nativeAnimator.destroy()
    }
    
    @discardableResult
    public func loadSkeleton(_ url: URL) -> Bool {
        _nativeAnimator.loadSkeleton(url.path(percentEncoded: false))
    }

    public func bindEntity(_ entity: Entity, for name: String) {
        let index = _nativeAnimator.findJontIndex(name)
        if index != UInt32.max {
            if _entityBindingMap[index] != nil {
                _entityBindingMap[index]?.insert(entity)
            } else {
                _entityBindingMap[index] = [entity]
            }
        }
    }
    
    /// Computes the bounding box of _skeleton. This is the box that encloses all skeleton's joints in model space.
    func computeSkeletonBounds() -> BoundingBox {
        var min = SIMD3<Float>()
        var max = SIMD3<Float>()
        _nativeAnimator.computeSkeletonBounds(&min, &max)
        return BoundingBox(Vector3(min), Vector3(max))
    }

    func fillPostureUniforms(_ uniforms: inout [Float]) -> Int {
        Int(_nativeAnimator.fillPostureUniforms(&uniforms))
    }

    /// Evaluates the animator component based on deltaTime.
    /// - Parameter deltaTime: The deltaTime when the animation update
    func update(_ deltaTime: Float) {
        _nativeAnimator.update(deltaTime)

        // sync to attach entity
        _entityBindingMap.forEach { (key: UInt32, value: Set<Entity>) in
            let matrix = Matrix(_nativeAnimator.models(at: key))
            value.forEach { entity in
                entity.transform.localMatrix = matrix
            }
        }
    }

    internal override func _onEnable() {
        engine._componentsManager.addOnUpdateAnimations(self)
    }

    internal override func _onDisable() {
        engine._componentsManager.removeOnUpdateAnimations(self)
    }
}
