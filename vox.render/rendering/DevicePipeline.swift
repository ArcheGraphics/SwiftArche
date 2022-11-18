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
    var _resourceCache: ResourceCache
    var _backgroundSubpass: Subpass?
    public var mainRenderPass: RenderPass!

    public init(_ camera: Camera) {
        _resourceCache = ResourceCache(camera.engine.device)
        self.camera = camera
        mainRenderPass = RenderPass(self)
        mainRenderPass.addSubpass(ForwardSubpass())
    }

    public func commit(_ commandBuffer: MTLCommandBuffer) {
        let background = camera.scene.background
        _changeBackground(background)

        let canvas = camera.engine.canvas
        if let renderPassDescriptor = canvas.currentRenderPassDescriptor {
            if background.mode == BackgroundMode.SolidColor {
                renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                        red: Double(background.solidColor.r),
                        green: Double(background.solidColor.g),
                        blue: Double(background.solidColor.b),
                        alpha: Double(background.solidColor.a)
                )
            }
            mainRenderPass.draw(commandBuffer, camera.renderTarget != nil ? camera.renderTarget! : renderPassDescriptor)
        }
    }

    private func _changeBackground(_ background: Background) {
        var backgroundSubpass: Subpass? = nil
        switch background.mode {
        case .Sky:
            backgroundSubpass = background.sky
            break
        case .Texture:
            backgroundSubpass = background.texture
            break
        case .AR:
            backgroundSubpass = background.ar
            break
        case .SolidColor:
            backgroundSubpass = nil
        }

        if backgroundSubpass !== _backgroundSubpass {
            if _backgroundSubpass != nil {
                mainRenderPass.removeSubpass(_backgroundSubpass!)
            }
            if backgroundSubpass != nil {
                mainRenderPass.addSubpass(backgroundSubpass!)
            }
            _backgroundSubpass = backgroundSubpass
        }
    }

    func callRender(_ cameraInfo: CameraInfo) {
        let renderers = camera.engine._componentsManager._renderers
        for i in 0..<renderers.length {
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