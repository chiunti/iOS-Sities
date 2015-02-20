//
//  MapView.h
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <iAd/iAd.h>
#import "GAITrackedViewController.h"

@interface MapView : GAITrackedViewController<CLLocationManagerDelegate, GMSMapViewDelegate, UIApplicationDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;

}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation        *location;
@property (weak, nonatomic) IBOutlet UIView *viewMapa;

// Actions
- (IBAction)btnRefreshDown:(id)sender;

//@property (strong,nonatomic) GMSMapView *mapView;

@end
