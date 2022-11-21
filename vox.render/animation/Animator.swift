//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// The controller of the animation system.
public class Animator: Component {
    var _animatorController: AnimatorController!
    var _controllerUpdateFlag: BoolUpdateFlag?

    var _onUpdateIndex: Int = -1

    private var _animatorLayersData: [Int: AnimatorLayerData] = [:]
    private var _crossOwnerCollection: [PropertyBase] = []
    private var _animationCurveOwners: [[Int: PropertyBase]] = []
    private var _animationEventHandlerPool: [AnimationEventHandler] = []

    /// The playback speed of the Animator, 1.0 is normal playback speed.
    var speed: Float = 1.0

    /// All layers from the AnimatorController which belongs this Animator.
    var animatorController: AnimatorController {
        get {
            _animatorController
        }
        set {
            if (newValue !== _animatorController) {
                _reset()
                if _controllerUpdateFlag != nil {
                    _controllerUpdateFlag = nil
                }
                _controllerUpdateFlag = newValue._registerChangeFlag()
                _animatorController = newValue
            }
        }
    }

    /// Play a state by name.
    /// - Parameters:
    ///   - stateName: The state name
    ///   - layerIndex: The layer index(default -1). If layer is -1, play the first state with the given state name
    ///   - normalizedTimeOffset: The time offset between 0 and 1(default 0)
    func play(_ stateName: String, _ layerIndex: Int = -1, _ normalizedTimeOffset: Float = 0) {
        if (_controllerUpdateFlag?.flag != nil) {
            _clearPlayData()
        }

        let animatorInfo = _getAnimatorStateInfo(stateName, layerIndex)
        let state = animatorInfo.state

        if (state == nil) {
            return
        }
        if (state!.clip == nil) {
            logger.warning("The state named \(stateName) has no AnimationClip data.")
            return
        }
        let animatorLayerData = _getAnimatorLayerData(animatorInfo.layerIndex)
        let srcPlayData = animatorLayerData.srcPlayData
        let curState = srcPlayData.state
        if (curState != nil && curState !== state) {
            _revertDefaultValue(srcPlayData)
        }

        //CM: Not consider same stateName, but different animation
        let animatorStateData = _getAnimatorStateData(stateName, state!, animatorLayerData)

        animatorLayerData.layerState = LayerState.Playing
        srcPlayData.reset(state!, animatorStateData, state!._getDuration() * normalizedTimeOffset)

        _saveDefaultValues(animatorStateData)
    }

    /// Create a cross fade from the current state to another state.
    /// - Parameters:
    ///   - stateName: The state name
    ///   - normalizedTransitionDuration: The duration of the transition (normalized)
    ///   - layerIndex: The layer index(default -1). If layer is -1, play the first state with the given state name
    ///   - normalizedTimeOffset: The time offset between 0 and 1(default 0)
    func crossFade(_ stateName: String,
                   _ normalizedTransitionDuration: Float,
                   _ layerIndex: Int = -1,
                   _ normalizedTimeOffset: Float = 0) {
        if (_controllerUpdateFlag?.flag != nil) {
            _clearPlayData()
        }

        let state = _getAnimatorStateInfo(stateName, layerIndex).state
        let manuallyTransition = _getAnimatorLayerData(layerIndex).manuallyTransition
        manuallyTransition.duration = normalizedTransitionDuration
        manuallyTransition.offset = normalizedTimeOffset
        manuallyTransition.destinationState = state
        _crossFadeByTransition(manuallyTransition, layerIndex)
    }

    /// Evaluates the animator component based on deltaTime.
    /// - Parameter deltaTime: The deltaTime when the animation update
    func update(_ deltaTime: Float) {
        var deltaTime = deltaTime
        if (speed == 0) {
            return
        }

        if (_animatorController == nil) {
            return
        }
        if (_controllerUpdateFlag?.flag != nil) {
            return
        }
        deltaTime *= speed
        for i in 0..<animatorController.layers.count {
            let animatorLayerData = _getAnimatorLayerData(i)
            if (animatorLayerData.layerState == LayerState.Standby) {
                continue
            }

            _updateLayer(i, i == 0, deltaTime / 1000)
        }
    }

