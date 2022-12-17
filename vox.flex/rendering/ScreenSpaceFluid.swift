//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render
import vox_math

public class ScreenSpaceFluidMaterial: BaseMaterial {
    private static let _normalDepthTextureProp = "u_normalDepthTexture"
    private static let _normalDepthSamplerProp = "u_normalDepthSampler"
    private static let _thickTextureProp = "u_thickTexture"
    private static let _thickSamplerProp = "u_thickSampler"
    private static let _ssfProperty = "u_ssf"

    private var _normalDepthTexture: MTLTexture?
    private var _thickTexture: MTLTexture?

    /// thick texture.
    public var thickTexture: MTLTexture? {
        get {
            _thickTexture
        }
        set {
            _thickTexture = newValue
            if let newValue = newValue {
                shaderData.setImageView(ScreenSpaceFluidMaterial._thickTextureProp, ScreenSpaceFluidMaterial._thickSamplerProp, newValue)
            } else {
                shaderData.setImageView(ScreenSpaceFluidMaterial._thickTextureProp, ScreenSpaceFluidMaterial._thickSamplerProp, nil)
            }
        }
    }

    /// normal depth texture.
    public var normalDepthTexture: MTLTexture? {
        get {
            _normalDepthTexture
        }
        set {
            _normalDepthTexture = newValue
            if let newValue = newValue {
                shaderData.setImageView(ScreenSpaceFluidMaterial._normalDepthTextureProp, ScreenSpaceFluidMaterial._normalDepthSamplerProp, newValue)
            } else {
                shaderData.setImageView(ScreenSpaceFluidMaterial._normalDepthTextureProp, ScreenSpaceFluidMaterial._normalDepthSamplerProp, nil)
            }
        }
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("flex.shader"), "vertex_ssf", "fragment_ssf"))
    }
}

//MARK: - DepthThickMaterial
public class DepthThickMaterial: BaseMaterial {
    private static let radiusProperty = "pointRadius"
    private static let lightProperty = "lightDir"
    private var _pointRadius: Float = 0
    private var _lightDir = Vector3F()
    
    public var lightDir: Vector3F {
        get {
            _lightDir
        }
        set {
            _lightDir = newValue
            shaderData.setData(DepthThickMaterial.lightProperty, _lightDir)
        }
    }
    
    public var pointRadius: Float {
        get {
            _pointRadius
        }
        set {
            _pointRadius = newValue
            shaderData.setData(DepthThickMaterial.radiusProperty, _pointRadius)
        }
    }
    
    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("flex.shader"), "vertex_ssf_depth_thick", "fragment_ssf_depth_thick"))
        
        lightDir = Vector3F(0, 1, 0)
        pointRadius = 10
    }
}

// MARK: - ScreenSpaceSubpass
class ScreenSpaceSubpass: GeometrySubpass {
    var element: RenderElement!
    
    override init() {
        super.init()
    }
    
    override func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor, _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "Screen-Space Fluid Pipeline"
        pipelineDescriptor.colorAttachments[0].pixelFormat = .r16Float
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    }
    
    override func drawElement(_ encoder: inout RenderCommandEncoder) {
        super._drawElement(&encoder, element)
    }
}

//MARK: - ScreenSpaceFluid
public class ScreenSpaceFluid: Script {
    let depthThickMtl: DepthThickMaterial
    var depthThickPassDesc: MTLRenderPassDescriptor
    var renderPass: RenderPass
    var subpass: ScreenSpaceSubpass
    var camera: Camera
    
    let smoothPass: ComputePass
    let restoreNormalPass: ComputePass
    
    var renderer: MeshRenderer
    let material: ScreenSpaceFluidMaterial
    var normalDepthTexture: MTLTexture!
    
    private var _canvasChanged: Canvas?
    private var _particleSystem: ParticleSystemData?
    private var _particleMesh: Mesh?
    
    private var _kernelRadius: Int = 1
    private var _blurRadius: Float = 0
    private var _blurDepth: Float = 0
    private var _ssfData = SSFData()

    public var particleSystem: ParticleSystemData? {
        get {
            _particleSystem
        }
        set {
            _particleSystem = newValue
            if let particleSystem = _particleSystem {
                let descriptor = MTLVertexDescriptor()
                let desc = MTLVertexAttributeDescriptor()
                desc.format = .float3
                desc.offset = 0
                desc.bufferIndex = 0
                descriptor.attributes[Int(Position.rawValue)] = desc
                descriptor.layouts[0].stride = 16

                let particleMesh = Mesh()
                particleMesh._vertexDescriptor = descriptor
                let maxNumber = particleSystem.numberOfParticles
                _ = particleMesh.addSubMesh(0, maxNumber, .point)
                particleMesh._setVertexBufferBinding(0, particleSystem.positions)
                _particleMesh = particleMesh
            }
        }
    }
    
    public var pointRadius: Float {
        get {
            depthThickMtl.pointRadius
        }
        set {
            depthThickMtl.pointRadius = newValue
        }
    }
    
    public var lightDir: Vector3F {
        get {
            depthThickMtl.lightDir
        }
        set {
            depthThickMtl.lightDir = newValue
        }
    }
    
    public var kernelRadius: Int {
        get {
            _kernelRadius
        }
        set {
            _kernelRadius = newValue
            smoothPass.defaultShaderData.setData("kernel_r", _kernelRadius)
        }
    }
    
