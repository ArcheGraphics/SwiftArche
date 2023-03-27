//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class EngineVisualizer: Script {
    private static let _ndcPosition: [Vector3] = [
        Vector3(-1, 1, -1),
        Vector3(1, 1, -1),
        Vector3(1, -1, -1),
        Vector3(-1, -1, -1)
    ]
    private static let _halfSqrt: Float = 0.70710678118655

    private var _localPositions: [Vector3] = []
    private var _globalPositions: [Vector3] = []
    private var _indices = [UInt32](repeating: 0, count: 128)
    private var _indicesCount = 0
    private var _boundsIndicesCount = 0

    private var _wireframeRenderers: [Renderer] = []
    private var _wireframeElements: [WireframeElement] = []

    /// Base color.
    public var baseColor = Color32(r: 255, g: 255, b: 255)
    private var _colorPool: [Color32] = []

    /// Clear all wireframe.
    public func clear() {
        _wireframeRenderers = []
        _wireframeElements = []
        _localPositions = []
        _globalPositions = []
        _indicesCount = 0
    }

    /// Create auxiliary mesh for entity.
    /// - Parameters:
    ///   - entity: The entity
    ///   - includeChildren: Whether include child entity(default is true)
    public func addEntityWireframe(with entity: Entity, includeChildren: Bool = true) {
        if (includeChildren) {
            let cameras = entity.getComponentsIncludeChildren(Camera.self)
            for camera in cameras {
                addCameraWireframe(with: camera)
            }

            let spotLights = entity.getComponentsIncludeChildren(SpotLight.self)
            for spotLight in spotLights {
                addSpotLightWireframe(with: spotLight)
            }

            let directLights = entity.getComponentsIncludeChildren(DirectLight.self)
            for directLight in directLights {
                addDirectLightWireframe(with: directLight)
            }

            let pointLights = entity.getComponentsIncludeChildren(PointLight.self)
            for pointLight in pointLights {
                addPointLightWireframe(with: pointLight)
            }

            let colliders = entity.getComponentsIncludeChildren(Collider.self)
            for collider in colliders {
                addCollideWireframe(with: collider)
            }
        } else {
            if let camera = entity.getComponent(Camera.self) {
                addCameraWireframe(with: camera)
            }
            if let spotLight = entity.getComponent(SpotLight.self) {
                addSpotLightWireframe(with: spotLight)
            }
            if let directLight = entity.getComponent(DirectLight.self) {
                addDirectLightWireframe(with: directLight)
            }
            if let pointLight = entity.getComponent(PointLight.self) {
                addPointLightWireframe(with: pointLight)
            }
            if let collider = entity.getComponent(Collider.self) {
                addCollideWireframe(with: collider)
            }
        }
    }

    /// Create auxiliary mesh for camera.
    /// - Parameter camera: The Camera
    public func addCameraWireframe(with camera: Camera) {
        let transform = camera.entity.transform!
        var inverseProj = camera.projectionMatrix
        _ = inverseProj.invert()

        let positionsOffset = UInt32(_localPositions.count)
        _wireframeElements.append(WireframeElement(transform, Int(positionsOffset)))

        // front
        for i in 0..<4 {
            var newPosition = EngineVisualizer._ndcPosition[i]
            _ = newPosition.transformCoordinate(m: inverseProj)
            _localPositions.append(newPosition)
        }

        // back
        for i in 0..<4 {
            var newPosition = EngineVisualizer._ndcPosition[i]
            newPosition = Vector3(newPosition.x, newPosition.y, 1)
            _ = newPosition.transformCoordinate(m: inverseProj)
            _localPositions.append(newPosition)
        }

        _growthIndexMemory(24)
        _indices[_indicesCount] = positionsOffset
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 1
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 1
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 2
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 2
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 3
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 3
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset // front
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 4
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 1
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 5
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 2
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 6
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 3
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 7 // link
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 4
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 5
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 5
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 6
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 6
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 7
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 7
        _indicesCount += 1
        _indices[_indicesCount] = positionsOffset + 4 // back
        _indicesCount += 1
    }

    /// Create auxiliary mesh for spot light.
    /// - Parameter light: The SpotLight
    public func addSpotLightWireframe(with light: SpotLight) {
        let height = light.distance
        let radius = tan(light.angle / 2) * height

        let positionsOffset = _localPositions.count
        let coneIndicesCount = Int(WireframePrimitive.coneIndexCount)

        _growthIndexMemory(coneIndicesCount)
        WireframePrimitive.createConeWireframe(
                radius,
                height,
                &_localPositions,
                UInt32(positionsOffset),
                &_indices,
                _indicesCount
        )
        _indicesCount += coneIndicesCount
        // rotation to default transform forward direction(-Z)
        _rotateAroundX(positionsOffset)

        _wireframeElements.append(WireframeElement(light.entity.transform, positionsOffset))
    }

    /// Create auxiliary mesh for point light.
    /// - Parameter light: The PointLight
    public func addPointLightWireframe(with light: PointLight) {
        let positionsOffset = _localPositions.count
        let sphereIndicesCount = Int(WireframePrimitive.sphereIndexCount)

        _growthIndexMemory(sphereIndicesCount)
        WireframePrimitive.createSphereWireframe(
                light.distance,
                &_localPositions,
                UInt32(positionsOffset),
                &_indices,
                _indicesCount
        )
        _indicesCount += sphereIndicesCount

        _wireframeElements.append(WireframeElement(light.entity.transform, positionsOffset))
    }

    /// Create auxiliary mesh for directional light.
    /// - Parameter light: The DirectLight
    public func addDirectLightWireframe(with light: DirectLight) {
        let positionsOffset = _localPositions.count
        let unboundCylinderIndicesCount = Int(WireframePrimitive.unboundCylinderIndexCount)

        _growthIndexMemory(unboundCylinderIndicesCount)
        WireframePrimitive.createUnboundCylinderWireframe(1, &_localPositions, UInt32(positionsOffset), &_indices, _indicesCount)
        _indicesCount += unboundCylinderIndicesCount
        // rotation to default transform forward direction(-Z)
        _rotateAroundX(positionsOffset)

        _wireframeElements.append(WireframeElement(light.entity.transform, positionsOffset))
    }

    /// Create auxiliary mesh for renderer axis-aligned boundingbox.
    /// - Parameter renderer: The Renderer
    public func addRendererWireframe(with renderer: Renderer) {
        _boundsIndicesCount += Int(WireframePrimitive.cuboidIndexCount)
        _wireframeRenderers.append(renderer)
    }

    /// Create auxiliary mesh for collider.
    /// - Parameter collider: The Collider
    public func addCollideWireframe(with collider: Collider) {
        let shapes = collider.shapes
        for shape in shapes {
            if shape is BoxColliderShape {
                addBoxColliderShapeWireframe(with: shape as! BoxColliderShape)
            } else if shape is SphereColliderShape {
                addSphereColliderShapeWireframe(with: shape as! SphereColliderShape)
            } else if shape is CapsuleColliderShape {
                addCapsuleColliderShapeWireframe(with: shape as! CapsuleColliderShape)
            } else if shape is MeshColliderShape {
                addMeshColliderShapeWireframe(with: shape as! MeshColliderShape)
            }
        }
    }

    /// Create auxiliary mesh for box collider shape.
    /// - Parameter shape: The BoxColliderShape
    public func addBoxColliderShapeWireframe(with shape: BoxColliderShape) {
        let transform = shape.collider!.entity.transform!
        let worldScale = transform.lossyWorldScale

        let positionsOffset = _localPositions.count

        let cuboidIndicesCount = WireframePrimitive.cuboidIndexCount
        _growthIndexMemory(Int(cuboidIndicesCount))
        WireframePrimitive.createCuboidWireframe(
                worldScale.x * shape.size.x,
                worldScale.y * shape.size.y,
                worldScale.z * shape.size.z,
                &_localPositions,
                UInt32(positionsOffset),
                &_indices,
                _indicesCount
        )
        let tempRotation = Quaternion.rotationYawPitchRoll(yaw: shape.rotation.x, pitch: shape.rotation.y, roll: shape.rotation.z)
        _localRotation(positionsOffset, tempRotation)
        let tempVector = shape.position * worldScale
        _localTranslate(positionsOffset, tempVector)

        _indicesCount += Int(cuboidIndicesCount)
        _wireframeElements.append(WireframeElement(transform, positionsOffset))
    }

    /// Create auxiliary mesh for sphere collider shape.
    /// - Parameter shape: The SphereColliderShape
    public func addSphereColliderShapeWireframe(with shape: SphereColliderShape) {
        let transform = shape.collider!.entity.transform!
        let worldScale = transform.lossyWorldScale

        let positionsOffset = _localPositions.count

        let sphereIndicesCount = WireframePrimitive.sphereIndexCount
        _growthIndexMemory(Int(sphereIndicesCount))
        WireframePrimitive.createSphereWireframe(
                max(worldScale.x, worldScale.y, worldScale.z) * shape.radius,
                &_localPositions,
                UInt32(positionsOffset),
                &_indices,
                _indicesCount
        )
        let tempRotation = Quaternion.rotationYawPitchRoll(yaw: shape.rotation.x, pitch: shape.rotation.y, roll: shape.rotation.z)
        _localRotation(positionsOffset, tempRotation)
        let tempVector = shape.position * worldScale
        _localTranslate(positionsOffset, tempVector)

        _indicesCount += Int(sphereIndicesCount)
        _wireframeElements.append(WireframeElement(transform, positionsOffset))
    }

    /// Create auxiliary mesh for capsule collider shape.
    /// - Parameter shape: The CapsuleColliderShape
    public func addCapsuleColliderShapeWireframe(with shape: CapsuleColliderShape) {
        let transform = shape.collider!.entity.transform!
        let worldScale = transform.lossyWorldScale
        let maxScale = max(worldScale.x, worldScale.y, worldScale.z)
        let positionsOffset = _localPositions.count

        let capsuleIndicesCount = WireframePrimitive.capsuleIndexCount
        _growthIndexMemory(Int(capsuleIndicesCount))
        WireframePrimitive.createCapsuleWireframe(
                maxScale * shape.radius,
                maxScale * shape.height,
                &_localPositions,
                UInt32(positionsOffset),
                &_indices,
                _indicesCount
        )
        var tempAxis = Quaternion()
        switch (shape.upAxis) {
        case ColliderShapeUpAxis.X:
            tempAxis = Quaternion(x: 0, y: 0, z: EngineVisualizer._halfSqrt, w: EngineVisualizer._halfSqrt)
            break
        case ColliderShapeUpAxis.Y:
            tempAxis = Quaternion(x: 0, y: 0, z: 0, w: 1)
            break
        case ColliderShapeUpAxis.Z:
            tempAxis = Quaternion(x: EngineVisualizer._halfSqrt, y: 0, z: 0, w: EngineVisualizer._halfSqrt)
        }
        var tempRotation = Quaternion.rotationYawPitchRoll(yaw: shape.rotation.x, pitch: shape.rotation.y, roll: shape.rotation.z)
        tempRotation *= tempAxis
        _localRotation(positionsOffset, tempRotation)
        let tempVector = shape.position * worldScale
        _localTranslate(positionsOffset, tempVector)

        _indicesCount += Int(capsuleIndicesCount)
        _wireframeElements.append(WireframeElement(transform, positionsOffset))
    }
    
    public func addMeshColliderShapeWireframe(with shape: MeshColliderShape) {
        let transform = shape.collider!.entity.transform!
        let worldScale = transform.lossyWorldScale
        let positionsOffset = _localPositions.count

        let points = shape.colliderPoints
        let indices = shape.colliderWireframeIndices
        
        _growthIndexMemory(indices.count)
        for i in 0..<indices.count {
            _indices[_indicesCount + i] = indices[i] + UInt32(positionsOffset)
        }
        points.forEach({ v in
            _localPositions.append(worldScale * v)
        })
        
        _indicesCount += indices.count
        _wireframeElements.append(WireframeElement(transform, positionsOffset))
    }

    public override func onGUI() {
        // update local to world geometry
        let localPositionLength = _localPositions.count
        if localPositionLength > _globalPositions.count {
            _globalPositions.append(contentsOf: repeatElement(Vector3(), count: localPositionLength - _globalPositions.count))
        } else {
            _ = _globalPositions.dropLast(_globalPositions.count - localPositionLength)
        }
        var positionIndex = 0
        for i in 0..<_wireframeElements.count {
            let wireframeElement = _wireframeElements[i]
            let beginIndex = wireframeElement.transformRanges
            let endIndex = i < _wireframeElements.count - 1 ? _wireframeElements[i + 1].transformRanges : localPositionLength
            if (wireframeElement.updateFlag.flag) {
                let transform = wireframeElement.transform
                let worldMatrix = Matrix.rotationTranslation(quaternion: transform.worldRotationQuaternion, translation: transform.worldPosition)

                for _ in beginIndex..<endIndex {
                    let localPosition = _localPositions[positionIndex]
                    _globalPositions[positionIndex] = Vector3.transformCoordinate(v: localPosition, m: worldMatrix)
                    positionIndex += 1
                }
                wireframeElement.updateFlag.flag = false
            } else {
                positionIndex += endIndex - beginIndex
            }
        }

        // update world-space geometry
        _growthIndexMemory(_boundsIndicesCount)
        var indicesCount = _indicesCount
        for i in 0..<_wireframeRenderers.count {
            let renderer = _wireframeRenderers[i]
            let bounds = renderer.bounds
            var tempVector = bounds.getExtent()

            let positionsOffset = _globalPositions.count
            WireframePrimitive.createCuboidWireframe(
                    tempVector.x * 2,
                    tempVector.y * 2,
                    tempVector.z * 2,
                    &_globalPositions,
                    UInt32(positionsOffset),
                    &_indices,
                    indicesCount
            )
            tempVector = bounds.getCenter()
            for i in positionsOffset..<_globalPositions.count {
                _globalPositions[i] += tempVector
            }
            indicesCount += Int(WireframePrimitive.cuboidIndexCount)
        }

        if _colorPool.count != _globalPositions.count {
            _colorPool = [Color32](repeating: baseColor, count: _globalPositions.count)
        }
        LineBatcher.ins.addLines(indicesCount: indicesCount, positions: _globalPositions, indices: _indices, colors: _colorPool)
    }

    private func _growthIndexMemory(_ length: Int) {
        let neededLength = _indicesCount + length
        if (neededLength > _indices.count) {
            if (neededLength > UInt32.max) {
                fatalError("The vertex count is over limit.")
            }

            var newIndices = [UInt32](repeating: 0, count: neededLength)
            newIndices.replaceSubrange(0..<_indices.count, with: _indices)
            _indices = newIndices
        }
    }

    private func _localTranslate(_ positionsOffset: Int, _ offset: Vector3) {
        for i in positionsOffset..<_localPositions.count {
            _localPositions[i] += offset
        }
    }

    private func _localRotation(_ positionsOffset: Int, _ rotation: Quaternion) {
        for i in positionsOffset..<_localPositions.count {
            _localPositions[i] = Vector3.transformByQuat(v: _localPositions[i], quaternion: rotation)
        }
    }

    private func _rotateAroundX(_ positionsOffset: Int) {
        for i in positionsOffset..<_localPositions.count {
            let position = _localPositions[i]
            _localPositions[i] = Vector3(position.x, -position.z, position.y)
        }
    }
}

/// Store Wireframe element info.
class WireframeElement {
    var updateFlag: BoolUpdateFlag
    var transform: Transform
    var transformRanges: Int

    init(_ transform: Transform, _ transformRanges: Int) {
        self.transform = transform
        self.transformRanges = transformRanges
        updateFlag = transform.registerWorldChangeFlag()
    }
}