    internal override func _onEnable() {
        engine._componentsManager.addOnUpdateAnimations(self)
    }

    internal override func _onDisable() {
        engine._componentsManager.removeOnUpdateAnimations(self)
    }

    func _reset() {
        for propertyOwners in _animationCurveOwners {
            for property in propertyOwners {
                let owner = property.value
                switch owner.property {
                case "position":
                    let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    if ownerType.hasSavedDefaultValue {
                        ownerType.revertDefaultValue()
                    }
                    break
                default:
                    break
                }
            }
        }
        _clearPlayData()
    }

    private func _getAnimatorStateInfo(_ stateName: String, _ layerIndex: Int) -> AnimatorStateInfo {
        var layerIndex = layerIndex
        var state: AnimatorState? = nil
        if (_animatorController != nil) {
            let layers = _animatorController.layers
            if (layerIndex == -1) {
                for i in 0..<layers.count {
                    state = layers[i].stateMachine.findStateByName(stateName)
                    if (state != nil) {
                        layerIndex = i
                        break
                    }
                }
            } else {
                state = layers[layerIndex].stateMachine.findStateByName(stateName)
            }
        }
        var out = AnimatorStateInfo()
        out.layerIndex = layerIndex
        out.state = state
        return out
    }

    private func _saveDefaultValues(_ stateData: AnimatorStateData) {
        let curveOwners = stateData.curveOwners
        for i in 0..<curveOwners.count {
            if let owner = curveOwners[i] {
                switch owner.property {
                case "position":
                    (owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>).saveDefaultValue()
                default:
                    break
                }
            }
        }
    }

    private func _getAnimatorStateData(_ stateName: String,
                                       _ animatorState: AnimatorState,
                                       _ animatorLayerData: AnimatorLayerData) -> AnimatorStateData {
        var animatorStateData = animatorLayerData.animatorStateDataMap[stateName]
        if animatorStateData == nil {
            animatorStateData = AnimatorStateData()
            animatorLayerData.animatorStateDataMap[stateName] = animatorStateData
            _saveAnimatorStateData(animatorState, animatorStateData!)
            _saveAnimatorEventHandlers(animatorState, animatorStateData!)
        }
        return animatorStateData!
    }

    private func _saveAnimatorStateData(_ animatorState: AnimatorState, _ animatorStateData: AnimatorStateData) {
        let curves = animatorState.clip!._curveBindings
        for i in 0..<curves.count {
            let curve = curves[i]
            switch curve.property {
            case "position":
                let curveType = curve as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                let targetEntity = curveType.relativePath == "" ? entity : entity.findByPath(curveType.relativePath)
                if (targetEntity != nil) {
                    let instanceId = targetEntity!.instanceId
                    _animationCurveOwners[instanceId] = [:]
                    animatorStateData.curveOwners[i] = curveType._createCurveOwner(targetEntity!)
                } else {
                    animatorStateData.curveOwners[i] = nil
                }
                break
            default:
                break
            }
        }
    }

    private func _saveAnimatorEventHandlers(_ state: AnimatorState, _ animatorStateData: AnimatorStateData) {
        // TODO: related to script
    }

    private func _clearCrossData(_ animatorLayerData: AnimatorLayerData) {
        animatorLayerData.crossCurveMark += 1
        _crossOwnerCollection = []
    }

    private func _addCrossCurveData(_ crossCurveData: inout [PropertyBase],
                                    _ owner: PropertyBase,
                                    _ curCurveIndex: Int,
                                    _ nextCurveIndex: Int) {
        switch owner.property! {
        case "position":
            let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
            ownerType.crossSrcCurveIndex = curCurveIndex
            ownerType.crossDestCurveIndex = nextCurveIndex
            crossCurveData.append(owner)
            break
        case "rotation":
            let ownerType = owner as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
            ownerType.crossSrcCurveIndex = curCurveIndex
            ownerType.crossDestCurveIndex = nextCurveIndex
            crossCurveData.append(owner)
            break
        case "scale":
            let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
            ownerType.crossSrcCurveIndex = curCurveIndex
            ownerType.crossDestCurveIndex = nextCurveIndex
            crossCurveData.append(owner)
            break
        default:
            break
        }
    }

