//
//  IEPanningBackgroundView.m
//
//  Created by Eric Dufresne on 2016-05-12.
//  Copyright © 2016 Eric Dufresne. Free or public use under the MIT license with this repository
//

#import "IEPanningBackgroundView.h"

@interface IEPanningBackgroundView (){
    NSTimer *panTimer;
}
@property (assign, nonatomic) NSInteger imageIndex;
@property (assign, nonatomic) CGRect initialBackgroundSize;
@property (strong, nonatomic) UIView *transitionView;
@property (strong, nonatomic) UIView *overlayView;
@end

@implementation IEPanningBackgroundView
@synthesize stockImages, style, overlayAlpha;
-(id)initWithImages:(NSArray<UIImage*>*)images background:(CGRect)background{
    self.imageIndex = arc4random()%images.count;
    if (self = [super initWithImage:images[self.imageIndex]]){
        stockImages = images;
        self.initialBackgroundSize = background;
        self.style = IEPanningBackgroundStyleDark;
        self.panningTime = 40.0;
        self.transitionTime = 2.0;
        self.overlayAlpha = 0;
        
        CGFloat resizeFactor = self.frame.size.height/background.size.height;
        self.frame = CGRectMake(background.origin.x, background.origin.y, self.frame.size.width/resizeFactor, self.frame.size.height/resizeFactor);
        
        self.transitionView = [[UIView alloc] initWithFrame:background];
        self.transitionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [self addSubview:self.transitionView];
        
        self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(background.origin.x, background.origin.y, self.frame.size.width, background.size.height)];
        self.overlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.overlayView];
    }
    return self;
}
-(id)initWithImageNames:(NSArray<NSString*>*)imageNames background:(CGRect)background{
    NSMutableArray *imageViews = [NSMutableArray array];
    for (NSString *string in imageNames){
        UIImage *image = [UIImage imageNamed:string];
        [imageViews addObject:image];
    }
    self.imageIndex = arc4random()%imageViews.count;
    if (self = [super initWithImage:imageViews[self.imageIndex]]){
        stockImages = imageViews;
        self.initialBackgroundSize = background;
        self.style = IEPanningBackgroundStyleDark;
        self.panningTime = 40.0;
        self.transitionTime = 2.0;
        self.overlayAlpha = 0;
        
        CGFloat resizeFactor = self.frame.size.height/background.size.height;
        self.frame = CGRectMake(background.origin.x, background.origin.y, self.frame.size.width/resizeFactor, self.frame.size.height/resizeFactor);
        
        self.transitionView = [[UIView alloc] initWithFrame:background];
        self.transitionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [self addSubview:self.transitionView];
        
        self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(background.origin.x, background.origin.y, self.frame.size.width, background.size.height)];
        self.overlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.overlayView];
    }
    return self;
}
+(instancetype)viewWithImages:(NSArray<UIImage*>*)images background:(CGRect)background{
    return [[self alloc] initWithImages:images background:background];
}
+(instancetype)viewWithImageNames:(NSArray<NSString*>*)imageNames background:(CGRect)background{
    return [[self alloc] initWithImageNames:imageNames background:background];
}
-(void)startPanning{
    if (self.delegate && [self.delegate respondsToSelector:@selector(panningBackgroundView:didStartPanningImage:)])
        [self.delegate panningBackgroundView:self didStartPanningImage:self.image];
    
    [UIView beginAnimations:@"panningAnimation" context:NULL];
    [UIView setAnimationDuration:self.panningTime];
    self.frame = CGRectMake(-self.frame.size.width+self.initialBackgroundSize.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    panTimer = [NSTimer scheduledTimerWithTimeInterval:self.panningTime target:self selector:@selector(reset) userInfo:nil repeats:NO];
}
//TODO: Needs work because animation is skipping to end. Need to pause animation
-(void)stopPanningImmedietly{
    [panTimer invalidate];
    [self.layer removeAllAnimations];
    panTimer = nil;
}
-(void)stopPanning{
    [panTimer invalidate];
    panTimer = nil;
}
#pragma mark - Private Methods
-(void)reset{
    if (self.delegate && [self.delegate respondsToSelector:@selector(panningBackgroundView:didFinishPanningImage:)])
        [self.delegate panningBackgroundView:self didFinishPanningImage:self.image];
    [UIView beginAnimations:@"transition-in" context:NULL];
    [UIView setAnimationDuration:self.transitionTime/2];
    if (self.style == IEPanningBackgroundStyleDark)
        self.transitionView.backgroundColor = [UIColor blackColor];
    else
        self.transitionView.backgroundColor = [UIColor whiteColor];
    [UIView commitAnimations];
    [UIView beginAnimations:@"transition-out" context:NULL];
    [UIView setAnimationDuration:self.transitionTime/2];
    [UIView setAnimationDelay:self.transitionTime/2];
    self.transitionView.backgroundColor = [UIColor clearColor];
    [UIView commitAnimations];
    
    panTimer = [NSTimer scheduledTimerWithTimeInterval:self.transitionTime/2 target:self selector:@selector(changeImages) userInfo:nil repeats:NO];
}
-(void)changeImages{
    self.imageIndex++;
    if (self.imageIndex >= self.stockImages.count)
        self.imageIndex = 0;
    
    self.image = self.stockImages[self.imageIndex];
    CGFloat resizeFactor = self.image.size.height/self.initialBackgroundSize.size.height;
    self.frame = CGRectMake(self.initialBackgroundSize.origin.x, self.initialBackgroundSize.origin.y, self.image.size.width/resizeFactor, self.image.size.height/resizeFactor);
    self.overlayView.frame = self.frame;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(panningBackgroundView:didStartPanningImage:)])
        [self.delegate panningBackgroundView:self didStartPanningImage:self.image];
    
    [UIView beginAnimations:@"panningAnimation" context:NULL];
    [UIView setAnimationDuration:self.panningTime];
    self.frame = CGRectMake(-self.frame.size.width+self.initialBackgroundSize.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    panTimer = [NSTimer scheduledTimerWithTimeInterval:self.panningTime-self.transitionTime/2 target:self selector:@selector(reset) userInfo:nil repeats:NO];
}
#pragma mark - Setter overrides
-(void)setStyle:(IEPanningBackgroundStyle)newStyle{
    self->style = newStyle;
    if (self.transitionView){
        if (self.style == IEPanningBackgroundStyleDark)
            self.overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.overlayAlpha];
        else
            self.overlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:self.overlayAlpha];
    }
}
-(void)setOverlayAlpha:(CGFloat)newOverlayAlpha{
    self->overlayAlpha = newOverlayAlpha;
    if (self.transitionView){
        if (self.style == IEPanningBackgroundStyleDark)
            self.overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:newOverlayAlpha];
        else
            self.overlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:newOverlayAlpha];
    }
}

@end
