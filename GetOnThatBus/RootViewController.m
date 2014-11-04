//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import "busStop.h"

#define kTransitStops @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"
#define kCoordinateSpanDelta 0.1
#define kCLLocationDistanceMeters 50000
#define kMobileMakersLatitude 41.89374
#define kMobileMakersLongitude -87.63533

@interface RootViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *jsonArray;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLLocationCoordinate2D mobileMakers = CLLocationCoordinate2DMake (kMobileMakersLatitude,kMobileMakersLongitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mobileMakers, kCLLocationDistanceMeters, kCLLocationDistanceMeters);
    [self.mapView setRegion:viewRegion animated:YES];
    [self loadTransitStops];
}

- (void)loadTransitStops
{
    NSURL *url = [NSURL URLWithString:kTransitStops];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
            {
                if (connectionError)
                {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error"
                                                                                   message:connectionError.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:nil];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:nil];
                    self.jsonArray = jsonDictionary[@"row"];

                    for (NSDictionary *stopDictionary in self.jsonArray)
                    {
                        BusStop *busStop = [[BusStop alloc]initWithDictionary:stopDictionary];
                        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([busStop.latitude doubleValue], [busStop.longitude doubleValue]);
                        MKPointAnnotation *stopAnnotation = [[MKPointAnnotation alloc]init];
                        stopAnnotation.coordinate = coord;
                        stopAnnotation.title = busStop.name;
                        stopAnnotation.subtitle = busStop.route;
                        [self.mapView addAnnotation:stopAnnotation];
                    }

                }
            }
     ];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = [view.annotation coordinate];
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = kCoordinateSpanDelta;
    coordinateSpan.longitudeDelta = kCoordinateSpanDelta;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
