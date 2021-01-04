//
//  ADDrawCurveDotButton.h
//  AngelDoctor
//
//  Created by dsq on 2020/12/29.
//  Copyright © 2020 JUMPER_IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADDrawCurveDotButton : UIButton

/// 按钮所在的组
@property(nonatomic, assign)NSInteger section;

/// 按钮所在的角标
@property(nonatomic, assign)NSInteger row;

@end

NS_ASSUME_NONNULL_END
