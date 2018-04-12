//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import UIKit

class StrokeSample {

    let point: CGPoint
    let brushFactor: CGFloat
    let forceValue: CGFloat
    let isPencilBased: Bool

    init(point: CGPoint, touch: UITouch) {

        self.point = point

        if #available(iOS 9.1, *) {
            self.forceValue = touch.force / sin(touch.altitudeAngle)
            self.isPencilBased = (touch.type == .stylus)
            self.brushFactor = (forceValue == 0) ? 1 : forceValue / 5
        } else {
            self.brushFactor = 1
            self.isPencilBased = false
            self.forceValue = touch.force
        }


    }

    private init(point: CGPoint, brushFactor: CGFloat, forceValue: CGFloat, isPencilBased: Bool) {
        self.point = point
        self.brushFactor = brushFactor
        self.forceValue = forceValue
        self.isPencilBased = isPencilBased
    }

    func moving(to newLocation: CGPoint) -> StrokeSample {
        return StrokeSample(point: newLocation, brushFactor: self.brushFactor, forceValue: forceValue, isPencilBased: self.isPencilBased)
    }

}
