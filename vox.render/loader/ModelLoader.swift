//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import MetalKit
import Math
import ModelIO

public class ModelLoader {
    static var textureLoader: TextureLoader?
    
    public static func parse(_ url: URL, _ callback: @escaping (ModelResource) -> Void) {
        if ModelLoader.textureLoader == nil {
            ModelLoader.textureLoader = TextureLoader()
        }
        
        let resource = ModelResource()
        resource.url = url
        
        let allocator = MTKMeshBufferAllocator(device: Engine.device)
        load(asset: MDLAsset(url: url,
                vertexDescriptor: MDLVertexDescriptor.defaultVertexDescriptor,
                             bufferAllocator: allocator), for: resource)
        callback(resource)
    }
    
    static func load(asset: MDLAsset, for resource: ModelResource) {
        // load Model I/O textures
        asset.loadTextures()

        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        _ = mdlMeshes.map { mdlMesh in
            load(mdlMesh: mdlMesh, parent: nil, for: resource)
        }
    }
    
    static func load(mdlMesh: MDLMesh, parent: Entity?, for resource: ModelResource) {
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                tangentAttributeNamed: MDLVertexAttributeNormal,
                                bitangentAttributeNamed: MDLVertexAttributeTangent)
        let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: Engine.device)
        
        // alloc entity
        var entity: Entity
        if let parent {
            entity = parent.createChild(mdlMesh.name)
        } else {
            entity = Entity(mdlMesh.name)
            resource.sceneRoots.append(entity)
        }
        resource.entities.append(entity)
        
        // use transform component
        if let transform = mdlMesh.transform {
            entity.transform.localMatrix = Matrix(transform.matrix)
        }
        
        zip(mdlMesh.submeshes!, mtkMesh.submeshes).forEach { (mdlSubmesh, mtkSubmesh: MTKSubmesh) in
            // alloc mesh
            let mesh = Mesh()
            mesh._vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)!
            for (index, vertexBuffer) in mtkMesh.vertexBuffers.enumerated() {
                mesh._vertexBufferBindings[index] = BufferView(buffer: vertexBuffer.buffer,
                                                               count: vertexBuffer.buffer.length, stride: 1)
            }
            let renderer = entity.addComponent(MeshRenderer.self)
            renderer.mesh = mesh
            
            // alloc submesh
            let mdlSubmesh = mdlSubmesh as! MDLSubmesh
            mesh.addSubMesh(0, mtkSubmesh.indexCount, mtkSubmesh.primitiveType)
            mesh._indexBufferBinding = IndexBufferBinding(BufferView(buffer: mtkSubmesh.indexBuffer.buffer,
                                                                     count: mtkSubmesh.indexBuffer.length,
                                                                     stride: 1), mtkSubmesh.indexType)
            // alloc material
            let mat = PBRMaterial()
            loadMaterial(mat, mdlSubmesh.material)
            resource.materials.append(mat)
            renderer.setMaterial(0, mat)
        }
    }
    
    static func loadMaterial(_ pbr: PBRMaterial, _ material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                  property.type == .string,
                  let filename = property.stringValue,
                  let texture = try? ModelLoader.textureLoader?.loadTexture(with: filename)
                    else {
                if let property = material?.property(with: semantic),
                   property.type == .texture,
                   let mdlTexture = property.textureSamplerValue?.texture {
                    return try? ModelLoader.textureLoader?.loadTexture(with: mdlTexture)
                }
                return nil
            }
            return texture
        }

        pbr.baseTexture = property(with: .baseColor)
        pbr.normalTexture = property(with: .tangentSpaceNormal)
        pbr.roughnessMetallicTexture = property(with: .roughness)
        pbr.occlusionTexture = property(with: .ambientOcclusion)
        pbr.emissiveTexture = property(with: .emission)

        if let baseColor = material?.property(with: .baseColor),
           baseColor.type == .float3 {
            pbr.baseColor = Color(baseColor.float3Value.x, baseColor.float3Value.y, baseColor.float3Value.z, 1.0)
        }
        if let roughness = material?.property(with: .roughness),
           roughness.type == .float3 {
            pbr.roughness = roughness.floatValue
        }
    }
}

/// Product after Model parser, usually, `defaultSceneRoot` is only needed to use.
public class ModelResource {
    /** GLTF file url. */
    public var url: URL!
    /** Oasis Material after MaterialParser. */
    public var materials: [Material] = []
    /** Oasis ModelMesh after MeshParser. */
    public var meshes: [Mesh] = []
    /** Oasis Entity after EntityParser. */
    public var entities: [Entity] = []
    /** Oasis RootEntities after SceneParser. */
    public var sceneRoots: [Entity] = []
}
