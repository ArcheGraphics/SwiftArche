//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render
import Math

public class ScreenSpaceFluidMaterial: BaseMaterial {
    private static let _normalDepthTextureProp = "u_normalDepthTexture"
    private static let _normalDepthSamplerProp = "u_normalDepthSampler"
    private static let _thickTextureProp = "u_thickTexture"
    private static let _thickSamplerProp = "u_thickSampler"

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

    public override init(_ name: String = "ssf mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library("flex.shader"), "vertex_ssf", "fragment_ssf"))
    }
}

//MARK: - ThickMaterial
public class ThickMaterial: BaseMaterial {
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
            shaderData.setData(ThickMaterial.lightProperty, _lightDir)
        }
    }
    
    public var pointRadius: Float {
        get {
            1 / _pointRadius
        }
        set {
            _pointRadius = 1 / newValue
            shaderData.setData(ThickMaterial.radiusProperty, _pointRadius)
        }
    }
    
    public override init(_ name: String = "ssf depth thick mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library("flex.shader"), "vertex_ssf_depth_thick", "fragment_ssf_thick"))
        shader[0].setBlendMode(.Additive)
        isTransparent = true

        lightDir = Vector3F(0, 0, 1)
        pointRadius = 20
    }
}

//MARK: - DepthMaterial
public class DepthMaterial: BaseMaterial {
    private static let radiusProperty = "pointRadius"
    private var _pointRadius: Float = 0
    
    public var pointRadius: Float {
        get {
            1 / _pointRadius
        }
        set {
            _pointRadius = 1 / newValue
            shaderData.setData(DepthMaterial.radiusProperty, _pointRadius)
        }
    }
    
    public override init(_ name: String = "ssf depth thick mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library("flex.shader"), "vertex_ssf_depth_thick", "fragment_ssf_depth"))

        pointRadius = 20
    }
}

// MARK: - ScreenSpaceSubpass
class ScreenSpaceSubpass: GeometrySubpass {
    var element: RenderElement!
    var pixelFormat: MTLPixelFormat = .invalid
    
    override init() {
        super.init()
    }
    
    override func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor, _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "Screen-Space Fluid Pipeline"
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    }
    
    override func drawElement(_ encoder: inout RenderCommandEncoder) {
        super._drawElement(&encoder, element)
    }
}

//MARK: - ScreenSpaceFluid
public class ScreenSpaceFluid: Script {
    private static let _ssfProperty = "u_ssf"

    var thickMtl: ThickMaterial!
    var thickTexture: MTLTexture!
    var depthMtl: DepthMaterial!
    var depthTexture: [MTLTexture] = []
    var depthThickPassDesc: MTLRenderPassDescriptor!
    var renderPass: RenderPass!
    var subpass: ScreenSpaceSubpass!
    var camera: Camera!
    
    var smoothPass: ComputePass!
    var restoreNormalPass: ComputePass!
    
