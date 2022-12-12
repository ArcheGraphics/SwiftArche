//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class QuadMaterial: BaseMaterial {
    private var _baseTexture: MTLTexture?

    /// Base texture.
    public var baseTexture: MTLTexture? {
        get {
            _baseTexture
        }
        set {
            _baseTexture = newValue
            if let newValue = newValue {
                shaderData.setImageView(QuadMaterial._baseTextureProp, QuadMaterial._baseSamplerProp, newValue)
            } else {
                shaderData.setImageView(QuadMaterial._baseTextureProp, QuadMaterial._baseSamplerProp, nil)
            }
        }
    }
    
    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("app.shader"), "vertex_quad", "fragment_quad"))
    }
}

class PathTracingScript: Script {
    private var _material: QuadMaterial!
    private var _tracingMtl: MTLTexture?
    private var _pipelineState: MTLComputePipelineState!

    public override func onAwake() {
        let quadRenderer: MeshRenderer! = entity.addComponent()
        let mesh = ModelMesh(engine)
        _ = mesh.addSubMesh(0, 6)
        mesh.bounds = BoundingBox(Vector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude),
                Vector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude))
        quadRenderer.mesh = mesh
        _material = QuadMaterial(engine)
        quadRenderer.setMaterial(_material)
        
        let function = engine.library("flex.shader").makeFunction(name: "render")
        _pipelineState = try! engine.device.makeComputePipelineState(function: function!)
    }
    
    override func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
        if let renderTarget = engine.canvas.currentRenderPassDescriptor {
            let texture = renderTarget.colorAttachments[0].texture!
            if _tracingMtl == nil || _tracingMtl!.width != texture.width || _tracingMtl!.height != texture.height {
                let desc = MTLTextureDescriptor()
                desc.width = texture.width
                desc.height = texture.height
                desc.pixelFormat = texture.pixelFormat
                desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
                _tracingMtl = engine.device.makeTexture(descriptor: desc)
                
                if let encoder = commandBuffer.makeComputeCommandEncoder() {
                    encoder.setComputePipelineState(_pipelineState)
                    encoder.setTexture(_tracingMtl!, index: 0)
                    
                    let threadsPerGridX = texture.width
                    let threadsPerGridY = texture.height
                    let nWidth = min(threadsPerGridX, _pipelineState.threadExecutionWidth)
                    let nHeight = min(threadsPerGridY, _pipelineState.maxTotalThreadsPerThreadgroup / nWidth)
                    encoder.dispatchThreads(MTLSize(width: threadsPerGridX, height: threadsPerGridY, depth: 1),
                            threadsPerThreadgroup: MTLSize(width: nWidth, height: nHeight, depth: 1))
                    encoder.endEncoding()
                }
                _material.baseTexture = _tracingMtl
            }
        }
    }
}

class PathTracingApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        let cameraEntity = rootEntity.createChild()
        let _: Camera = cameraEntity.addComponent()
        let _: PathTracingScript = cameraEntity.addComponent()
        
        engine.run()
    }
}

