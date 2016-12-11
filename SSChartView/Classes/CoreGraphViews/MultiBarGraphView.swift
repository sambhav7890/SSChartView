//
//  MultiBarGraphView.swift
//  Graphs
//
//  Created by Sambhav Shah on 2016/12/12.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

class MultiBarGraphView<T: Hashable, U: NumericType>: UIView {
    
    fileprivate var scrollView: UIScrollView!
    
    fileprivate var graph: MultiBarGraph<T, U>?
    fileprivate var config: MultiBarGraphViewConfig<U>
    
    init(frame: CGRect, graph: MultiBarGraph<T, U>?, viewConfig: MultiBarGraphViewConfig<U>? = nil) {
        
        self.config = viewConfig ?? MultiBarGraphViewConfig<U>()
        super.init(frame: frame)
        self.graph = graph
        self.scrollView = UIScrollView(
            frame: CGRect(x: 20.0, y: 0.0, width: self.bounds.width - 20.0, height: self.bounds.height - 20.0)
        )
        self.addSubview(self.scrollView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct MultiBarGraphViewConfig<T: NumericType> {
    
    let barColors: [UIColor]
    let barWidthScale: CGFloat
    var sectionWidth: CGFloat?
    
    init(
        barColors: [UIColor]? = nil,
        barWidthScale: CGFloat? = nil,
        sectionWidth: CGFloat? = nil
        ) {
        self.barColors = barColors ?? [DefaultColorType.bar.color()]
        self.barWidthScale = barWidthScale ?? 0.8
        self.sectionWidth = sectionWidth
    }
}