    private func _prepareCrossFading(_ animatorLayerData: AnimatorLayerData) {
        let crossCurveMark = animatorLayerData.crossCurveMark

        // Add src cross curve data.
        _prepareSrcCrossData(&_crossOwnerCollection, animatorLayerData.srcPlayData, crossCurveMark, false)
        // Add dest cross curve data.
        _prepareDestCrossData(&_crossOwnerCollection, animatorLayerData.destPlayData, crossCurveMark, false)
    }

    private func _prepareStandbyCrossFading(_ animatorLayerData: AnimatorLayerData) {
        let srcPlayData = animatorLayerData.srcPlayData
        let crossCurveMark = animatorLayerData.crossCurveMark

        // Standby have two sub state, one is never play, one is finished, never play srcPlayData is null.
        _prepareSrcCrossData(&_crossOwnerCollection, srcPlayData, crossCurveMark, true)

        // Add dest cross curve data.
        _prepareDestCrossData(&_crossOwnerCollection, animatorLayerData.destPlayData, crossCurveMark, true)
    }

    private func _prepareFixedPoseCrossFading(_ animatorLayerData: AnimatorLayerData) {
        // Save current cross curve data owner fixed pose.
        for i in 0..<_crossOwnerCollection.count {
            let item = _crossOwnerCollection[i]
            switch item.property {
            case "position":
                let itemType = item as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                itemType.saveFixedPoseValue()
                // Reset destCurveIndex When fixed pose crossFading again.
                itemType.crossDestCurveIndex = -1
                break
            case "rotation":
                let itemType = item as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                itemType.saveFixedPoseValue()
                // Reset destCurveIndex When fixed pose crossFading again.
                itemType.crossDestCurveIndex = -1
                break
            case "scale":
                let itemType = item as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                itemType.saveFixedPoseValue()
                // Reset destCurveIndex When fixed pose crossFading again.
                itemType.crossDestCurveIndex = -1
                break
            default:
                break
            }
        }
        // prepare dest AnimatorState cross data.
        _prepareDestCrossData(&_crossOwnerCollection, animatorLayerData.destPlayData, animatorLayerData.crossCurveMark, true)
    }

    private func _prepareSrcCrossData(
            _ crossCurveData: inout [PropertyBase],
            _ srcPlayData: AnimatorStatePlayData,
            _ crossCurveMark: Int,
            _ saveFixed: Bool
    ) {
        let curveOwners = srcPlayData.stateData.curveOwners
        for i in 0..<curveOwners.count {
            if let owner = curveOwners[i] {
                switch owner.property {
                case "position":
                    let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    ownerType.crossCurveMark = crossCurveMark
                    ownerType.crossCurveDataIndex = crossCurveData.count
                    if saveFixed {
                        ownerType.saveFixedPoseValue()
                    }
                    break
                case "rotation":
                    let ownerType = owner as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                    ownerType.crossCurveMark = crossCurveMark
                    ownerType.crossCurveDataIndex = crossCurveData.count
                    if saveFixed {
                        ownerType.saveFixedPoseValue()
                    }
                    break
                case "scale":
                    let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    ownerType.crossCurveMark = crossCurveMark
                    ownerType.crossCurveDataIndex = crossCurveData.count
                    if saveFixed {
                        ownerType.saveFixedPoseValue()
                    }
                    break
                default:
                    break
                }
                _addCrossCurveData(&crossCurveData, owner, i, -1)
            }
        }
    }

