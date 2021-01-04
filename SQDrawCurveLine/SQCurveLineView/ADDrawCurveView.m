//
//  ADDrawCurveView.m
//  AngelDoctor
//
//  Created by dsq on 2020/6/12.
//  Copyright © 2020 JUMPER_IOS. All rights reserved.
//

#import "ADDrawCurveView.h"
#import "UIButton+EnlargeEdge.h"
#import "ADDrawCurveDotButton.h"


#define kBounceXRight 5
#define kBounceXLeft  28

//距离上方的距离
#define KPaddingTop 12
//距离下方的距离
#define KPaddingBottom  38

#define kLabelColor RGB(153, 153, 153)

#define kDrawLineColor RGB(201, 201, 201)
//y轴坐标的宽
static CGFloat yLabelWidth = 25;
//
//static CGFloat xLabelWidth = 40;
//x轴上刻度的高度
static CGFloat kCutHeight = 0;
//y轴上高出最高坐标的高度
static CGFloat kYMaxHeight = 8;
//x轴左边高出的宽度
static CGFloat kXMoreWidth = 8;


@interface ADDrawCurveView ()<UIScrollViewDelegate>

/** 一个刻度的宽度 */
@property (nonatomic, assign) CGFloat widthAxis;
/** 添加的绘画子类, 刷新的时候使用 */
@property (nonatomic, strong)NSMutableArray *addSubViewArray;
/** 添加的绘画layer子类,刷新的时候使用 */
@property (nonatomic, strong)NSMutableArray *addSubLayerArray;

@property (nonatomic, strong)UIScrollView *scrollView;


@property (assign, nonatomic) int didShowIndex; //点击展示的索引
/** x轴刻度的个数 */
@property (nonatomic, assign)int count;

@property(nonatomic, strong) UILabel *unitLabel; //单位

@property(nonatomic, strong) UILabel *xAisTipsLabel; //单位

@property(nonatomic, strong)ADDrawCurveDotButton *currentDotButton; //当前点击的原点


@end

@implementation ADDrawCurveView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupView];
        
    }
    return self;
}

- (instancetype)initWithframe:(CGRect)frame IsAutoYValue:(BOOL)isAuto
{
    if (self = [self initWithFrame:frame]) {
        self.isAutoYValue = isAuto;
    }
    return self;
}

- (void)setupView
{
     self.backgroundColor = [UIColor whiteColor];
     self.scrollView = [[UIScrollView alloc]init];
     self.scrollView.showsVerticalScrollIndicator   = NO;
     self.scrollView.showsHorizontalScrollIndicator = NO;
     self.scrollView.bounces = NO;
     self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(kBounceXLeft, 0, self.frame.size.width - kBounceXLeft - kBounceXRight, self.frame.size.height);

    self.unitLabel = [UILabel labelWith:@"" font:11 textColor:RGB(153, 153, 153)];
    [self addSubview:self.unitLabel];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.equalTo(self);
    }];
    
    self.xAisTipsLabel = [UILabel labelWith:@"" font:11 textColor:RGB(153, 153, 153)];
    [self addSubview:self.xAisTipsLabel];
    [self.xAisTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-kBounceXRight - 10);
        make.bottom.equalTo(self);
    }];

    
    self.addSubViewArray = [NSMutableArray array];
    self.addSubLayerArray = [NSMutableArray array];
    //默认展示7个刻度
    self.count = 7;
    
//    self.showView = [[ADSugarDrawShowTextView alloc]init];
//    if ([self.delegate respondsToSelector:@selector(drawCurveTapShowView:)]) {
//        self.showView = [self.delegate drawCurveTapShowView:self];
//        UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickDetail:)];
//        [self.showView addGestureRecognizer:aTap];
//        [self addSubview:self.showView];
//    }
    
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickBgView)];
    [self addGestureRecognizer:bgTap];
    
}

//- (void)drawRect:(CGRect)rect
//{
//    //创建x轴label
//    [self createLabelX];
//    
//    [self createLabelY];
//    //画点
//    [self drawLine];
//    //虚线
//    [self addBackgroundLimitMin:self.limitMin max:self.limitMax];
//}

- (void)createLabelXYLine
{
    //创建x轴label
    [self createLabelX];
    
    [self createLabelY];
    //画点
    [self drawLine];
    //虚线
    [self addBackgroundLimitMin:self.limitMin max:self.limitMax];
}

