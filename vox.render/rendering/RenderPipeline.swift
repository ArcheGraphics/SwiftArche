//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class RenderPipeline {
    static func _compareFromNearToFar(a: RenderElement, b: RenderElement) -> Bool {
        a.renderer.priority > b.renderer.priority || a.renderer._distanceForSort > b.renderer._distanceForSort;
    }

    static func _compareFromFarToNear(a: RenderElement, b: RenderElement) -> Bool {
        a.renderer.priority > b.renderer.priority || b.renderer._distanceForSort > a.renderer._distanceForSort;
    }

    var camera: Camera
    var _opaqueQueue: [RenderElement] = []
    var _transparentQueue: [RenderElement] = []
    var _alphaTestQueue: [RenderElement] = []
    var _resourceCache: ResourceCache

    public init(_ camera: Camera) {
        _resourceCache = ResourceCache(camera.engine.device)
        self.camera = camera
    }

    public func render() {
        _opaqueQueue.removeAll()
        _alphaTestQueue.removeAll()
        _transparentQueue.removeAll()
        callRender(camera._cameraInfo)
        _opaqueQueue.sort(by: RenderPipeline._compareFromNearToFar);
        _alphaTestQueue.sort(by: RenderPipeline._compareFromNearToFar);
        _transparentQueue.sort(by: RenderPipeline._compareFromFarToNear);
    }

    func callRender(_ cameraInfo: CameraInfo) {
        let renderers = camera.engine._componentsManager._renderers;
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