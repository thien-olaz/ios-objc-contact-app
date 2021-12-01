//
//  ContactViewModel.h
//  zalo-contact
//
//  Created by Thiện on 01/12/2021.
//

@import Foundation;
#import "ContactsLoader.h"
#import "CellObject.h"
#import "ContactTableViewAction.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^BindDataBlock)(void);

@protocol TableViewActionDelegate

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;

@end

@interface ContactViewModel : NSObject

@property (nonatomic, copy) BindDataBlock dataBlock;
@property NSMutableArray *data;

- (instancetype)initWithDelegate:(id<TableViewActionDelegate>)delegate;
- (void)setDataBlock:(BindDataBlock)dataBlock;

@end

NS_ASSUME_NONNULL_END
