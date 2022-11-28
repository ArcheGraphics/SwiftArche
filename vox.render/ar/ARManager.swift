//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ARKit
import vox_math

public class ARManager: NSObject {
    let _session = ARSession()
    // Captured image texture cache
    var capturedImageTextureCache: CVMetalTextureCache!
    var capturedImageTextureY: CVMetalTexture?
    var capturedImageTextureCbCr: CVMetalTexture?
    private var _onUpdateScripts: DisorderedArray<Script> = DisorderedArray()

    public var camera: Camera? = nil
    public var session: ARSession {
        get {
            _session
        }
    }

    public init(_ device: MTLDevice) {
        super.init()
        // Create captured image texture cache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        capturedImageTextureCache = textureCache
        _session.delegate = self
    }
    
    public func run() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        session.run(configuration)
    }
    
    public func pause() {
        session.pause()
    }

    func addOnUpdateScript(_ script: Script) {
        script._onUpdateIndex = _onUpdateScripts.count
        _onUpdateScripts.add(script)
    }

    func removeOnUpdateScript(_ script: Script) {
        let replaced = _onUpdateScripts.deleteByIndex(script._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = script._onUpdateIndex
        }
        script._onUpdateIndex = -1
    }

    func update(_ deltaTime: Float) {
        guard let currentFrame = session.currentFrame else {
            return
        }

        if camera != nil {
            let arCamera = currentFrame.camera
            var viewMatrix = Matrix(arCamera.viewMatrix(for: .landscapeRight))
            camera!.entity.transform.worldMatrix = viewMatrix.invert()
            camera!.projectionMatrix = Matrix(arCamera.projectionMatrix(for: .landscapeRight, viewportSize: camera!.engine.canvas.bounds.size,
                    zNear: CGFloat(camera!.nearClipPlane), zFar: CGFloat(camera!.farClipPlane)))

            let elements = _onUpdateScripts._elements
            for i in 0..<_onUpdateScripts.count {
                let element = elements[i]!
                if (element._started) {
                    element.onARUpdate(deltaTime, currentFrame)
                }
            }
        }
    }

    private func updateCapturedImageTextures(frame: ARFrame) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage

        if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) {
            return
        }

        capturedImageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .r8Unorm, planeIndex: 0)
        capturedImageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .rg8Unorm, planeIndex: 1)
    }

    private func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, capturedImageTextureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)

        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }
}

extension ARManager: ARSessionDelegate {
    ///
    /// This is called when a new frame has been updated.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - frame: The frame that has been updated.
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateCapturedImageTextures(frame: frame)
    }

    /// This is called when new anchors are added to the session.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of added anchors.
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }

    /// This is called when anchors are updated.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of updated anchors.
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    }

    /// This is called when anchors are removed from the session.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of removed anchors.
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    }

    ///  This is called when a session fails.
    /// - Parameters:
    ///   - session: The session that failed.
    ///   - error: The error being reported (see ARError.h).
    /// - Remark: On failure the session will be paused.
    public func session(_ session: ARSession, didFailWithError error: Error) {
    }

    /// This is called when the camera’s tracking state has changed.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - camera: The camera that changed tracking states.
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }

    /// This is called when a session is interrupted.
    /// - Remark: A session will be interrupted and no longer able to track when
    /// it fails to receive required sensor data. This happens when video capture is interrupted,
    /// for example when the application is sent to the background or when there are
    /// multiple foreground applications (see AVCaptureSessionInterruptionReason).
    /// No additional frame updates will be delivered until the interruption has ended.
    /// - Parameter session: The session that was interrupted.
    public func sessionWasInterrupted(_ session: ARSession) {
    }

    /// This is called when a session interruption has ended.
    /// - Remark: A session will continue running from the last known state once
    /// the interruption has ended. If the device has moved, anchors will be misaligned.
    /// To avoid this, some applications may want to reset tracking (see ARSessionRunOptions)
    /// or attempt to relocalize (see `-[ARSessionObserver sessionShouldAttemptRelocalization:]`).
    /// - Parameter session: The session that was interrupted.
    public func sessionInterruptionEnded(_ session: ARSession) {
    }

    /// This is called after a session resumes from a pause or interruption to determine
    /// whether or not the session should attempt to relocalize.
    /// - Remark:  To avoid misaligned anchors, apps may wish to attempt a relocalization after
    /// a session pause or interruption. If YES is returned: the session will begin relocalizing
    /// and tracking state will switch to limited with reason relocalizing. If successful, the
    /// session's tracking state will return to normal. Because relocalization depends on
    /// the user's location, it can run indefinitely. Apps that wish to give up on relocalization
    /// may call run with `ARSessionRunOptionResetTracking` at any time.
    /// - Parameter session: The session to relocalize.
    /// - Returns: Return YES to begin relocalizing.
    @available(iOS 11.3, macCatalyst 13.1, *)
    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        true
    }

    /// This is called when the session outputs a new audio sample buffer.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - audioSampleBuffer: The captured audio sample buffer.
    public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
    }

    /// This is called when the session generated new collaboration data.
    /// - Remark: This data should be sent to all participants.
    /// - Parameters:
    ///   - session: The session that produced world tracking collaboration data.
    ///   - data: Collaboration data to be sent to participants.
    @available(iOS 13.0, macCatalyst 13.1, *)
    public func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    }

    ///
    /// This is called when geo tracking status changes.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - geoTrackingStatus: Latest geo tracking status.
    @available(iOS 14.0, *)
    public func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
    }
}