    private func _prepareDestCrossData(
            _ crossCurveData: inout [PropertyBase],
            _ destPlayData: AnimatorStatePlayData,
            _ crossCurveMark: Int,
            _ saveFixed: Bool
    ) {
        let curveOwners = destPlayData.stateData.curveOwners
        for i in 0..<curveOwners.count {
            if let owner = curveOwners[i] {
                switch owner.property {
                case "position":
                    let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    // Not include in previous AnimatorState.
                    if (ownerType.crossCurveMark == crossCurveMark) {
                        (crossCurveData[ownerType.crossCurveDataIndex] as! AnimationCurveOwner<Vector3, AnimationVector3Curve>).crossDestCurveIndex = i
                    } else {
                        ownerType.saveDefaultValue()
                        if saveFixed {
                            ownerType.saveFixedPoseValue()
                        }
                        ownerType.crossCurveMark = crossCurveMark
                        ownerType.crossCurveDataIndex = crossCurveData.count
                        _addCrossCurveData(&crossCurveData, owner, -1, i)
                    }
                    break
                case "rotation":
                    let ownerType = owner as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                    // Not include in previous AnimatorState.
                    if (ownerType.crossCurveMark == crossCurveMark) {
                        (crossCurveData[ownerType.crossCurveDataIndex] as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>).crossDestCurveIndex = i
                    } else {
                        ownerType.saveDefaultValue()
                        if saveFixed {
                            ownerType.saveFixedPoseValue()
                        }
                        ownerType.crossCurveMark = crossCurveMark
                        ownerType.crossCurveDataIndex = crossCurveData.count
                        _addCrossCurveData(&crossCurveData, owner, -1, i)
                    }
                    break
                case "scale":
                    let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    // Not include in previous AnimatorState.
                    if (ownerType.crossCurveMark == crossCurveMark) {
                        (crossCurveData[ownerType.crossCurveDataIndex] as! AnimationCurveOwner<Vector3, AnimationVector3Curve>).crossDestCurveIndex = i
                    } else {
                        ownerType.saveDefaultValue()
                        if saveFixed {
                            ownerType.saveFixedPoseValue()
                        }
                        ownerType.crossCurveMark = crossCurveMark
                        ownerType.crossCurveDataIndex = crossCurveData.count
                        _addCrossCurveData(&crossCurveData, owner, -1, i)
                    }
                    break
                default:
                    break
                }
            }
        }
    }

    private func _getAnimatorLayerData(_ layerIndex: Int) -> AnimatorLayerData {
        var animatorLayerData = _animatorLayersData[layerIndex]
        if animatorLayerData == nil {
            animatorLayerData = AnimatorLayerData()
            _animatorLayersData[layerIndex] = animatorLayerData
        }
        return animatorLayerData!
    }

    private func _updateLayer(_ layerIndex: Int, _ firstLayer: Bool, _ deltaTime: Float) {
        let blendingMode = _animatorController.layers[layerIndex].blendingMode
        let weight = _animatorController.layers[layerIndex].weight
        let animLayerData = _animatorLayersData[layerIndex]!
        let srcPlayData = animLayerData.srcPlayData
        let destPlayData = animLayerData.destPlayData
        let crossFadeTransitionInfo = animLayerData.crossFadeTransition!
        let layerAdditive = blendingMode == AnimatorLayerBlendingMode.Additive
        let layerWeight = firstLayer ? 1.0 : weight
        _checkTransition(srcPlayData, crossFadeTransitionInfo, layerIndex)
        switch (animLayerData.layerState) {
        case LayerState.Playing:
            _updatePlayingState(srcPlayData, animLayerData, layerIndex, layerWeight, deltaTime, layerAdditive)
            break
        case LayerState.FixedCrossFading:
            _updateCrossFadeFromPose(destPlayData, animLayerData, layerIndex, layerWeight, deltaTime, layerAdditive)
            break
        case LayerState.CrossFading:
            _updateCrossFade(
                    srcPlayData,
                    destPlayData,
                    animLayerData,
                    layerIndex,
                    layerWeight,
                    deltaTime,
                    layerAdditive
            )
            break
        default:
            fatalError()
        }
    }