- (void)createLabelX
{
    
    //图表的x轴所在的y坐标
    CGFloat curveMaxY = self.frame.size.height - KPaddingBottom - kCutHeight;
    //label的高度
    CGFloat heightLabel = 10;
    //label的宽度
    CGFloat widthLabel = self.widthAxis;
    
    
    NSArray *dataArray = [self.dataSource xTitleArrayInDrawCurve:self];
    for (int i = 0; i < dataArray.count; i++) {
        UILabel *label = [[UILabel alloc]init];
        CGFloat x =  widthLabel * i  ;
        label.frame = CGRectMake(x , self.frame.size.height - KPaddingBottom + 5, widthLabel , heightLabel);
    
        NSString *xAsixString = dataArray[i];
        
        label.text = xAsixString;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000 + i ;
        label.textColor = kLabelColor;
        label.font = [UIFont systemFontOfSize:11];
        label.numberOfLines = 0;
        [self.scrollView addSubview:label];
        [self.addSubViewArray addObject:label];
        
        CAShapeLayer *dashLayer = [CAShapeLayer layer];
        dashLayer.strokeColor = kDrawLineColor.CGColor;
        dashLayer.fillColor = [UIColor clearColor].CGColor;
        dashLayer.lineWidth = 1;
        //纵坐标移动的y轴
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (i == 0) { //设置y轴
            //初始位置
            NSLog(@"x = %f",label.center.x);
            [path moveToPoint:CGPointMake(label.frame.origin.x + kBounceXLeft, curveMaxY + kCutHeight)];
            // 线条到右边的坐标
            [path addLineToPoint:CGPointMake(label.frame.origin.x + kBounceXLeft, KPaddingTop)];
            //            [path stroke];
            dashLayer.path = path.CGPath;
            [self.layer addSublayer:dashLayer];
            [self.addSubLayerArray addObject:dashLayer];
        }
    }
    
}

- (void)createLabelY
{
    //分割线数量
    int yLineCount = self.ySpaceCount - 1;
    //每格相差的平均值
    double average = (double)(self.maxYValue - self.minYValue) / (yLineCount - 1);
    NSMutableArray *yValueArray = [NSMutableArray array];
    for (int i = 0; i < yLineCount; i++) {
        [yValueArray addObject:[NSString stringWithFormat:@"%.1f",self.maxYValue - average * i]];
    }
    
    //x轴最后一个数
    UILabel *xLabel = (UILabel *)[self viewWithTag:1000 + self.count - 1];
    
    CGFloat labelH = 12;
    
    for (int i = 0; i < yValueArray.count; i++) {
        CGFloat pointY = [yValueArray[i] floatValue];
        CGFloat y = [self getContextPointWithNormalPoint:CGPointMake(0, pointY)].y;
        //y轴分割线
        if (i != yValueArray.count - 1) {
            UIView *dashView = [[UIView alloc]init];
            dashView.backgroundColor = RGB(229, 229, 229);
            dashView.frame = CGRectMake(0, y, xLabel.frame.origin.x + xLabel.frame.size.width + kXMoreWidth, 1);
            [self.scrollView addSubview:dashView];
            [self.addSubViewArray addObject:dashView];
        }else{
            //y坐标轴
            CAShapeLayer *dashLayer = [CAShapeLayer layer];
            dashLayer.strokeColor = kDrawLineColor.CGColor;
            dashLayer.fillColor = [UIColor clearColor].CGColor;
            dashLayer.lineWidth = 1;
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            path.lineWidth = 1;
            
            [path moveToPoint:CGPointMake(0, y)];
            // 线条到右边的坐标
            [path addLineToPoint:CGPointMake(xLabel.frame.origin.x + xLabel.frame.size.width + kXMoreWidth, y)];
            
            dashLayer.path = path.CGPath;
            //插入图层最底层，避免遮挡住折线图
            [self.scrollView.layer insertSublayer:dashLayer atIndex:0];
            [self.addSubLayerArray addObject:dashLayer];
        }
        
        CGFloat labelY = y - labelH / 2;
        UILabel *labelYdivsion = [[UILabel alloc]initWithFrame:CGRectMake(0, labelY , yLabelWidth, labelH )];
        labelYdivsion.tag = 2000 + i;
        if (yValueArray.count > i) {
            labelYdivsion.text = [NSString stringWithFormat:@"%@",yValueArray[i]];
        }
        labelYdivsion.font = [UIFont systemFontOfSize:10];
        labelYdivsion.textColor = kLabelColor;
        labelYdivsion.textAlignment = NSTextAlignmentRight;
        labelYdivsion.backgroundColor = [UIColor whiteColor];
        [self addSubview:labelYdivsion];
        [self.addSubViewArray addObject:labelYdivsion];
        
        
        ///设置图表的y轴右边标题，跟左边对应
        if ([self.dataSource respondsToSelector:@selector(drawCurve:setRightYTitleWithIndex:)]) {
            NSString *yRightValye = [self.dataSource drawCurve:self setRightYTitleWithIndex:i];
            CGFloat labelY = y - labelH / 2;
            UILabel *labelYdivsion = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - yLabelWidth - kBounceXRight, labelY , yLabelWidth, labelH )];
            labelYdivsion.text = yRightValye;
            labelYdivsion.font = [UIFont systemFontOfSize:10];
            labelYdivsion.textColor = kLabelColor;
            labelYdivsion.backgroundColor = [UIColor whiteColor];
            [self addSubview:labelYdivsion];
            [self.addSubViewArray addObject:labelYdivsion];
            
        }
    }
}

