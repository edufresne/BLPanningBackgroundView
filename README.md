# IEPanningBackgroundView
A reusable view that can be added as a subview to pan through a set of stock images. This can be used for a slow panning effect for sign in/intro screens or the speed can be increased for a carousel like component. 

- Runs on an iOS device
- Both Swift and Objective C versions

## Usage
- Clone the repository and add either the swift or objective c version to your project
- The examples below show adding the panning background view as the whole screen. 

#### Objective C
```objective-c
void viewDidLoad{
  NSArray *array = [NSArray arrayWithObjects: @"image1", @"image2", @"image3", nil];
  panningView = [IEPanningBackgroundView viewWithImageNames: array background: self.view.frame];
  [self addSubView: panningView];
  
  panningView.style = IEPanningBackgroundViewStyleDark; //Controls transition color and overlay color if applicable
  panningView.overlayAlpha = 0.5; //Adds a lighter or darker overlay depending on the style 
  panningView.transitionTime = 1.5; //Transition between pictures in seconds
  panningView.panningTime = 35; //Controls how long it takes to transition from each image
  [panningView startPanning];
}

void someMethod{
  [panningView stopPanning];
}
```

#### Swift
````swift
override func viewDidLoad(){
  let array = ["image1", "image2", "image3"]
  panningView = IEBackgroundView(imageNames: array, background: view.frame)
  addSubView(panningView)
  
  panningView.style = IEPanningBackgroundViewStyle.Dark //Controls transition color and overlay color if applicable
  panningView.overlayAlpha = 0.5 //Adds a lighter or darker overlay depending on the style 
  panningView.transitionTime = 1.5 //Transition between pictures in seconds
  panningView.startPanning() //Controls how long it takes to transition from each image
}

func someMethod(){
  panningView.stopPanning()
}
````