    private func _updatePlayingState(
            _ playData: AnimatorStatePlayData,
            _ layerData: AnimatorLayerData,
            _ layerIndex: Int,
            _ weight: Float,
            _ delta: Float,
            _ additive: Bool
    ) {
        let curveOwners = playData.stateData.curveOwners
        let eventHandlers = playData.stateData.eventHandlers
        let state = playData.state!
        let lastPlayState = playData.playState
        let lastClipTime = playData.clipTime!
        let curveBindings = state.clip!._curveBindings

        playData.update(isBackwards: speed < 0)

        let clipTime = playData.clipTime!
        let playState = playData.playState

        if eventHandlers.count != 0 {
            _fireAnimationEvents(playData, eventHandlers, lastClipTime, clipTime)
        }

        for i in 0..<curveBindings.count {
            if let owner = curveOwners[i] {
                switch owner.property {
                case "position":
                    let ownerType = curveOwners[i] as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    let curveBindingType = curveBindings[i] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                    ownerType.evaluateAndApplyValue(curveBindingType.curve, clipTime, weight, additive)
                    break
                case "rotation":
                    let ownerType = curveOwners[i] as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                    let curveBindingType = curveBindings[i] as! AnimationClipCurveBinding<Quaternion, AnimationQuaternionCurve>
                    ownerType.evaluateAndApplyValue(curveBindingType.curve, clipTime, weight, additive)
                    break
                case "scale":
                    let ownerType = curveOwners[i] as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                    let curveBindingType = curveBindings[i] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                    ownerType.evaluateAndApplyValue(curveBindingType.curve, clipTime, weight, additive)
                    break
                default:
                    break
                }
            }
        }

        playData.frameTime += state.speed * delta

        if (playState == AnimatorStatePlayState.Finished) {
            layerData.layerState = LayerState.Standby
        }

        if (lastPlayState == AnimatorStatePlayState.UnStarted) {
            _callAnimatorScriptOnEnter(state, layerIndex)
        }
        if (playState == AnimatorStatePlayState.Finished) {
            _callAnimatorScriptOnExit(state, layerIndex)
        } else {
            _callAnimatorScriptOnUpdate(state, layerIndex)
        }
    }