//通过正常的x，y值转化为绘画需要的坐标
- (CGPoint)getContextPointWithNormalPoint:(CGPoint)point
{
    //一个格子的宽度
    CGFloat widthAxis = self.widthAxis;
    //原点的高度
    CGFloat originHeight = self.frame.size.height - KPaddingTop - KPaddingBottom - kCutHeight - kYMaxHeight;
    //每个数字y轴的高度
    CGFloat originUnitHeight = originHeight / (self.maxYValue - self.minYValue);
    
    NSArray *xArray = [self.dataSource xTitleArrayInDrawCurve:self];
    //x的间隔
    CGFloat spaceX = ([xArray.lastObject floatValue] - [xArray.firstObject floatValue]) / (xArray.count - 1);
    //x的坐标
    CGFloat xPath =  widthAxis  / spaceX * point.x - self.widthAxis / 2;
    CGFloat yPath = originHeight - originUnitHeight * (point.y - self.minYValue) + KPaddingTop + kYMaxHeight;
    return CGPointMake(xPath, yPath);
}

//清空子视图
- (void)removeSubLayer
{
    //清空路径
     for (UIView *view in self.addSubViewArray) {
         [view removeFromSuperview];
     }
     for (CALayer *layer in self.addSubLayerArray) {
         [layer removeFromSuperlayer];
     }
//     [self.bezierPath removeAllPoints];
}

//画线
- (void)drawLine
{
    //默认一组
    NSInteger section = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInDrawCurve:)]) {
        //总共有多少组
        section =  [self.dataSource numberOfSectionsInDrawCurve:self];
    }

    for (int i = 0; i < section; i++) {
        NSArray *dotArr = [self.dataSource drawCurve:self dotArrayInSection:i];
        //绘制
        [self drawShapeLayerWithArray:dotArr section:i];
    }
    
}

