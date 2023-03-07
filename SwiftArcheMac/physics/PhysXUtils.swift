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
    let renderer = sphereEntity.addComponent(MeshRenderer.self)
    renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius: radius)
    renderer.setMaterial(mtl)
    sphereEntity.transform.position = position
    sphereEntity.transform.rotationQuaternion = rotation

    let physicsSphere = SphereColliderShape()
    physicsSphere.radius = radius
    let sphereCollider = sphereEntity.addComponent(DynamicCollider.self)
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
    let renderer = capsuleEntity.addComponent(MeshRenderer.self)
    renderer.mesh = PrimitiveMesh.createCapsule(rootEntity.engine, radius: radius, height: height, radialSegments: 20)
    renderer.setMaterial(mtl)
    capsuleEntity.transform.position = position
    capsuleEntity.transform.rotationQuaternion = rotation

    let physicsCapsule = CapsuleColliderShape()
    physicsCapsule.radius = radius
    physicsCapsule.height = height
    let capsuleCollider = capsuleEntity.addComponent(DynamicCollider.self)
    capsuleCollider.addShape(physicsCapsule)

    return capsuleEntity
}

func addBox(_ rootEntity: Entity, _ size: Vector3,
            _ position: Vector3, _ rotation: Quaternion, isDynamic: Bool = true) -> Entity {
    let mtl = PBRMaterial(rootEntity.engine)
    mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let boxEntity = rootEntity.createChild()
    let renderer = boxEntity.addComponent(MeshRenderer.self)
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
    if isDynamic {
        let boxCollider = boxEntity.addComponent(DynamicCollider.self)
        boxCollider.addShape(physicsBox)
        boxCollider.setDensity(1)
    } else {
        let boxCollider = boxEntity.addComponent(StaticCollider.self)
        boxCollider.addShape(physicsBox)
    }

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

    let renderer = planeEntity.addComponent(MeshRenderer.self)
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
    physicsPlane.isSceneQuery = false;
    let planeCollider = planeEntity.addComponent(StaticCollider.self)
    planeCollider.addShape(physicsPlane)

    return planeEntity
}

func createDebugWireframe(_ shape: MeshColliderShape, _ entity: Entity) {
    let points = shape.colliderPoints
    let indices = shape.colliderWireframeIndices
    
    let mesh = ModelMesh(entity.engine)
    mesh.setPositions(positions: points)
    mesh.setIndices(indices: indices)
    _ = mesh.addSubMesh(0, indices.count, .line)
    mesh.uploadData(true)
    
    let mtl = UnlitMaterial(entity.engine)
    let renderer = entity.addComponent(MeshRenderer.self)
    renderer.setMaterial(mtl)
    renderer.mesh = mesh
}

func addDuckMesh(_ rootEntity: Entity) {
    let assetURL = Bundle.main.url(forResource: "Duck", withExtension: "glb", subdirectory: "glTF-Sample-Models/2.0/Duck/glTF-Binary")!
    GLTFLoader.parse(rootEntity.engine, assetURL, { resource in
        let entity = resource.defaultSceneRoot!
        rootEntity.addChild(entity)
        
        let colliderShape = MeshColliderShape()
//        colliderShape.isConvex = true
        colliderShape.mesh = resource.meshes![0][0]
        let collider = entity.addComponent(StaticCollider.self)
        collider.addShape(colliderShape)
        
        createDebugWireframe(colliderShape, entity)
    }, true)
}