    private func _updateCrossFade(
            _ srcPlayData: AnimatorStatePlayData,
            _ destPlayData: AnimatorStatePlayData,
            _ layerData: AnimatorLayerData,
            _ layerIndex: Int,
            _ weight: Float,
            _ delta: Float,
            _ additive: Bool
    ) {
        let srcCurves = srcPlayData.state.clip!._curveBindings
        let srcState = srcPlayData.state!
        let srcStateData = srcPlayData.stateData
        let lastSrcPlayState = srcPlayData.playState
        let srcEventHandler = srcStateData!.eventHandlers

        let destState = destPlayData.state!
        let destStateData = destPlayData.stateData
        let lastDstPlayState = destPlayData.playState
        let destEventHandler = destStateData!.eventHandlers

        let destCurves = destState.clip!._curveBindings
        let lastSrcClipTime = srcPlayData.clipTime!
        let lastDestClipTime = destPlayData.clipTime!

        var crossWeight = destPlayData.frameTime / (destState._getDuration() * layerData.crossFadeTransition.duration)
        if crossWeight >= 1.0 {
            crossWeight = 1.0
        }
        srcPlayData.update(isBackwards: speed < 0)
        destPlayData.update(isBackwards: speed < 0)

        let srcClipTime = srcPlayData.clipTime!
        let destClipTime = destPlayData.clipTime!

        if srcEventHandler.count != 0 {
            _fireAnimationEvents(srcPlayData, srcEventHandler, lastSrcClipTime, srcClipTime)
        }
        if destEventHandler.count != 0 {
            _fireAnimationEvents(destPlayData, destEventHandler, lastDestClipTime, destClipTime)
        }

        if (lastSrcPlayState == AnimatorStatePlayState.UnStarted) {
            _callAnimatorScriptOnEnter(srcState, layerIndex)
        }
        if (crossWeight == 1 || srcPlayData.playState == AnimatorStatePlayState.Finished) {
            _callAnimatorScriptOnExit(srcState, layerIndex)
        } else {
            _callAnimatorScriptOnUpdate(srcState, layerIndex)
        }

        if (lastDstPlayState == AnimatorStatePlayState.UnStarted) {
            _callAnimatorScriptOnEnter(destState, layerIndex)
        }
        if (destPlayData.playState == AnimatorStatePlayState.Finished) {
            _callAnimatorScriptOnExit(destState, layerIndex)
        } else {
            _callAnimatorScriptOnUpdate(destState, layerIndex)
        }

        for i in 0..<_crossOwnerCollection.count {
            let crossCurveData = _crossOwnerCollection[i]
            switch crossCurveData.property {
            case "position":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                let crossSrcCurveIndex = crossCurveDataType.crossSrcCurveIndex
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let srcCurvesType = srcCurves[crossSrcCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                let destCurvesType = destCurves[crossDestCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                crossCurveDataType.crossFadeAndApplyValue(
                        crossSrcCurveIndex >= 0 ? srcCurvesType.curve : nil,
                        crossDestCurveIndex >= 0 ? destCurvesType.curve : nil,
                        srcClipTime,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive
                )
                break
            case "rotation":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                let crossSrcCurveIndex = crossCurveDataType.crossSrcCurveIndex
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let srcCurvesType = srcCurves[crossSrcCurveIndex] as! AnimationClipCurveBinding<Quaternion, AnimationQuaternionCurve>
                let destCurvesType = destCurves[crossDestCurveIndex] as! AnimationClipCurveBinding<Quaternion, AnimationQuaternionCurve>
                crossCurveDataType.crossFadeAndApplyValue(
                        crossSrcCurveIndex >= 0 ? srcCurvesType.curve : nil,
                        crossDestCurveIndex >= 0 ? destCurvesType.curve : nil,
                        srcClipTime,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive
                )
                break
            case "scale":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                let crossSrcCurveIndex = crossCurveDataType.crossSrcCurveIndex
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let srcCurvesType = srcCurves[crossSrcCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                let destCurvesType = destCurves[crossDestCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>
                crossCurveDataType.crossFadeAndApplyValue(
                        crossSrcCurveIndex >= 0 ? srcCurvesType.curve : nil,
                        crossDestCurveIndex >= 0 ? destCurvesType.curve : nil,
                        srcClipTime,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive
                )
                break
            default:
                break
            }
        }
    }

    private func _updateCrossFadeFromPose(_ destPlayData: AnimatorStatePlayData,
                                          _ layerData: AnimatorLayerData,
                                          _ layerIndex: Int,
                                          _ weight: Float,
                                          _ delta: Float,
                                          _ additive: Bool) {
        let state = destPlayData.state!
        let stateData = destPlayData.stateData!
        let lastPlayState = destPlayData.playState
        let eventHandlers = stateData.eventHandlers
        let lastDestClipTime = destPlayData.clipTime!
        let curveBindings = state.clip!._curveBindings

        var crossWeight = destPlayData.frameTime / (state._getDuration() * layerData.crossFadeTransition.duration)
        if crossWeight >= 1.0 {
            crossWeight = 1.0
        }
        destPlayData.update(isBackwards: speed < 0)

        let playState = destPlayData.playState

        _updateCrossFadeData(layerData, crossWeight, delta, true)

        let destClipTime = destPlayData.clipTime!
        if eventHandlers.count != 0 {
            _fireAnimationEvents(destPlayData, eventHandlers, lastDestClipTime, destClipTime)
        }

        if (lastPlayState == AnimatorStatePlayState.UnStarted) {
            _callAnimatorScriptOnEnter(state, layerIndex)
        }
        if (playState == AnimatorStatePlayState.Finished) {
            _callAnimatorScriptOnExit(state, layerIndex)
        } else {
            _callAnimatorScriptOnUpdate(state, layerIndex)
        }

        for i in 0..<_crossOwnerCollection.count {
            let crossCurveData = _crossOwnerCollection[i]
            switch crossCurveData.property {
            case "position":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let curveType = curveBindings[crossDestCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>

                crossCurveDataType.crossFadeFromPoseAndApplyValue(
                        crossDestCurveIndex >= 0 ? curveType.curve : nil,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive)
            case "rotation":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let curveType = curveBindings[crossDestCurveIndex] as! AnimationClipCurveBinding<Quaternion, AnimationQuaternionCurve>

                crossCurveDataType.crossFadeFromPoseAndApplyValue(
                        crossDestCurveIndex >= 0 ? curveType.curve : nil,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive)
                break
            case "scale":
                let crossCurveDataType = crossCurveData as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                let crossDestCurveIndex = crossCurveDataType.crossDestCurveIndex
                let curveType = curveBindings[crossDestCurveIndex] as! AnimationClipCurveBinding<Vector3, AnimationVector3Curve>

                crossCurveDataType.crossFadeFromPoseAndApplyValue(
                        crossDestCurveIndex >= 0 ? curveType.curve : nil,
                        destClipTime,
                        crossWeight,
                        weight,
                        additive)
                break
            default:
                break
            }
        }

        _updateCrossFadeData(layerData, crossWeight, delta, true)
    }

    private func _updateCrossFadeData(_ layerData: AnimatorLayerData, _ crossWeight: Float, _ delta: Float, _ fixed: Bool) {
        let destPlayData = layerData.destPlayData
        destPlayData.frameTime += destPlayData.state.speed * delta
        if (crossWeight == 1.0) {
            if (destPlayData.playState == AnimatorStatePlayState.Finished) {
                layerData.layerState = LayerState.Standby
            } else {
                layerData.layerState = LayerState.Playing
            }
            layerData.switchPlayData()
        } else {
            if !fixed {
                layerData.srcPlayData.frameTime += layerData.srcPlayData.state.speed * delta
            }
        }
    }

    private func _revertDefaultValue(_ playData: AnimatorStatePlayData) {
        let clip = playData.state.clip
        if (clip != nil) {
            let curves = clip!._curveBindings
            let curveOwners = playData.stateData.curveOwners
            for i in 0..<curves.count {
                if let owner = curveOwners[i] {
                    switch owner.property {
                    case "position":
                        let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                        if ownerType.hasSavedDefaultValue {
                            ownerType.revertDefaultValue()
                        }
                        break
                    case "rotation":
                        let ownerType = owner as! AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>
                        if ownerType.hasSavedDefaultValue {
                            ownerType.revertDefaultValue()
                        }
                        break
                    case "scale":
                        let ownerType = owner as! AnimationCurveOwner<Vector3, AnimationVector3Curve>
                        if ownerType.hasSavedDefaultValue {
                            ownerType.revertDefaultValue()
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
    }

    private func _checkTransition(_ stateData: AnimatorStatePlayData,
                                  _ crossFadeTransition: AnimatorStateTransition,
                                  _ layerIndex: Int) {
        let state = stateData.state
        let clipTime = stateData.clipTime
        let duration = state!._getDuration()
        let transitions = state!.transitions
        for i in 0..<transitions.count {
            let transition = transitions[i]
            if (duration * transition.exitTime <= clipTime!) {
                if crossFadeTransition !== transition {
                    _crossFadeByTransition(transition, layerIndex)
                }
            }
        }
    }

    private func _crossFadeByTransition(_ transition: AnimatorStateTransition, _ layerIndex: Int) {
        let name = transition.destinationState.name
        let animatorStateInfo = _getAnimatorStateInfo(name, layerIndex)
        let crossState = animatorStateInfo.state
        if (crossState == nil) {
            return
        }
        if (crossState!.clip == nil) {
            logger.warning("The state named \(name) has no AnimationClip data.")
            return
        }

        let animatorLayerData = _getAnimatorLayerData(animatorStateInfo.layerIndex)
        let layerState = animatorLayerData.layerState
        let destPlayData = animatorLayerData.destPlayData

        let animatorStateData = _getAnimatorStateData(name, crossState!, animatorLayerData)
        let duration = crossState!._getDuration()
        let offset = duration * transition.offset
        destPlayData.reset(crossState!, animatorStateData, offset)

        _saveDefaultValues(animatorStateData)

        switch (layerState) {
        case LayerState.Standby:
            animatorLayerData.layerState = LayerState.FixedCrossFading
            _clearCrossData(animatorLayerData)
            _prepareStandbyCrossFading(animatorLayerData)
            break
        case LayerState.Playing:
            animatorLayerData.layerState = LayerState.CrossFading
            _clearCrossData(animatorLayerData)
            _prepareCrossFading(animatorLayerData)
            break
        case LayerState.CrossFading:
            animatorLayerData.layerState = LayerState.FixedCrossFading
            _prepareFixedPoseCrossFading(animatorLayerData)
            break
        case LayerState.FixedCrossFading:
            _prepareFixedPoseCrossFading(animatorLayerData)
            break
        }

        animatorLayerData.crossFadeTransition = transition
    }

    private func _fireAnimationEvents(
            _ playState: AnimatorStatePlayData,
            _ eventHandlers: [AnimationEventHandler],
            _ lastClipTime: Float,
            _ clipTime: Float
    ) {
        let state = playState.state!
        let clipDuration = state.clip!.length
        if (speed >= 0) {
            if (clipTime < lastClipTime) {
                _fireSubAnimationEvents(playState, eventHandlers, lastClipTime, state.clipEndTime * clipDuration)
                playState.currentEventIndex = 0
                _fireSubAnimationEvents(playState, eventHandlers, state.clipStartTime * clipDuration, clipTime)
            } else {
                _fireSubAnimationEvents(playState, eventHandlers, lastClipTime, clipTime)
            }
        } else {
            if (clipTime > lastClipTime) {
                _fireBackwardSubAnimationEvents(
                        playState,
                        eventHandlers,
                        lastClipTime,
                        state.clipStartTime * clipDuration
                )
                playState.currentEventIndex = eventHandlers.count - 1
                _fireBackwardSubAnimationEvents(playState, eventHandlers, state.clipEndTime * clipDuration, clipTime)
            } else {
                _fireBackwardSubAnimationEvents(playState, eventHandlers, lastClipTime, clipTime)
            }
        }
    }

    private func _fireSubAnimationEvents(_ playState: AnimatorStatePlayData,
                                         _ eventHandlers: [AnimationEventHandler],
                                         _ lastClipTime: Float,
                                         _ curClipTime: Float) {
        for i in playState.currentEventIndex..<eventHandlers.count {
            let eventHandler = eventHandlers[i]
            let time = eventHandler.event.time
            let parameter = eventHandler.event.parameter

            if (time > curClipTime) {
                break
            }

            let handlers = eventHandler.handlers
            if (time >= lastClipTime) {
                for j in 0..<handlers.count {
                    handlers[j](parameter!)
                }
                playState.currentEventIndex = i + 1
            }
        }
    }

    private func _fireBackwardSubAnimationEvents(_ playState: AnimatorStatePlayData,
                                                 _ eventHandlers: [AnimationEventHandler],
                                                 _ lastClipTime: Float,
                                                 _ curClipTime: Float) {
        for eventIndex in 0..<playState.currentEventIndex {
            let eventHandler = eventHandlers[eventIndex]
            let time = eventHandler.event.time
            let parameter = eventHandler.event.parameter

            if (time < curClipTime) {
                break
            }

            if (time <= lastClipTime) {
                let handlers = eventHandler.handlers
                for j in 0..<handlers.count {
                    handlers[j](parameter!)
                }
                playState.currentEventIndex = max(eventIndex - 1, 0)
            }
        }
    }

    private func _callAnimatorScriptOnEnter(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateEnterScripts
        for i in 0..<scripts.count {
            scripts[i].onStateEnter(self, state, layerIndex)
        }
    }

    private func _callAnimatorScriptOnUpdate(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateUpdateScripts
        for i in 0..<scripts.count {
            scripts[i].onStateUpdate(self, state, layerIndex)
        }
    }

    private func _callAnimatorScriptOnExit(_ state: AnimatorState, _ layerIndex: Int) {
        let scripts = state._onStateExitScripts
        for i in 0..<scripts.count {
            scripts[i].onStateExit(self, state, layerIndex)
        }
    }

    private func _checkAutoPlay() {
        let layers = _animatorController.layers
        for i in 0..<layers.count {
            let stateMachine = layers[i].stateMachine
            if (stateMachine?.defaultState != nil) {
                play(stateMachine!.defaultState!.name, i)
            }
        }
    }

    private func _clearPlayData() {
        _animatorLayersData = [:]
        _crossOwnerCollection = []
        _animationCurveOwners = []

        if _controllerUpdateFlag != nil {
            _controllerUpdateFlag!.flag = false
        }
    }
}

struct AnimatorStateInfo {
    var layerIndex: Int = -1
    var state: AnimatorState?
}