//根据点数绘制线
- (void)drawShapeLayerWithArray:(NSArray *)dotArray section:(int)section
{
    
    //判断是否是一个可显示的第一点
    BOOL isFirstPoint = NO;
    
    CGFloat dotWidth  = 6;
    CGFloat dotHeight = 6;
    
    //默认灰色
    UIColor *strokeColor = kDrawLineColor;
    if ([self.dataSource respondsToSelector:@selector(drawCurve:lineColorInSection:)]) {
        strokeColor = [self.dataSource drawCurve:self lineColorInSection:section];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = 1;
    [self.scrollView.layer addSublayer:shapeLayer]; //直接添加导视图上
    [self.addSubLayerArray addObject:shapeLayer];

    //曲线
    UIBezierPath *bezierPath =[[UIBezierPath alloc]init];

    for (int i = 0; i < dotArray.count; i ++) {
        
        CGPoint modelPoint = [dotArray[i] CGPointValue];
        //坐标转化
        CGPoint point = [self getContextPointWithNormalPoint:modelPoint];
        //是否展示连接点
        //圆圈的坐标
        CGFloat dotX = point.x - dotWidth * 0.5 + 1;
        CGFloat dotY = point.y - dotHeight * 0.5;
        ADDrawCurveDotButton *dotView = [self createDotView];
        dotView.section = section;
        dotView.row = i ;
        [self.scrollView addSubview:dotView];
        dotView.frame = CGRectMake(dotX, dotY, dotWidth, dotHeight);
        [self.addSubViewArray addObject:dotView];
        
        if ([self.dataSource respondsToSelector:@selector(isEnableDotWithDrawCurveSections:)]) {
            //连接点是否可点击
           BOOL isEnabelDot = [self.dataSource isEnableDotWithDrawCurveSections:section];
            dotView.userInteractionEnabled = isEnabelDot;
        }
        
        if (modelPoint.y <= 0) {
            dotView.hidden = YES;
            continue;
        }
        //状态
        UIColor *dotColor = [UIColor clearColor];
        if ([self.dataSource respondsToSelector:@selector(drawCurve:lineDotColorWithIndex:)]) {
            dotColor = [self.dataSource drawCurve:self lineDotColorWithIndex:i];
        }
        dotView.backgroundColor = dotColor;

        //创建折现点标记
        if (isFirstPoint == NO) { //如果还未出现第一个点，则从这点开始创建并画起
            [bezierPath moveToPoint:CGPointMake(point.x , point.y)];
            isFirstPoint = YES;
        }else{
            [bezierPath addLineToPoint:CGPointMake(point.x , point.y)];
        }
    }
    //绘制
    shapeLayer.path = bezierPath.CGPath;
}

//私有方法，在重绘的时候添加范围
- (void)addBackgroundLimitMin:(CGFloat)min max:(CGFloat)max
{
    if (min == 0 && max == 0) {
        return;
    }
    //y轴最小值
    CGFloat minY = [self getContextPointWithNormalPoint:CGPointMake(0, min)].y;
    //y轴最大值
    CGFloat maxY = [self getContextPointWithNormalPoint:CGPointMake(0, max)].y;
    
    //绘画矩形
    
    //x轴最后一个数
    UILabel *xLabel = (UILabel *)[self viewWithTag:1000 + self.count - 1];
    
    CGFloat w = xLabel.frame.origin.x + xLabel.frame.size.width + kXMoreWidth;
    //虚线
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, minY,  w, 1)];
    CAShapeLayer *subDashLayer = [CAShapeLayer layer];
    subDashLayer.fillColor = RGB(255, 205, 103).CGColor;
    subDashLayer.lineWidth = 1;
    subDashLayer.path = path.CGPath;
    subDashLayer.lineDashPattern = @[@4,@4];
//    [self.scrollView.layer insertSublayer:subDashLayer atIndex:0];
    //加在最上层
    [self.scrollView.layer addSublayer:subDashLayer];
    [self.addSubLayerArray addObject:subDashLayer];
    
    //高点虚线
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(0, maxY,  w, 1)];
    CAShapeLayer *subDashLayer1 = [CAShapeLayer layer];
    subDashLayer1.fillColor = RGB(252, 82, 77).CGColor;
    subDashLayer1.lineWidth = 1;
    subDashLayer1.path = path1.CGPath;
    subDashLayer1.lineDashPattern = @[@4,@4];
//    [self.scrollView.layer insertSublayer:subDashLayer1 atIndex:0];
    //加在最上层
    [self.scrollView.layer addSublayer:subDashLayer1];
    [self.addSubLayerArray addObject:subDashLayer1];
    
}

#pragma mark - 共有方法

/// 刷新
- (void)reloadCurveView
{
    //隐藏表格
    [self onClickBgView];
    
    //如果是自动的
    if (self.isAutoYValue || ![self.dataSource respondsToSelector:@selector(yValueLimitsDrawCurve:)]) {
        
        //计算最大值和最小值
        //默认一组
        NSInteger section = 1;
        if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInDrawCurve:)]) {
            //总共有多少组
            section =  [self.dataSource numberOfSectionsInDrawCurve:self];
        }
        
        for (int i = 0; i < section; i++) {
            NSArray *dotArray =  [self.dataSource drawCurve:self dotArrayInSection:i];
            
            //计算每个点的最大值和最小值
            for (int i = 0; i < dotArray.count; i++) {
                CGPoint dotPoint = [dotArray[i] CGPointValue];
                CGFloat dotY = dotPoint.y;
                if (self.maxYValue < ceil(dotY)) {
                    self.maxYValue = dotY;
                }
                if (self.minYValue > floor(dotY)) {
                    self.minYValue = dotY;
                }
                
            }
        }
        
    }else if([self.dataSource respondsToSelector:@selector(yValueLimitsDrawCurve:)]){
        //存在设置的y轴范围
        //取出y轴的的范围
        NSArray *limitArr = [self.dataSource yValueLimitsDrawCurve:self];
        
        //返回的数组不是2个
        if (limitArr.count < 2) {
            self.maxYValue = 0;
            self.minYValue = 0;
        }
        self.maxYValue = [limitArr[1] intValue];
        self.minYValue = [limitArr[0] intValue];
    }else{
        //不是自动的，且没有设置y轴范围，则使用默认
        self.maxYValue = 0;
        self.minYValue = 0;
    }
        
    //滚动到对应位置
    //默认取出一组数据
    NSArray *dataArray = [self.dataSource xTitleArrayInDrawCurve:self];
    
    
    CGFloat contentW = self.widthAxis * dataArray.count;
    self.scrollView.contentSize = CGSizeMake(contentW + kXMoreWidth, 0);
    if (dataArray.count > self.visualCount) {
         //滚动到最后
         [self.scrollView setContentOffset:CGPointMake(contentW - self.scrollView.frame.size.width + kXMoreWidth, 0) animated:NO];
     }else{
         [self.scrollView setContentOffset:CGPointZero animated:NO];
     }
    //清空子视图
    [self removeSubLayer];

    self.count = (int)dataArray.count;
    //重绘
