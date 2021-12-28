//
//  TabCell.h
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

@import Foundation;
@import UIKit;
#import "CellObject.h"
#import "CommonCellObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabCell : UITableViewCell<ZaloCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

NS_ASSUME_NONNULL_END
