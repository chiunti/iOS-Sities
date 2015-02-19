//
//  MapView.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "MapView.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "Defaults.h"


NSString  *strUserLocation;
float     mlatitude;
float     mlongitude;
GMSMapView *mapView_;

@interface MapView ()

@end

@implementation MapView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cfgiAdBanner];
    //[self getLugares];
    
    
    // Do any additional setup after loading the view.
    
    // --------------------- location
    
    self.locationManager   = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
    self.locationManager.desiredAccuracy  = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self paintMap];
}

-(void)paintMap
{
    //  Create a GMSCmeraPosition
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:17.0696588
                                                            longitude:-96.7264306
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.frame = CGRectMake(0, 0, self.viewMapa.frame.size.width, self.viewMapa.frame.size.height);
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    //self.viewMapa = mapView_;
    
    
    // marcadores
    //PFObject *testObject = [PFObject objectWithClassName:@"lugares"];
    
    for (id lugar in lugares)
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position =  CLLocationCoordinate2DMake( [lugar[@"position"] latitude ], [lugar[@"position"] longitude])  ;
        marker.title = lugar[@"name"];
        marker.snippet = lugar[@"description"];
        marker.map = mapView_;
    }
    
    [self.viewMapa addSubview:mapView_];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getLugares
{
    NSLog(@"getLugares mapa");
    PFQuery *query = [PFQuery queryWithClassName:@"lugares"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            lugares = [NSMutableArray arrayWithArray:objects];
            [self performSelectorOnMainThread:@selector(paintMap) withObject:nil waitUntilDone:NO];
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**********************************************************************************************
 Localization
 **********************************************************************************************/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = locations.lastObject;
    NSLog( @"didUpdateLocation!");
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         for (CLPlacemark *placemark in placemarks)
         {
             NSString *addressName = [placemark name];
             NSString *city = [placemark locality];
             NSString *administrativeArea = [placemark administrativeArea];
             NSString *country  = [placemark country];
             NSString *countryCode = [placemark ISOcountryCode];
             //NSLog(@"name is %@ and locality is %@ and administrative area is %@ and country is %@ and country code %@", addressName, city, administrativeArea, country, countryCode);
             strUserLocation = [[administrativeArea stringByAppendingString:@","] stringByAppendingString:countryCode];
             //NSLog(@"gstrUserLocation = %@", strUserLocation);
         }
         mlatitude = self.locationManager.location.coordinate.latitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         mlongitude = self.locationManager.location.coordinate.longitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         NSLog(@"lat = %f", mlatitude);
         NSLog(@"lon = %f", mlongitude);
     }];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    GMSMutablePath *mPath = [[GMSMutablePath alloc] init];
    [mPath addLatitude:mlatitude longitude:mlongitude];
    [mPath addCoordinate:marker.position];
    GMSPolyline *mpoly = [GMSPolyline polylineWithPath:mPath];
    mpoly.map = mapView_;
}


/***************************************
 iAd Banner
 **************************************/
- (void)cfgiAdBanner
{
    // Setup iAdView
    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, /*self.view.frame.size.height*/ 20, self.view.frame.size.width, 50)];
    /*
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    
    //Set coordinates for adView
    CGRect adFrame      = adView.frame;
    //adFrame.origin.y    = self.view.frame.size.height - 50;
    adFrame.origin.y    = 20;
    NSLog(@"adFrame.origin.y: %f",adFrame.origin.y);
    adView.frame        = adFrame;
    */
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    adView.delegate = self;
    [self.view addSubview:adView];
    adView.delegate         = self;
    adView.hidden           = YES;
    self->bannerIsVisible   = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self->bannerIsVisible)
    {
        adView.hidden = NO;
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        [UIView commitAnimations];
        self->bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self->bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        [UIView commitAnimations];
        adView.hidden = YES;
        self->bannerIsVisible = NO;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"resume actions from banner");
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}
- (IBAction)btnRefreshPressed:(id)sender {
    [self getLugares];
}
@end
