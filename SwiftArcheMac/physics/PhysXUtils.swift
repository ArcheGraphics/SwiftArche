//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

func addSphere(_ rootEntity: Entity, _ radius: Float,
               _ position: Vector3, _ rotation: Quaternion) -> Entity {
    let mtl = PBRMaterial(rootEntity.engine)
    mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let sphereEntity = rootEntity.createChild()
    let renderer: MeshRenderer = sphereEntity.addComponent()
    renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius: radius)
    renderer.setMaterial(mtl)
    sphereEntity.transform.position = position
    sphereEntity.transform.rotationQuaternion = rotation

    let physicsSphere = SphereColliderShape()
    physicsSphere.radius = radius
    let sphereCollider: DynamicCollider = sphereEntity.addComponent()
    sphereCollider.addShape(physicsSphere)

    return sphereEntity
}

func addCapsule(_ rootEntity: Entity, _ radius: Float, _ height: Float,
                _ position: Vector3, _ rotation: Quaternion) -> Entity {
    let mtl = PBRMaterial(rootEntity.engine)
    mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let capsuleEntity = rootEntity.createChild()
    let renderer: MeshRenderer = capsuleEntity.addComponent()
    renderer.mesh = PrimitiveMesh.createCapsule(rootEntity.engine, radius: radius, height: height, radialSegments: 20)
    renderer.setMaterial(mtl)
    capsuleEntity.transform.position = position
    capsuleEntity.transform.rotationQuaternion = rotation

    let physicsCapsule = CapsuleColliderShape()
    physicsCapsule.radius = radius
    physicsCapsule.height = height
    let capsuleCollider: DynamicCollider = capsuleEntity.addComponent()
    capsuleCollider.addShape(physicsCapsule)

    return capsuleEntity
}

func addBox(_ rootEntity: Entity, _ size: Vector3,
            _ position: Vector3, _ rotation: Quaternion) -> Entity {
    let mtl = PBRMaterial(rootEntity.engine)
    mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let boxEntity = rootEntity.createChild()
    let renderer: MeshRenderer = boxEntity.addComponent()
    renderer.mesh = PrimitiveMesh.createCuboid(
            rootEntity.engine,
            width: size.x,
            height: size.y,
            depth: size.z
    )
    renderer.setMaterial(mtl)
    boxEntity.transform.position = position
    boxEntity.transform.rotationQuaternion = rotation

    let physicsBox = BoxColliderShape()
    physicsBox.size = size
    physicsBox.isTrigger = false
    let boxCollider: DynamicCollider = boxEntity.addComponent()
    boxCollider.addShape(physicsBox)

    return boxEntity
}

func addPlane(_ rootEntity: Entity, _ size: Vector3,
              _ position: Vector3, _ rotation: Quaternion) -> Entity {
    let mtl = PBRMaterial(rootEntity.engine)
    mtl.baseColor = Color(
            0.2179807202597362,
            0.2939682161541871,
            0.31177952549087604,
            1
    )
    mtl.roughness = 0.0
    mtl.metallic = 0.0
    let planeEntity = rootEntity.createChild()
    planeEntity.layer = Layer.Layer1

    let renderer: MeshRenderer = planeEntity.addComponent()
    renderer.mesh = PrimitiveMesh.createCuboid(
            rootEntity.engine,
            width: size.x,
            height: size.y,
            depth: size.z
    )
    renderer.setMaterial(mtl)
    planeEntity.transform.position = position
    planeEntity.transform.rotationQuaternion = rotation

    let physicsPlane = PlaneColliderShape()
    physicsPlane.position = Vector3(0, size.y, 0)
    let planeCollider: StaticCollider = planeEntity.addComponent()
    planeCollider.addShape(physicsPlane)

    return planeEntity
}
