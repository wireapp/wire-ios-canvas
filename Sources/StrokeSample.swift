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

    private(set) var point: CGPoint
    private(set) var updateIndex: NSNumber?

    private(set) var isPencilBased: Bool!
    private(set) var forceValue: CGFloat!
    private(set) var brushFactor: CGFloat!

    // MARK: - Initialization

    init(point: CGPoint, touch: UITouch) {
        self.point = point
        self.update(with: touch)
    }

    // MARK: - Changing the Data

    func move(to newLocation: CGPoint) {
        self.point = newLocation
    }

    func update(with touch: UITouch) {

        if #available(iOS 9.1, *) {
            self.updateIndex = touch.estimationUpdateIndex
            self.isPencilBased = (touch.type == .stylus)
            self.forceValue = touch.force / sin(touch.altitudeAngle)
            self.brushFactor = (forceValue == 0) ? 1 : forceValue / 5
        } else {
            self.brushFactor = 1
            self.isPencilBased = false
            self.forceValue = touch.force
        }

    }

}