    var renderer: MeshRenderer!
    var material: ScreenSpaceFluidMaterial!
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
                let maxNumber: Int = particleSystem.numberOfParticles[0]
                _ = particleMesh.addSubMesh(0, maxNumber, .point)
                particleMesh._setVertexBufferBinding(0, particleSystem.positions)
                _particleMesh = particleMesh
            }
        }
    }
    
    public var smoothIter: Int32 = 2

    public var pointRadius: Float {
        get {
            thickMtl.pointRadius
        }
        set {
            depthMtl.pointRadius = newValue
            thickMtl.pointRadius = newValue
        }
    }
    
    public var lightDir: Vector3F {
        get {
            thickMtl.lightDir
        }
        set {
            thickMtl.lightDir = newValue
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
    
    public override func onStart() {
        camera = entity.getComponent(Camera.self)!
        thickMtl = ThickMaterial("ssf-thick")
        depthMtl = DepthMaterial("ssf-depth")
        depthThickPassDesc = MTLRenderPassDescriptor();
        depthThickPassDesc.depthAttachment.loadAction = .clear
        depthThickPassDesc.colorAttachments[0].loadAction = .clear
        subpass = ScreenSpaceSubpass()
        renderPass = RenderPass(camera.devicePipeline)
        renderPass.addSubpass(subpass)
        
        smoothPass = ComputePass()
        smoothPass.resourceCache = entity.scene.postprocessManager.resourceCache
        smoothPass.shader.append(ShaderPass(Engine.library("flex.shader"), "ssf_smoothDepth"))
        restoreNormalPass = ComputePass()
        restoreNormalPass.resourceCache = entity.scene.postprocessManager.resourceCache
        restoreNormalPass.shader.append(ShaderPass(Engine.library("flex.shader"), "ssf_restoreNormal"))

        material = ScreenSpaceFluidMaterial("ssf")
        renderer = entity.addComponent(MeshRenderer.self)
        renderer.setMaterial(material)
        renderer.mesh = PrimitiveMesh.createQuadPlane()
                
        kernelRadius = 10
        sigmaRadius = 6
        sigmaDepth = 0.1

        let canvas = Engine.canvas!
        let flag = ListenerUpdateFlag()
        flag.listener = resize
        canvas.updateFlagManager.addFlag(flag: flag)
        if let renderTarget = canvas.currentRenderPassDescriptor,
           let texture = renderTarget.colorAttachments[0].texture {
            createTexture(texture.width, texture.height)
        }
    }
    
    func createTexture(_ width: Int, _ height: Int) {
        var desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r16Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
        desc.storageMode = .private
        thickTexture = Engine.device.makeTexture(descriptor: desc)
        
        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue
                                     | MTLTextureUsage.shaderWrite.rawValue
                                     | MTLTextureUsage.renderTarget.rawValue)
        desc.storageMode = .private
        depthTexture.append( Engine.device.makeTexture(descriptor: desc)!)
        depthTexture.append( Engine.device.makeTexture(descriptor: desc)!)

        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
        desc.storageMode = .private
        depthThickPassDesc.depthAttachment.texture = Engine.device.makeTexture(descriptor: desc)
        
        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: width, height: height, mipmapped: false)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        desc.storageMode = .private
        normalDepthTexture = Engine.device.makeTexture(descriptor: desc)
        
        // binding texture
        material.normalDepthTexture = normalDepthTexture
        material.thickTexture = thickTexture
        
        smoothPass.threadsPerGridX = width
        smoothPass.threadsPerGridY = height

        restoreNormalPass.threadsPerGridX = width
        restoreNormalPass.threadsPerGridY = height
        restoreNormalPass.defaultShaderData.setImageView("u_normalDepthOut", normalDepthTexture)
        
        // calculate camera parameter
        let tanHalfFov = tan(MathUtil.degreeToRadian(camera.fieldOfView) * 0.5)
        _ssfData.canvasHeight = Float(height)
        _ssfData.canvasWidth = Float(width)
        _ssfData.p_f = camera.farClipPlane
        _ssfData.p_n = camera.nearClipPlane
        _ssfData.p_t = tanHalfFov * camera.nearClipPlane
        _ssfData.p_r = camera.aspectRatio * _ssfData.p_t
        thickMtl.shaderData.setData(ScreenSpaceFluid._ssfProperty, _ssfData)
        depthMtl.shaderData.setData(ScreenSpaceFluid._ssfProperty, _ssfData)
        restoreNormalPass.defaultShaderData.setData(ScreenSpaceFluid._ssfProperty, _ssfData)
        material.shaderData.setData(ScreenSpaceFluid._ssfProperty, _ssfData)
    }
    
    public override func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
        if let canvas = _canvasChanged {
            createTexture(Int(canvas.size.width), Int(canvas.size.height))
            _canvasChanged = nil
        }
        
        if let mesh = _particleMesh {
            subpass.element = RenderElement(renderer, mesh, mesh.subMesh!, thickMtl, thickMtl.shader[0])
            subpass.pixelFormat = .r16Float
            depthThickPassDesc.colorAttachments[0].texture = thickTexture
            renderPass.draw(commandBuffer, depthThickPassDesc, "ssf thick")
            
            subpass.element = RenderElement(renderer, mesh, mesh.subMesh!, depthMtl, depthMtl.shader[0])
            subpass.pixelFormat = .r32Float
            depthThickPassDesc.colorAttachments[0].texture = depthTexture[0]
            renderPass.draw(commandBuffer, depthThickPassDesc, "ssf depth")
            
            if let encoder = commandBuffer.makeComputeCommandEncoder() {
                encoder.label = "ssf compute"
                var currentIdx = 0
                for _ in 0..<smoothIter {
                    smoothPass.defaultShaderData.setImageView("depthIn", depthTexture[currentIdx])
                    smoothPass.defaultShaderData.setImageView("depthOut", depthTexture[1 - currentIdx])
                    smoothPass.compute(commandEncoder: encoder)
                    currentIdx = 1 - currentIdx
                }
                
                restoreNormalPass.defaultShaderData.setImageView("u_depthIn", depthTexture[currentIdx])
                restoreNormalPass.compute(commandEncoder: encoder)
                encoder.endEncoding()
            }
        }
    }
}
