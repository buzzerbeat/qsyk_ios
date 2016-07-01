//
//  QSYKDropMenuTableSectionHeaderView.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/30/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSYKDropMenuTableSectionHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separotorHeightCons;

@end
