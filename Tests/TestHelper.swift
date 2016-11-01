//
//  TestHelper.swift
//  Canvas
//
//  Created by Jacob on 01/11/16.
//  Copyright © 2016 Wire GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    convenience init?(testImageNamed name: String) {
        func url(forTestResourceNamed name: String) -> URL? {
            let bundle = Bundle(for: CanvasTests.self)
            return bundle.url(forResource: (name as NSString).deletingPathExtension, withExtension:(name as NSString).pathExtension)
        }
        
        guard let url = url(forTestResourceNamed: name) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        self.init(data: data, scale: 2)
    }
    
}
