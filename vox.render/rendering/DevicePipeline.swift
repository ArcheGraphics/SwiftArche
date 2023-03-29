//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class DevicePipeline {
    static func _compareFromNearToFar(a: RenderElement, b: RenderElement) -> Bool {
        a.renderer.priority > b.renderer.priority || a.renderer._distanceForSort > b.renderer._distanceForSort
    }

    static func _compareFromFarToNear(a: RenderElement, b: RenderElement) -> Bool {
        a.renderer.priority > b.renderer.priority || b.renderer._distanceForSort > a.renderer._distanceForSort
    }

    var camera: Camera
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

    public func commit(fg: inout FrameGraph, with commandBuffer: MTLCommandBuffer) {
        let scene = camera.scene
        if (scene.castShadows && scene._sunLight?.shadowType != ShadowType.None) {
            shadowManager.draw(fg: &fg, with: commandBuffer)
        }
        
        let background = scene.background
        _changeBackground(background)

        var renderContext: RenderCommandEncoderDescriptor?
        if let renderTarget = camera.renderTarget {
            renderContext = RenderCommandEncoderDescriptor(label: "pass for \(camera.entity.name)",
                                                           renderTarget: renderTarget,
                                                           commandBuffer: commandBuffer)
        } else if let renderPassDescriptor = Engine.canvas!.currentRenderPassDescriptor {
            renderContext = RenderCommandEncoderDescriptor(label: "forward pass",
                                                           renderTarget: renderPassDescriptor,
                                                           commandBuffer: commandBuffer)
        }
        
        if let renderContext {
            if background.mode == BackgroundMode.SolidColor {
                let color = background.solidColor.toLinear()
                renderContext.renderTarget.colorAttachments[0].clearColor = MTLClearColor(
                        red: Double(color.r), green: Double(color.g), blue: Double(color.b), alpha: Double(color.a)
                )
            }
            
            fg.addRenderTask(for: RenderCommandEncoderData.self, name: "forward pass") { data, builder in
                data.output = builder.write(resource: builder.create(name: "", description: renderContext))
            } execute: { [self] builder in
                if var encoder = builder.output.actual {
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

    /// Push a render element to the render queue.
    /// - Parameter element: Render element
    func pushPrimitive(_ element: RenderElement) {
        switch element.shaderPass.renderState!.renderQueueType {
        case .AlphaTest:
            _alphaTestQueue.append(element)
            break
        case .Opaque:
            _opaqueQueue.append(element)
            break
        case .Transparent:
            _transparentQueue.append(element)
            break
        }
    }
}
