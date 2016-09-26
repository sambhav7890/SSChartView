//
//  GraphView.swift
//  Graphs
//
//  Created by Sambhav Shah on 2016/09/02.
//  Copyright © 2016 S. All rights reserved.
//

import UIKit

open class GraphView<T: Hashable, U: NumericType>: UIView {
    
    open var graph: Graph<T, U>? {
        didSet {
            self.reloadData()
        }
    }
    
    fileprivate var barGraphConfig: BarGraphViewConfig?

	public init(frame: CGRect, graph: Graph<T, U>? = nil) {
        self.graph = graph
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.reloadData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.reloadData()
    }
    
    func reloadData() {
        
        self.subviews.forEach { $0.removeFromSuperview() }
        
        guard let graph = self.graph else { return }
        
        switch graph.kind {
        case .bar(let g):
            
            if let view = g.view(self.bounds) {
                if let c = barGraphConfig {
                    view.setBarGraphViewConfig(c)
                }
                self.addSubview(view)
            }
		}
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.subviews.forEach{
            $0.frame = self.bounds
        }
    }
}

extension GraphView {
    
    public func barGraphConfiguration(_ configuration: () -> BarGraphViewConfig) -> Self {
        self.barGraphConfig = configuration()
        self.subviews.forEach { (v) in
            if let barGraphView = v as? BarGraphView<T, U> {
                barGraphView.setBarGraphViewConfig(barGraphConfig)
            }
        }
        return self
    }
}

extension UIScrollView {
    
    func insetBounds() -> CGRect {
        
        return CGRect(
            x: self.bounds.origin.x + self.contentInset.left,
            y: self.bounds.origin.y + self.contentInset.top,
            width: self.bounds.size.width - self.contentInset.left - self.contentInset.right,
            height: self.bounds.size.height - self.contentInset.top - self.contentInset.bottom
        )
    }
}

