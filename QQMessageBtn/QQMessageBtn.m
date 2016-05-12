//
//  QQMessageBtn.m
//  QQMessageBtn
//
//  Created by Mime97 on 16/5/11.
//  Copyright © 2016年 Mime. All rights reserved.
//
#define KBTNWIDTH self.bounds.size.width
#define KBTNHEIGHT self.bounds.size.height
#import "QQMessageBtn.h"
@interface QQMessageBtn ()
@property (nonatomic, assign)CGFloat maxDistance;
@property (nonatomic, strong)UIView *smallCircle;
@property (nonatomic, strong)NSMutableArray *bombImages;
@property (nonatomic, strong)CAShapeLayer *shapeLayer;
@end
@implementation QQMessageBtn
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
- (NSMutableArray *)bombImages
{
    if (!_bombImages) {
        _bombImages = [[NSMutableArray alloc]init];
        for (int i =1 ; i < 9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
            [_bombImages addObject:image];
        }
    }
    return _bombImages;
}
- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    return _shapeLayer;
}
- (UIView *)smallCircle
{
    if (!_smallCircle) {
        _smallCircle = [[UIView alloc]init];
        _smallCircle.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:_smallCircle belowSubview:self];
    }
    return _smallCircle;
}
- (void)setUp
{
    CGFloat cornerRadius = (KBTNHEIGHT > KBTNWIDTH ? KBTNWIDTH/2.0:KBTNHEIGHT/2.0);
    _maxDistance = cornerRadius *4;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    CGRect smallCricle = CGRectMake(0, 0, cornerRadius*(2 - 0.5), cornerRadius*(2 - 0.5));
    self.smallCircle.bounds = smallCricle;
    _smallCircle.center = self.center;
    _smallCircle.layer.cornerRadius = _smallCircle.bounds.size.width/2;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    [self addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
}
#pragma mark - 添加手势
- (void)pan:(UIPanGestureRecognizer *)pan
{
    [self.layer removeAnimationForKey:@"shake"];
    CGPoint panPoint = [pan translationInView:self];
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    [pan setTranslation:CGPointZero inView:self];
    
    //两个圆中心点之间的距离
    CGFloat distance = [self pointToPointDistanceWithPoint:self.center pointB:self.smallCircle.center];
    if (distance < _maxDistance) {
        CGFloat cornerRadius = (KBTNHEIGHT > KBTNWIDTH ? KBTNWIDTH/2.0 : KBTNHEIGHT/2.0);
        CGFloat smallCircleRadius = cornerRadius - distance/10;
        _smallCircle.bounds = CGRectMake(0, 0, smallCircleRadius*1.5, smallCircleRadius*1.5);
        _smallCircle.layer.cornerRadius = _smallCircle.bounds.size.width/2;
        if (_smallCircle.hidden == NO && distance > 0) {
            //绘制不规则矩形
            self.shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:self.smallCircle].CGPath;
        }
    }
    else
        {
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            self.smallCircle.hidden = YES;
        }
        if (pan.state == UIGestureRecognizerStateEnded) {
            if (distance > _maxDistance) {
                [self startDestoryAnimations];
                [self killAll];
            }
            else
            {
                [self.shapeLayer removeFromSuperlayer];
                self.shapeLayer = nil;
                
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.center = self.smallCircle.center;
                } completion:^(BOOL finished) {
                    self.smallCircle.hidden = NO;
                }];
        }
    }
    
}
- (void)clickBtn
{
    [self startDestoryAnimations];
    [self killAll];
}
#pragma mark - 两个圆心之间的距离
- (CGFloat)pointToPointDistanceWithPoint:(CGPoint)pointA pointB:(CGPoint)pointB
{
    CGFloat offsetX = pointA.x - pointB.x;
    CGFloat offsetY = pointA.y - pointB.y;
    CGFloat distance = sqrtf(offsetX * offsetX + offsetY * offsetY);
    return distance;
}
#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCircleView:(UIView *)bigCircleView smallCircleView:(UIView *)smallCircleView
{
    CGPoint bigCenter = bigCircleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCircleView.bounds.size.width/2;
    
    CGPoint smallCenter = smallCircleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCircleView.bounds.size.width/2;
    //获取圆心的距离
    CGFloat d = [self pointToPointDistanceWithPoint:_smallCircle.center pointB:self.center];
    CGFloat sinΘ = (x2 - x1) / d;
    CGFloat cosΘ = (y2 - y1) / d;
    //坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1*cosΘ, y1 + r1*sinΘ);
    CGPoint pointB = CGPointMake(x1 + r1*cosΘ, y1 - r1*sinΘ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosΘ , y2 - r2 * sinΘ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosΘ , y2 + r2 * sinΘ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinΘ , pointA.y + d / 2 * cosΘ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinΘ , pointB.y + d / 2 * cosΘ);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //A
    [path moveToPoint:pointA];
    //AB
    [path addLineToPoint:pointB];
    //BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    //CD
    [path addLineToPoint:pointD];
    //DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}
- (void)killAll
{
    [self removeFromSuperview];
    [self.smallCircle removeFromSuperview];
    self.smallCircle = nil;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}
#pragma mark - button 消失动画
- (void)startDestoryAnimations
{
    UIImageView *animationImageView = [[UIImageView alloc]initWithFrame:self.frame];
    animationImageView.animationImages = self.bombImages;
    animationImageView.animationRepeatCount = 1;
    animationImageView.animationDuration = 0.5;
    [animationImageView startAnimating];
    [self.superview addSubview:animationImageView];
}
#pragma mark - 设置长按时左右摇摆动画
- (void)setHighlighted:(BOOL)highlighted
{
    [self.layer removeAnimationForKey:@"shake"];
    //长按左右晃动幅度
    CGFloat shake = 10;
    CAKeyframeAnimation *keyAnima = [CAKeyframeAnimation animation];
    keyAnima.keyPath = @"transform.translation.x";
    keyAnima.values = @[@(-shake),@(shake),@(-shake)];
    keyAnima.removedOnCompletion = NO;
    keyAnima.repeatCount = MAXFLOAT;
    keyAnima.duration = 0.3f;
    [self.layer addAnimation:keyAnima forKey:@"shake"];
}
@end
