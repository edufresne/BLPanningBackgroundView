//
//  IEPanningBackgroundView.swift
//  IEPanningBackgroundView
//
//  Created by Eric Dufresne on 2016-08-22.
//  Copyright © 2016 Eric Dufresne. All rights reserved.
//

import UIKit

//Delegate for use to see when images are switching and when they are done swifthing
@objc protocol IEPanningBackgroundViewDelegate{
    @objc optional func panningBackgroundViewWillPanImage(_ view : IEPanningBackgroundView, image : UIImage)
    @objc optional func panningBackgroundViewDidPanImage(_ view : IEPanningBackgroundView, image : UIImage)
}
enum IEPanningBackgroundStyle : Int{
    case light, dark
}

//Subclass of UIImage View
class IEPanningBackgroundView : UIImageView{

    //Variable that sets the overlay of the picture. This is white if the style is light and black if the style is dark. Can range from values 0-1
    var overlayAlpha : Double = 0{
        didSet{
            if self.initialized{
                if self.style == IEPanningBackgroundStyle.dark{
                    self.overlayView.backgroundColor = UIColor(white: 0, alpha: CGFloat(self.overlayAlpha))
                }
                else{
                    self.overlayView.backgroundColor = UIColor(white: 1, alpha: CGFloat(self.overlayAlpha))
                }
            }
        }
    }
    
    //Variable that sets panning time of each stock image
    var panningTime : Double = 40

    //Variable that sets the transition time for the fade out/in transition in between images
    var transitionTime : Double = 2
    
    var style : IEPanningBackgroundStyle{
        didSet{
            if self.initialized{
                if self.style == IEPanningBackgroundStyle.dark{
                    self.overlayView.backgroundColor = UIColor(white: 0, alpha: CGFloat(overlayAlpha))
                }
                else{
                    self.overlayView.backgroundColor = UIColor(white: 1, alpha: CGFloat(overlayAlpha))
                }
            }
        }
    }
    //An array of all the images currently cycling through the panning background view
    var stockImages : Array = [UIImage]()
    
    //Optional delegate for use of the user
    weak var delegate : IEPanningBackgroundViewDelegate?
    
    //Private Variables
    
    private var imageIndex : Int = 0
    private var initialBackgroundSize : CGRect = CGRect()
    private var transitionView : UIView = UIView()
    private var overlayView : UIView = UIView()
    private var timer : Timer?
    private var initialized : Bool = false
    
    //Creates this object using an array of UIImage and the background of the superview
    init(images: [UIImage], background: CGRect){
        imageIndex = Int(arc4random())%images.count
        initialBackgroundSize = background
        style = IEPanningBackgroundStyle.dark
        overlayAlpha = 0
        super.init(image: images[imageIndex])
        
        let resizeFactor = frame.size.height/background.size.height
        frame = CGRect(x: background.origin.x, y: background.origin.y, width: frame.size.width/resizeFactor, height: frame.size.height/resizeFactor)
        
        transitionView = UIView.init(frame: background)
        transitionView.backgroundColor = UIColor.clear
        addSubview(transitionView)
        
        overlayView = UIView.init(frame: frame)
        overlayView.backgroundColor = UIColor.clear
        addSubview(overlayView)
        initialized = true
    }
    //Creates this object using an array of strings that are the image names and the background of the superview
    init(imageNames: [String], background : CGRect){
        for name in imageNames{
            stockImages.append(UIImage(named: name)!)
        }
        imageIndex = Int(arc4random())%stockImages.count
        initialBackgroundSize = background
        style = IEPanningBackgroundStyle.dark
        overlayAlpha = 0
        super.init(image: stockImages[imageIndex])
        
        let resizeFactor = frame.size.height/background.size.height
        frame = CGRect(x: background.origin.x, y: background.origin.y, width: frame.size.width/resizeFactor, height: frame.size.height/resizeFactor)
        
        transitionView = UIView.init(frame: background)
        transitionView.backgroundColor = UIColor.clear
        addSubview(transitionView)
        
        overlayView = UIView.init(frame: frame)
        overlayView.backgroundColor = UIColor.clear
        addSubview(overlayView)
        initialized = true
    }
    
    //Required ignore
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //Method that starts animating the image with the panning effect and cycles through all the pictures repeatedly until stopPanning() is called
    func startPanning(){
        delegate?.panningBackgroundViewWillPanImage?(self, image: self.image!)
        
        UIView.beginAnimations("panningAnimation", context: nil)
        UIView.setAnimationDuration(panningTime)
        frame = CGRect(x: -frame.width+initialBackgroundSize.width, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        UIView.commitAnimations()
        
        let select = #selector(IEPanningBackgroundView.reset)
        timer = Timer.scheduledTimer(timeInterval: panningTime, target: self, selector: select, userInfo: nil, repeats: false)
    }
    //Stops panning once the current image is done panning
    func stopPanning(){
        timer?.invalidate()
        timer = nil
    }
    //Stops all animations immedietly
    func stopPanningImmedietly(){
        timer?.invalidate()
        timer = nil
        layer.removeAllAnimations()
    }
    
    //Private Methods
    
    @objc fileprivate func reset(){
        delegate?.panningBackgroundViewDidPanImage!(self, image: self.image!)
        
        UIView.beginAnimations("transition-in", context: nil)
        UIView.setAnimationDuration(self.transitionTime/2)
        if self.style == IEPanningBackgroundStyle.dark{
            transitionView.backgroundColor = UIColor.black
        }
        else{
            transitionView.backgroundColor = UIColor.white
        }
        UIView.commitAnimations()
        
        UIView.beginAnimations("transition-out", context: nil)
        UIView.setAnimationDuration(transitionTime/2)
        UIView.setAnimationDelay(transitionTime/2)
        transitionView.backgroundColor = UIColor.clear
        UIView.commitAnimations()
        
        let select = #selector(IEPanningBackgroundView.changeImages)
        timer = Timer.scheduledTimer(timeInterval: transitionTime/2, target: self, selector: select, userInfo: nil, repeats: false)
    }
    @objc fileprivate func changeImages(){
        imageIndex += 1
        if (imageIndex >= stockImages.count){
            imageIndex = 0
        }
        
        image = self.stockImages[imageIndex]
        let resizeFactor = image!.size.height/initialBackgroundSize.size.height
        frame = CGRect(x: initialBackgroundSize.origin.x, y: initialBackgroundSize.origin.y, width: image!.size.width/resizeFactor, height: image!.size.height/resizeFactor)
        overlayView.frame = frame
        
        delegate?.panningBackgroundViewWillPanImage?(self, image: self.image!)
        
        UIView.beginAnimations("panningAnimation", context: nil)
        UIView.setAnimationDuration(panningTime)
        frame = CGRect(x: -frame.size.width+initialBackgroundSize.size.width, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        UIView.commitAnimations()
        
        let select = #selector(IEPanningBackgroundView.reset)
        timer = Timer.scheduledTimer(timeInterval: panningTime, target: self, selector: select, userInfo: nil, repeats: false)
    }
}
