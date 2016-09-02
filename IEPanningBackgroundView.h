//
//  IEPanningBackgroundView.h
//
//  Created by Eric Dufresne on 2016-05-12.
//  Copyright © 2016 Eric Dufresne. Free for public use under the MIT license with this repository
//

#import <UIKit/UIKit.h>

@protocol IEPanningBackgroundViewDelegate;

@interface IEPanningBackgroundView : UIImageView

typedef enum : NSUInteger{
    IEPanningBackgroundStyleLight,
    IEPanningBackgroundStyleDark
} IEPanningBackgroundStyle;

/*
 Sets the amount of brightness/darkness (depending on the style) that is overlayed on all the pictures You can use this if you want to add constrast between your text and your background images or if it is hard to see text because of the brightness/darkness of your images.
 */
@property (assign, nonatomic) CGFloat overlayAlpha; // Defaults to 0. Can be between 0 - 1

/*
 Time in seconds that it takes for an image to pan from left to right. After this duration the image is switched. Note: any value close to 10.0 starts to animate too fast for the default transition time.
 */
@property (assign, nonatomic) CGFloat panningTime; // Defaults to 40.0 seconds

/*
 Time in seconds that it takes between images to fade in and fade out.
 */
@property (assign, nonatomic) CGFloat transitionTime; //Defaults to 2.0 seconds

/*
 This determines the color of the transition while changing images as well as whether the overlay adds brightness or darkness if the overlayAlpha != 0. Light would make the transition white and add brightness while the Dark would make the transition black and add darkness.
 */
@property (assign, nonatomic) IEPanningBackgroundStyle style; //Defaults to Dark

/*
 Images that the background view will pan through. Starts at a random index and then goes sequentially.
 */
@property (readonly, nonatomic) NSArray *stockImages;

/*
 Optional delegate to use. See delgate methods below for more info. Defaults to nil.
 */
@property (weak, nonatomic) id<IEPanningBackgroundViewDelegate> delegate;

//Init methods
-(id)initWithImages:(NSArray<UIImage*>*)images background:(CGRect)background;
-(id)initWithImageNames:(NSArray<NSString*>*)imageNames background:(CGRect)background;

//static Init methods
+(instancetype)viewWithImages:(NSArray<UIImage*>*)images background:(CGRect)background;
+(instancetype)viewWithImageNames:(NSArray<NSString*>*)imageNames background:(CGRect)background;

// Starts the panning animation
-(void)startPanning;
//Stops panning after current animation is done.
-(void)stopPanning;
//Stops panning before current animation is finished.
-(void)stopPanningImmedietly;

@end

//Optional delegate to use to see when images are starting or finishing panning
@protocol IEPanningBackgroundViewDelegate <NSObject>
@optional
-(void)panningBackgroundView:(IEPanningBackgroundView*)view didStartPanningImage:(UIImage*)image;
-(void)panningBackgroundView:(IEPanningBackgroundView*)view didFinishPanningImage:(UIImage*)image;
@end
