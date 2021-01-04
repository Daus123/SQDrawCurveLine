//
//  ADDrawCurveView.h
//  AngelDoctor
//
//  Created by dsq on 2020/6/12.
//  Copyright © 2020 JUMPER_IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
///*********************** 需改进,还未完成,等有时间再写 ******************8/


@class ADDrawCurveView;
@protocol ADDrawCurveViewDataSource <NSObject>

@required



///获取每组的数据源CGPoint
- (NSArray *)drawCurve:(ADDrawCurveView *)view dotArrayInSection:(NSInteger)section;

/// 设置x轴显示的值
- (NSArray *)xTitleArrayInDrawCurve:(ADDrawCurveView *)view;


@optional

///获取共有多少组，默认1组
- (NSInteger)numberOfSectionsInDrawCurve:(ADDrawCurveView *)view;

///每个点的颜色
- (UIColor *)drawCurve:(ADDrawCurveView *)view lineDotColorWithIndex:(NSInteger)index;

/// 设置右边的纵坐标的文字 , 通过所在位置
- (NSString *)drawCurve:(ADDrawCurveView *)view setRightYTitleWithIndex:(NSInteger)index;

/// 每条线的颜色
- (UIColor *)drawCurve:(ADDrawCurveView *)view lineColorInSection:(NSInteger)section;

/// y轴的范围，如[0,7]
- (NSArray *)yValueLimitsDrawCurve:(ADDrawCurveView *)view;

/// 是否能够点击对应的点
- (BOOL)isEnableDotWithDrawCurveSections:(NSInteger)section;

@end

@protocol ADDrawCurveViewDelegate <NSObject>

@optional
/// 提供点击需要展示的view
- (UIView *)drawCurveTapShowView:(ADDrawCurveView *)view;

/// 点击点的事件
- (void)drawCurve:(ADDrawCurveView *)view didDotViewInIndexPath:(NSIndexPath *)indexPath;

/// 点击展示图事件
- (void)drawCurve:(ADDrawCurveView *)view didShowViewInIndexPath:(NSIndexPath *)indexPath;;

@end

@interface ADDrawCurveView : UIView


/** 展示的数据数组 */
@property (nonatomic, strong) NSArray *dataArray;
/** 设置y轴的最大值，最大的y轴坐标默认大小7 */
@property (nonatomic, assign) int maxYValue;
/** 设置y轴的最小值，默认大小2 */
@property (nonatomic, assign) int minYValue;
//限制的范围
@property(nonatomic, assign)CGFloat limitMin;

@property(nonatomic, assign)CGFloat limitMax;
/// 是否自动的计算y轴的范围
@property(nonatomic, assign)BOOL isAutoYValue;
/// 是否显示连接点
@property(nonatomic, assign)BOOL isShowDot;

@property (weak, nonatomic) id<ADDrawCurveViewDataSource> dataSource;

@property (weak, nonatomic) id<ADDrawCurveViewDelegate> delegate;

/// y轴的间隔数，默认8
@property(assign, nonatomic)int ySpaceCount;
/// 显示的x轴的数量，默认7
@property(assign, nonatomic)int visualCount;
/// 提示单位
@property(copy, nonatomic)NSString *unitStr;
/// x轴的提示问题
@property(copy, nonatomic)NSString *xAisTips;

@property (nonatomic, strong) UIView *showView; //点击原点展示的文本框,(子类中重绘)

/// 是否自动的计算y轴的范围
- (instancetype)initWithframe:(CGRect)frame IsAutoYValue:(BOOL)isAuto;
/** 设置范围虚线 */
- (void)setLimitMin:(CGFloat)min max:(CGFloat)max;
/// 刷新
- (void)reloadCurveView;



@end

NS_ASSUME_NONNULL_END
