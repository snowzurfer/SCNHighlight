//
//  SCNNode+Extensions.swift
//  SCNHighlight
//
//  Created by Alberto Taiuti on 08/06/2019.
//  Copyright © 2019 Alberto Taiuti. All rights reserved.
//

import SceneKit

extension SCNNode {
  func setCategoryBitMaskForAllHierarchy(_ highlightedBitMask: Int = 2,
                                         nodesToExclude: Set<String> = Set<String>()) {
    if let selfName = name {
      if !nodesToExclude.contains(selfName) {
        categoryBitMask = highlightedBitMask
      }
    }
    else {
      categoryBitMask = highlightedBitMask
    }
    
    for child in self.childNodes {
      child.setCategoryBitMaskForAllHierarchy(highlightedBitMask,
                                              nodesToExclude: nodesToExclude)
    }
  }
}
