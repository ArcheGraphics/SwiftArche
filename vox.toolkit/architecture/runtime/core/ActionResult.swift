//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Contains information about a ProBuilder action (success, failure, notification, etc)
public final class ActionResult {
    /// Describes the results of an action.
    public enum Status {
        /// The action was a success.
        case Success
        /// A critical failure prevented the action from running.
        case Failure
        /// The action was not completed due to invalid parameters.
        case Canceled
        /// The action was not run because there was no meaningful action to be made.
        case NoChange
    }

    /// State of affairs after the operation.
    public private(set) var status: Status

    /// Short description of the results. Should be no longer than a few words.
    public private(set) var notification: String

    /// Create a new ActionResult.
    /// - Parameters:
    ///   - status: State of affairs after an action.
    ///   - notification: A short summary of the action performed.
    public init(status: ActionResult.Status, notification: String) {
        self.status = status
        self.notification = notification
    }

    public func ToBool() -> Bool {
        status == Status.Success
    }

    public static func FromBool(success: Bool) -> Bool {
        Bool(success ? ActionResult.Success : ActionResult(status: ActionResult.Status.Failure, notification: "Failure"))
    }

    /// Generic "Success" action result with no notification text.
    public static var Success: ActionResult {
        get {
            ActionResult(status: ActionResult.Status.Success, notification: "")
        }
    }

    /// Generic "No Selection" action result with "Nothing Selected" notification.
    public static var NoSelection: ActionResult {
        get {
            ActionResult(status: ActionResult.Status.Canceled, notification: "Nothing Selected")
        }
    }

    /// Generic "Canceled" action result with "User Canceled" notification.
    public static var UserCanceled: ActionResult {
        get {
            ActionResult(status: ActionResult.Status.Canceled, notification: "User Canceled")
        }
    }
}

extension Bool {
    init(_ res: ActionResult) {
        self = res.status == ActionResult.Status.Success
    }
}