    public var sigmaRadius: Float {
        get {
            1 / _blurRadius
        }
        set {
            _blurRadius = 1 / newValue
            smoothPass.defaultShaderData.setData("blur_r", _blurRadius)
        }
    }
    
    public var sigmaDepth: Float {
        get {
            1 / _blurDepth
        }
        set {
            _blurDepth = 1 / newValue
            smoothPass.defaultShaderData.setData("blur_z", _blurDepth)
        }
    }
    
    func resize(type: Int?, param: AnyObject?) -> Void {
        _canvasChanged = (param as! Canvas) // wait update until next frame
    }
    
    required init(_ entity: Entity) {
        camera = entity.getComponent()!
        depthThickMtl = DepthThickMaterial(entity.engine, "ssf-depth-thick")
        depthThickPassDesc = MTLRenderPassDescriptor();
        depthThickPassDesc.depthAttachment.loadAction = .clear
        depthThickPassDesc.colorAttachments[0].loadAction = .clear
        subpass = ScreenSpaceSubpass()
        renderPass = RenderPass(camera.devicePipeline)
        renderPass.addSubpass(subpass)
        
        smoothPass = ComputePass(entity.engine)
        smoothPass.resourceCache = entity.scene.postprocessManager.resourceCache
        smoothPass.shader.append(ShaderPass(entity.engine.library("flex.shader"), "ssf_smoothDepth"))
        restoreNormalPass = ComputePass(entity.engine)
        restoreNormalPass.resourceCache = entity.scene.postprocessManager.resourceCache
        restoreNormalPass.shader.append(ShaderPass(entity.engine.library("flex.shader"), "ssf_restoreNormal"))

        material = ScreenSpaceFluidMaterial(entity.engine, "ssf")
        renderer = entity.addComponent()
        renderer.setMaterial(material)
        renderer.mesh = PrimitiveMesh.createQuadPlane(entity.engine)
        
        super.init(entity)
        
        kernelRadius = 10
        sigmaRadius = 6
        sigmaDepth = 0.1

        let canvas = engine.canvas
        let flag = ListenerUpdateFlag()
        flag.listener = resize
        canvas.updateFlagManager.addFlag(flag: flag)
        if let renderTarget = canvas.currentRenderPassDescriptor,
           let texture = renderTarget.colorAttachments[0].texture {
            createTexture(texture.width, texture.height)
        }
    }
    
    func createTexture(_ width: Int, _ height: Int) {
        let width = Int(Float(width))
        let height = Int(Float(height))
        var desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r16Float, width: width, height: height, mipmapped: true)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
        desc.storageMode = .private
        depthThickPassDesc.colorAttachments[0].texture = engine.device.makeTexture(descriptor: desc)
        
        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
        desc.storageMode = .private
        depthThickPassDesc.depthAttachment.texture = engine.device.makeTexture(descriptor: desc)
        
        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        desc.storageMode = .private
        normalDepthTexture = engine.device.makeTexture(descriptor: desc)
        
        // binding texture
        material.normalDepthTexture = normalDepthTexture
        material.thickTexture = depthThickPassDesc.colorAttachments[0].texture
        
        smoothPass.threadsPerGridX = width
        smoothPass.threadsPerGridY = height
        smoothPass.defaultShaderData.setImageView("depth", depthThickPassDesc.depthAttachment.texture)
        smoothPass.defaultShaderData.setImageView("normalDepth", normalDepthTexture)

        restoreNormalPass.threadsPerGridX = width
        restoreNormalPass.threadsPerGridY = height
        restoreNormalPass.defaultShaderData.setImageView("u_normalDepthIn", normalDepthTexture)
        restoreNormalPass.defaultShaderData.setImageView("u_normalDepthOut", normalDepthTexture)
        
        // calculate camera parameter
        let tanHalfFov = tan(MathUtil.degreeToRadian(camera.fieldOfView) * 0.5)
        _ssfData.canvasHeight = Float(height)
        _ssfData.canvasWidth = Float(width)
        _ssfData.p_f = camera.farClipPlane
        _ssfData.p_n = camera.nearClipPlane
        _ssfData.p_t = tanHalfFov * camera.nearClipPlane
        _ssfData.p_r = camera.aspectRatio * _ssfData.p_t
        depthThickMtl.shaderData.setData("u_ssf", _ssfData)
        restoreNormalPass.defaultShaderData.setData("u_ssf", _ssfData)
        material.shaderData.setData("u_ssf", _ssfData)
    }
    
    public override func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
        if let canvas = _canvasChanged {
            if let renderTarget = canvas.currentRenderPassDescriptor,
               let texture = renderTarget.colorAttachments[0].texture {
                createTexture(texture.width, texture.height)
                _canvasChanged = nil
            }
        }
        
        if let mesh = _particleMesh {
            subpass.element = RenderElement(renderer, mesh, mesh.subMesh!, depthThickMtl, depthThickMtl.shader[0])
            renderPass.draw(commandBuffer, depthThickPassDesc, "ssf depthThick")
            
            if let encoder = commandBuffer.makeComputeCommandEncoder() {
                encoder.label = "ssf compute"
                smoothPass.compute(commandEncoder: encoder)
                restoreNormalPass.compute(commandEncoder: encoder)
                encoder.endEncoding()
            }
        }
    }
}
