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
    renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius)
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
    renderer.mesh = PrimitiveMesh.createCapsule(rootEntity.engine, radius, height, 20)
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
            size.x,
            size.y,
            size.z
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
