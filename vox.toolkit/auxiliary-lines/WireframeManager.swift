//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render
import Foundation
import Metal

public class WireframeManager: Script {
    private static let _ndcPosition: [Vector3] = [
        Vector3(-1, 1, -1),
        Vector3(1, 1, -1),
        Vector3(1, -1, -1),
        Vector3(-1, -1, -1)
    ]
    private static let _halfSqrt: Float = 0.70710678118655

    private var _localPositions: [Vector3] = []
    private var _globalPositions: [Vector3] = []
    private var _indices: [UInt32] = []
    private var _indicesCount = 0
    private var _boundsIndicesCount = 0

    private var _wireframeRenderers: [Renderer] = []
    private var _wireframeElements: [WireframeElement] = []
    private var _renderer: MeshRenderer!
    private var _material: UnlitMaterial!
    private var _mesh: ModelMesh!

    /// Base color.
    public var baseColor: Color {
        get {
            _material.baseColor
        }
        set {
            _material.baseColor = newValue
        }
    }


    /// Clear all wireframe.
    public func clear() {
        _wireframeRenderers = []
        _wireframeElements = []
        _localPositions = []
        _globalPositions = []
        _indicesCount = 0
        _mesh.subMesh!.count = 0
    }

    /// Create auxiliary mesh for entity.
    /// - Parameters:
    ///   - entity: The entity
    ///   - includeChildren: Whether include child entity(default is true)
    public func addEntityWireframe(with entity: Entity, includeChildren: Bool = true) {
        if (includeChildren) {
            let cameras: [Camera] = entity.getComponentsIncludeChildren()
            for camera in cameras {
                addCameraWireframe(with: camera)
            }

            let spotLights: [SpotLight] = entity.getComponentsIncludeChildren()
            for spotLight in spotLights {
                addSpotLightWireframe(with: spotLight)
            }

            let directLights: [DirectLight] = entity.getComponentsIncludeChildren()
            for directLight in directLights {
                addDirectLightWireframe(with: directLight)
            }

            let pointLights: [PointLight] = entity.getComponentsIncludeChildren()
            for pointLight in pointLights {
                addPointLightWireframe(with: pointLight)
            }

            let colliders: [Collider] = entity.getComponentsIncludeChildren()
            for collider in colliders {
                addCollideWireframe(with: collider)
            }
        } else {
            let camera: Camera? = entity.getComponent()
            if camera != nil {
                addCameraWireframe(with: camera!)
            }
            let spotLight: SpotLight? = entity.getComponent()
            if spotLight != nil {
                addSpotLightWireframe(with: spotLight!)
            }
            let directLight: DirectLight? = entity.getComponent()
            if directLight != nil {
                addDirectLightWireframe(with: directLight!)
            }
            let pointLight: PointLight? = entity.getComponent()
            if pointLight != nil {
                addPointLightWireframe(with: pointLight!)
            }
            let collider: Collider? = entity.getComponent()
            if collider != nil {
                addCollideWireframe(with: collider!)
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
            var newPosition = WireframeManager._ndcPosition[i]
            _ = newPosition.transformCoordinate(m: inverseProj)
            _localPositions.append(newPosition)
        }

        // back
        for i in 0..<4 {
            var newPosition = WireframeManager._ndcPosition[i]
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
            if (shape is BoxColliderShape) {
                addBoxColliderShapeWireframe(with: shape as! BoxColliderShape)
            } else if (shape is SphereColliderShape) {
                addSphereColliderShapeWireframe(with: shape as! SphereColliderShape)
            } else if (shape is CapsuleColliderShape) {
                addCapsuleColliderShapeWireframe(with: shape as! CapsuleColliderShape)
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
            _ = tempAxis.set(x: 0, y: 0, z: WireframeManager._halfSqrt, w: WireframeManager._halfSqrt)
            break
        case ColliderShapeUpAxis.Y:
            _ = tempAxis.set(x: 0, y: 0, z: 0, w: 1)
            break
        case ColliderShapeUpAxis.Z:
            _ = tempAxis.set(x: WireframeManager._halfSqrt, y: 0, z: 0, w: WireframeManager._halfSqrt)
        }
        var tempRotation = Quaternion.rotationYawPitchRoll(yaw: shape.rotation.x, pitch: shape.rotation.y, roll: shape.rotation.z)
        tempRotation *= tempAxis
        _localRotation(positionsOffset, tempRotation)
        let tempVector = shape.position * worldScale
        _localTranslate(positionsOffset, tempVector)

        _indicesCount += Int(capsuleIndicesCount)
        _wireframeElements.append(WireframeElement(transform, positionsOffset))
    }

    public override func onAwake() {
        let mesh = ModelMesh(engine)
        let material = UnlitMaterial(engine)
        let renderer: MeshRenderer? = entity.getComponent()

        if let renderer = renderer {
            _ = mesh.addSubMesh(0, _indicesCount, MTLPrimitiveType.line)
            renderer.mesh = mesh
            renderer.setMaterial(material)

            _mesh = mesh
            _material = material
            _renderer = renderer
            _indices = [UInt32](repeating: 0, count: 128)
        }
    }

    public override func onEnable() {
        _renderer.enabled = true
    }


    public override func onDisable() {
        _renderer.enabled = false
    }

    public override func onUpdate(_ deltaTime: Float) {
        // update local to world geometry
        let localPositionLength = _localPositions.count
        if localPositionLength > _globalPositions.count {
            _globalPositions.append(contentsOf: repeatElement(Vector3(), count: localPositionLength - _globalPositions.count))
        } else {
            _ = _globalPositions.dropLast(_globalPositions.count - localPositionLength)
        }
        var positionIndex = 0
        var needUpdate = false
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
                needUpdate = true
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

        if (_wireframeRenderers.count > 0 || needUpdate) {
            _mesh.setPositions(positions: _globalPositions)
            _mesh.setIndices(indices: _indices)
            _mesh.uploadData(false)
            _mesh.subMesh!.count = indicesCount
        }
    }

    private func _growthIndexMemory(_ length: Int) {
        let neededLength = _indicesCount + length
        if (neededLength > _indices.count) {
            if (neededLength > 4294967295) {
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