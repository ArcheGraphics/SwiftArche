//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class DevicePipeline {
    static func _compareFromNearToFar(a: RenderElement, b: RenderElement) -> Bool {
        a.data.renderer.priority > b.data.renderer.priority || a.data.renderer._distanceForSort > b.data.renderer._distanceForSort
    }

    static func _compareFromFarToNear(a: RenderElement, b: RenderElement) -> Bool {
        a.data.renderer.priority > b.data.renderer.priority || b.data.renderer._distanceForSort > a.data.renderer._distanceForSort
    }
    
    final class RenderCommandEncoderData: EmptyClassType {
        var colorOutput: [Resource<MTLTextureDescriptor>] = []
        var depthOutput: Resource<MTLTextureDescriptor>?
        var inputShadow: Resource<MTLTextureDescriptor>?
        required init() {}
    }

    var camera: Camera
    var context = RenderContext()
    var _opaqueQueue: [RenderElement] = []
    var _transparentQueue: [RenderElement] = []
    var _alphaTestQueue: [RenderElement] = []
    var _backgroundSubpass: Subpass?
    var _forwardSubpass = ForwardSubpass()
    public var shadowManager: ShadowManager!

    public init(_ camera: Camera) {
        self.camera = camera
        shadowManager = ShadowManager(self)
    }

    public func commit(with commandBuffer: MTLCommandBuffer) {
        context.replacementShader = camera._replacementShader
        context.replacementTag = camera._replacementSubShaderTag
        
        let fg = Engine.fg
        var colorOutput: [Resource<MTLTextureDescriptor>] = []
        var depthOutput: Resource<MTLTextureDescriptor>?
        if let renderTarget = camera.renderTarget {
            if let depthTexture = renderTarget.depthAttachment.texture {
                colorOutput.append(fg.addRetainedResource(for: MTLTextureDescriptor.self,
                                                          name: "camera depthTexture",
                                                          description: MTLTextureDescriptor(),
                                                          actual: depthTexture))
            }
            for i in 0..<32 {
                if let colorTexture = renderTarget.colorAttachments[i].texture {
                    depthOutput = fg.addRetainedResource(for: MTLTextureDescriptor.self,
                                                         name: "camera colorTexture\(i)",
                                                         description: MTLTextureDescriptor(),
                                                         actual: colorTexture)
                }
            }
        }
        
        context.pipelineStageTagValue = PipelineStage.ShadowCaster
        // shadow pass automatic culled if not used
        shadowManager.draw(with: commandBuffer, context: context)
        
        let scene = camera.scene
        let background = scene.background
        _changeBackground(background)
        
        context.pipelineStageTagValue = PipelineStage.Forward
        // main forward pass
        if let renderTarget = camera.renderTarget ?? Engine.canvas.currentRenderPassDescriptor {
            if background.mode == BackgroundMode.SolidColor {
                let color = background.solidColor.toLinear()
                renderTarget.colorAttachments[0].clearColor = MTLClearColor(
                        red: Double(color.r), green: Double(color.g), blue: Double(color.b), alpha: Double(color.a)
                )
            }
            
            fg.addFrameTask(for: RenderCommandEncoderData.self, name: "forward pass", commandBuffer: commandBuffer) {
                [unowned self] data, builder in
                if camera.renderTarget != nil {
                    data.colorOutput = colorOutput.map({ resource in
                        builder.write(resource: resource)
                    })
                    if let depthOutput {
                        data.depthOutput = builder.write(resource: depthOutput)
                    }
                } else {
                    data.colorOutput.append(builder.write(resource: fg.blackboard[BlackBoardType.color.rawValue] as! Resource<MTLTextureDescriptor>))
                    data.depthOutput = builder.write(resource: fg.blackboard[BlackBoardType.depth.rawValue]  as! Resource<MTLTextureDescriptor>)
                }
                
                if let sunLight = scene._sunLight,
                   scene.castShadows && sunLight.shadowType != ShadowType.None {
                    data.inputShadow = builder.read(resource: fg.blackboard[BlackBoardType.shadow.rawValue] as! Resource<MTLTextureDescriptor>)
                }
            } execute: { [self] builder, commandBuffer in
                if let commandBuffer {
                    var encoder = RenderCommandEncoder(commandBuffer, renderTarget, "forward pass")
                    _forwardSubpass.draw(pipeline: self, on: &encoder)
                    if let background = _backgroundSubpass {
                        background.draw(pipeline: self, on: &encoder)
                    }
                    encoder.endEncoding()
                }
            }
        }
    }

    private func _changeBackground(_ background: Background) {
        switch background.mode {
        case .Sky:
            _backgroundSubpass = background.sky
            break
        case .Texture:
            _backgroundSubpass = background.texture
            break
        case .AR:
#if os(iOS)
            _backgroundSubpass = background.ar
#endif
            break
        case .SolidColor:
            _backgroundSubpass = nil
        }
    }

    func callRender(_ cameraInfo: CameraInfo) {
        let renderers = Engine._componentsManager._renderers
        for i in 0..<renderers.count {
            let renderer = renderers.get(i)!

            // filter by camera culling mask.
            if (camera.cullingMask.rawValue & renderer._entity.layer.rawValue) == 0 {
                continue
            }

            // filter by camera frustum.
            if (camera.enableFrustumCulling) {
                renderer.isCulled = !camera._frustum.intersectsBox(box: renderer.bounds)
                if (renderer.isCulled) {
                    continue
                }
            }
            renderer._prepareRender(cameraInfo, self)
        }
    }
    
    /// Push render data to render queue.
    /// - Parameters:
    ///   - context: Render context
    ///   - data: Render data
    func pushRenderData(_ data: RenderData) {
        let material = data.material
        let renderStates = material.renderStates
        let materialSubShader = material.shader.subShaders[0]
        let replacementShader = context.replacementShader

      if let replacementShader {
          let replacementSubShaders = replacementShader.subShaders
          let replacementTagKey = context.replacementTag
          if let replacementTagKey {
              for i in 0..<replacementSubShaders.count {
                  let subShader = replacementSubShaders[i];
                  if subShader.tagsMap[replacementTagKey] == materialSubShader.tagsMap[replacementTagKey] {
                      pushRenderDataWihShader(data, subShader.passes, renderStates);
                      break;
                  }
              }
          } else {
              pushRenderDataWihShader(data, replacementSubShaders[0].passes, renderStates);
          }
      } else {
          pushRenderDataWihShader(data, materialSubShader.passes, renderStates);
      }
    }
    
    private func pushRenderDataWihShader(_ element: RenderData,
                                         _ shaderPasses: [ShaderPass],
                                         _ renderStates: [RenderState]) {
        let pipelineStage = context.pipelineStageTagValue
        for i in 0..<shaderPasses.count {
          let shaderPass = shaderPasses[i]
            if (shaderPass.tagsMap[ShaderTagKey.pipelineStage.rawValue] == pipelineStage) {
                let renderElement = RenderElement(data: element, shaderPass: shaderPass, renderState: renderStates[i]);
                switch (renderElement.renderState.renderQueueType) {
                case RenderQueueType.Transparent:
                    _transparentQueue.append(renderElement)
                    break;
                case RenderQueueType.AlphaTest:
                    _alphaTestQueue.append(renderElement)
                    break;
                case RenderQueueType.Opaque:
                    _opaqueQueue.append(renderElement)
                    break;
                }
            }
        }
    }
}
