//
//  GrayFooterCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "GrayFooterCell.h"

@implementation GrayFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor: UIColor.systemBackgroundColor];
    return self;
}

@end
