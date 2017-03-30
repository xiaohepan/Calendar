//
//  FlowLayout.swift
//  seasonview
//
//  Created by panxiaohe on 16/4/12.
//  Copyright © 2016年 panxiaohe. All rights reserved.
//

import UIKit

class CalendarLayout: UICollectionViewFlowLayout {

    
    override func prepare() {
            super.prepare()
            self.setupLayout()
        }
        
        func setupLayout(){
            //设置cell的大小
            self.minimumLineSpacing = 8
            
            self.minimumInteritemSpacing = 0
            
            let width = self.collectionView!.bounds.width
            
            let cellSize = round(( width - 6 * self.minimumLineSpacing)/7)
            
            let offset = (width - cellSize * 7)
            
            let leftoffset = round(offset / 2)
        
            self.collectionView?.contentInset.left = leftoffset
            self.collectionView?.contentInset.right = offset - leftoffset
            self.itemSize = CGSize(width: cellSize,height: cellSize)
        }
    
}
