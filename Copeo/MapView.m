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
GMSPolyline *polyline1;
GMSPolyline *polyline2;

@interface MapView ()

@end

@implementation MapView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cfgiAdBanner];
    // google analytics
    self.screenName = @"Map View";
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Map View";
}

- (IBAction)btnRefreshDown:(id)sender {
    [self getLugares];
}

-(void)paintMap
{
    //  Create a GMSCmeraPosition
    NSLog(@"paintMap");
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:17.0696588
                                                            longitude:-96.7264306
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.frame = CGRectMake(0, 0, self.viewMapa.frame.size.width, self.viewMapa.frame.size.height);
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    
    
    
    // marcadores
    //PFObject *testObject = [PFObject objectWithClassName:@"lugares"];
    
    for (id lugar in lugares)
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position =  CLLocationCoordinate2DMake( [lugar[@"position"] latitude ], [lugar[@"position"] longitude])  ;
        marker.title = lugar[@"name"];
        marker.snippet = [lugar[@"description" ] stringByAppendingString:@"\n\nPresiona aquí para trazar la ruta"];
        marker.map = mapView_;
    }
    
    // remove subviews
    for (UIView *view in [self.viewMapa subviews])
    {
        [view removeFromSuperview];
    }
    
    // add new view
    [self.viewMapa addSubview:mapView_];
    //self.viewMapa = mapView_;
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






//---------------------------------------------------------------------------------------------
// Localization
//---------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = locations.lastObject;
    //NSLog( @"didUpdateLocation!");
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         ///
         //for (CLPlacemark *placemark in placemarks)
         //{
         //    NSString *addressName = [placemark name];
         //    NSString *city = [placemark locality];
         //    NSString *administrativeArea = [placemark administrativeArea];
         //    NSString *country  = [placemark country];
         //    NSString *countryCode = [placemark ISOcountryCode];
         //    NSLog(@"name is %@ and locality is %@ and administrative area is %@ and country is %@ and country code %@", addressName, city, administrativeArea, country, countryCode);
         //    strUserLocation = [[administrativeArea stringByAppendingString:@","] stringByAppendingString:countryCode];
         //    NSLog(@"gstrUserLocation = %@", strUserLocation);
         //}
         //
          
         mlatitude = self.locationManager.location.coordinate.latitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         mlongitude = self.locationManager.location.coordinate.longitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         //NSLog(@"lat = %f", mlatitude);
         //NSLog(@"lon = %f", mlongitude);
     }];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{

    [self drawDirection:CLLocationCoordinate2DMake(mlatitude, mlongitude) and:CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)];
    
}


//---------------------------------------
// iAd Banner
//---------------------------------------
 - (void)cfgiAdBanner
{
    // Setup iAdView
    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0,  20, self.view.frame.size.width, 50)];
    //
    //adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    //
    ////Set coordinates for adView
    //CGRect adFrame      = adView.frame;
    ////adFrame.origin.y    = self.view.frame.size.height - 50;
    //adFrame.origin.y    = 20;
    //NSLog(@"adFrame.origin.y: %f",adFrame.origin.y);
    //adView.frame        = adFrame;
    //
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





//--------------------------------
// map directions
// -------------------------------


- (void) drawDirection:(CLLocationCoordinate2D)source and:(CLLocationCoordinate2D) dest {
    
    
    //GMSPolyline *polyline = [[GMSPolyline alloc] init];
    if (polyline1) {
        polyline1.map = nil;
        polyline2.map = nil;
    }
    polyline1 = [[GMSPolyline alloc] init];
    polyline2 = [[GMSPolyline alloc] init];
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    NSArray * points = [self calculateRoutesFrom:source to:dest];
    
    NSInteger numberOfSteps = points.count;
    
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [points objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        [path addCoordinate:coordinate];
    }
    
    polyline1.path = path;
    polyline1.strokeColor = [UIColor redColor];
    polyline1.strokeWidth = 4.f;
    //polyline.map = self.mapView;
    polyline1.map = mapView_;
    
    // Copy the previous polyline, change its color, and mark it as geodesic.
    polyline2 = [polyline1 copy];
    polyline2.strokeWidth = 2.f;
    polyline2.strokeColor = [UIColor yellowColor];
    polyline2.geodesic = YES;
    //polyline.map = self.mapView;
    polyline2.map = mapView_;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&avoid=highways&mode=driving",saddr,daddr]];
    
    NSError *error=nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSURLResponse *response = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONWritingPrettyPrinted error:nil];
    
    return [self decodePolyLine:[self parseResponse:dic]];
}
- (NSString *)parseResponse:(NSDictionary *)response {
    NSArray *routes = [response objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    if (route) {
        NSString *overviewPolyline = [[route objectForKey:
                                       @"overview_polyline"] objectForKey:@"points"];
        return overviewPolyline;
    }
    return @"";
}
-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc]
                                initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0,
                                                    [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1)
                          : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1)
                          : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:
                                [latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    return array;
}


@end
