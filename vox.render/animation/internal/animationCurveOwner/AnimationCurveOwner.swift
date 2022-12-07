//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class AnimationCurveOwnerBase {
    /// The name or path to the property being animated.
    var property: AnimationProperty!
    var target: Entity!

    var crossCurveMark: Int = 0
    var crossCurveDataIndex: Int = 0
    var hasSavedDefaultValue: Bool = false
    var crossSrcCurveIndex: Int = 0
    var crossDestCurveIndex: Int = 0

    public func revertDefaultValue() {
    }

    public func saveDefaultValue() {
    }

    public func saveFixedPoseValue() {
    }
}

public class AnimationCurveOwner<V: KeyframeValueType, Calculator: IAnimationCurveCalculator>: AnimationCurveOwnerBase where Calculator.V == V {
    var defaultValue: V!
    var fixedPoseValue: V!
    var baseEvaluateData: IEvaluateData<V> = IEvaluateData()
    var crossEvaluateData: IEvaluateData<V> = IEvaluateData()

    var referenceTargetValue: V?
    private var _assembler: IAnimationCurveOwnerAssembler<V, Calculator>

    init(_ target: Entity, _ property: AnimationProperty,
         _ assembler: IAnimationCurveOwnerAssembler<V, Calculator>) {
        _assembler = assembler
        
        super.init()
        self.target = target
        self.property = property
        _assembler.initialize(owner: self)
        if (Calculator._isReferenceType) {
            referenceTargetValue = _assembler.getTargetValue()!
        }
    }

    public func evaluateAndApplyValue(_ curve: AnimationCurve<V, Calculator>, _ time: Float,
                                      _ layerWeight: Float, _ additive: Bool) {
        if (curve.keys.count != 0) {
            if (additive) {
                let value = curve._evaluateAdditive(time, &baseEvaluateData)

                if (Calculator._isReferenceType) {
                    _ = Calculator._additiveValue(value, layerWeight, referenceTargetValue!)
                } else {
                    let assembler = _assembler
                    let originValue = assembler.getTargetValue()!
                    let additiveValue = Calculator._additiveValue(value, layerWeight, originValue)
                    assembler.setTargetValue(additiveValue)
                }
            } else {
                let value = curve._evaluate(time, &baseEvaluateData)
                _applyValue(value, layerWeight)
            }
        }
    }

    public func crossFadeAndApplyValue(_ srcCurve: AnimationCurve<V, Calculator>?,
                                       _ destCurve: AnimationCurve<V, Calculator>?,
                                       _ srcTime: Float,
                                       _ destTime: Float,
                                       _ crossWeight: Float,
                                       _ layerWeight: Float,
                                       _ additive: Bool) {
        let srcValue =
                srcCurve != nil && srcCurve!.keys.count != 0
                        ? additive
                        ? srcCurve!._evaluateAdditive(srcTime, &baseEvaluateData)
                        : srcCurve!._evaluate(srcTime, &baseEvaluateData)
                        : additive
                        ? Calculator._getZeroValue(baseEvaluateData.value)
                        : defaultValue

        let destValue =
                destCurve != nil && destCurve!.keys.count != 0
                        ? additive
                        ? destCurve!._evaluateAdditive(destTime, &crossEvaluateData)
                        : destCurve!._evaluate(destTime, &crossEvaluateData)
                        : additive
                        ? Calculator._getZeroValue(crossEvaluateData.value)
                        : defaultValue

        _applyCrossValue(srcValue!, destValue!, crossWeight, layerWeight, additive)
    }

    public func crossFadeFromPoseAndApplyValue(_ destCurve: AnimationCurve<V, Calculator>?,
                                               _ destTime: Float,
                                               _ crossWeight: Float,
                                               _ layerWeight: Float,
                                               _ additive: Bool) {
        let srcValue = additive
                ? Calculator._subtractValue(fixedPoseValue, defaultValue, baseEvaluateData.value)
                : fixedPoseValue;
        let destValue =
                destCurve != nil && destCurve!.keys.count != 0
                        ? additive
                        ? destCurve!._evaluateAdditive(destTime, &crossEvaluateData)
                        : destCurve!._evaluate(destTime, &crossEvaluateData)
                        : additive
                        ? Calculator._getZeroValue(crossEvaluateData.value)
                        : defaultValue;

        _applyCrossValue(srcValue!, destValue!, crossWeight, layerWeight, additive);
    }

    public override func revertDefaultValue() {
        _assembler.setTargetValue(defaultValue)
    }

    public override func saveDefaultValue() {
        if (Calculator._isReferenceType) {
            _ = Calculator._copyValue(referenceTargetValue!, defaultValue)
        } else {
            defaultValue = _assembler.getTargetValue()
        }
        hasSavedDefaultValue = true
    }

    public override func saveFixedPoseValue() {
        if (Calculator._isReferenceType) {
            _ = Calculator._copyValue(referenceTargetValue!, fixedPoseValue)
        } else {
            fixedPoseValue = _assembler.getTargetValue()
        }
    }

    private func _applyValue(_ value: V, _ weight: Float) {
        if (weight == 1.0) {
            if (Calculator._isReferenceType) {
                _ = Calculator._copyValue(value, referenceTargetValue)
            } else {
                _assembler.setTargetValue(value)
            }
        } else {
            if (Calculator._isReferenceType) {
                let targetValue = referenceTargetValue
                _ = Calculator._lerpValue(targetValue!, value, weight, targetValue)
            } else {
                let originValue = _assembler.getTargetValue()!
                let lerpValue = Calculator._lerpValue(originValue, value, weight, nil)
                _assembler.setTargetValue(lerpValue)
            }
        }
    }

    private func _applyCrossValue(_ srcValue: V,
                                  _ destValue: V,
                                  _ crossWeight: Float,
                                  _ layerWeight: Float,
                                  _ additive: Bool) {
        let out: V
        if (Calculator._isReferenceType) {
            out = Calculator._lerpValue(srcValue, destValue, crossWeight, baseEvaluateData.value)
        } else {
            out = Calculator._lerpValue(srcValue, destValue, crossWeight, nil)
        }

        if (additive) {
            if (Calculator._isReferenceType) {
                _ = Calculator._additiveValue(out, layerWeight, referenceTargetValue!)
            } else {
                let originValue = _assembler.getTargetValue()!
                let lerpValue = Calculator._additiveValue(out, layerWeight, originValue)
                _assembler.setTargetValue(lerpValue)
            }
        } else {
            _applyValue(out, layerWeight)
        }
    }
}

struct IEvaluateData<V: KeyframeValueType> {
    var curKeyframeIndex: Int = 0
    var value: V = V()
}