//    [self setNeedsDisplay];
    [self createLabelXYLine];
}



#pragma mark - 事件

- (void)onClickBgView
{
//    self.showView.hidden = YES;
//    self.showView.frame = CGRectZero;
    
    [self.showView removeFromSuperview];
}

////点击圆点
- (void)onClickDotView:(ADDrawCurveDotButton *)btn
{
    self.currentDotButton = btn;
    
//    self.didShowIndex = (int)btn.tag;

    if ([self.delegate respondsToSelector:@selector(drawCurveTapShowView:)]) {
        
        [self.showView removeFromSuperview];
        
        self.showView = [self.delegate drawCurveTapShowView:self];
        UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickDetail:)];
        [self.showView addGestureRecognizer:aTap];
        [self addSubview:self.showView];
    }
    
    if ([self.delegate respondsToSelector:@selector(drawCurve:didDotViewInIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.row inSection:btn.section];
        [self.delegate drawCurve:self didDotViewInIndexPath:indexPath];
    }
    
    

    CGRect showViewRect = self.showView.frame;
//    CGFloat width  = 90;
//    CGFloat height = 50;
    CGFloat width = showViewRect.size.width;
    CGFloat height = showViewRect.size.height;
    CGFloat x      = btn.center.x - self.scrollView.contentOffset.x - 20;
    //处理在边角位置
    if (x + width >= kScreenWidth) {
        x = kScreenWidth - width - 20;
    }
    CGFloat y      = btn.frame.origin.y - height - 10;
    self.showView.frame = CGRectMake(x, y, width, height);
    //带到最上层
    [self bringSubviewToFront:self.showView];
    self.showView.hidden = NO;
}
//
- (void)onClickDetail:(UITapGestureRecognizer *)aTap
{
    DLog(@"%d",aTap.view.tag);

    [self onClickBgView];
    
    if ([self.delegate respondsToSelector:@selector(drawCurve:didShowViewInIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentDotButton.row inSection:self.currentDotButton.section];
        [self.delegate drawCurve:self didShowViewInIndexPath:indexPath];
    }
}

//创建点
- (ADDrawCurveDotButton *)createDotView
{
    ADDrawCurveDotButton *dotView = [[ADDrawCurveDotButton alloc]init];
    [dotView setEnlargeEdge:5];
    dotView.backgroundColor = RGB(250, 77, 147);
    dotView.layer.cornerRadius = 3;
    dotView.userInteractionEnabled = YES;
    [dotView addTarget:self action:@selector(onClickDotView:) forControlEvents:UIControlEventTouchUpInside];
    return dotView;
}




#pragma mark - setter
- (void)setUnitStr:(NSString *)unitStr
{
    _unitStr = unitStr;
    
    self.unitLabel.text = unitStr;
}

- (void)setXAisTips:(NSString *)xAisTips
{
    _xAisTips = xAisTips;
    
    self.xAisTipsLabel.text = xAisTips;
}

#pragma mark - getter
- (CGFloat)widthAxis
{
    if (!_widthAxis) {
        _widthAxis = (self.frame.size.width - kBounceXRight - kBounceXLeft - kXMoreWidth) / self.visualCount;
    }
    return _widthAxis;
}


- (int)maxYValue
{
    if (!_maxYValue) {
        _maxYValue = 7;
    }
    return _maxYValue;
}

- (int)minYValue
{
    if (!_minYValue) {
        _minYValue = 0;
    }
    return _minYValue;
}

- (int)visualCount
{
    if (!_visualCount) {
        _visualCount = 7;
    }
    return _visualCount;
}


- (int)ySpaceCount
{
    if (!_ySpaceCount) {
        _ySpaceCount = 8;
    }
    return _ySpaceCount;
}



@end
