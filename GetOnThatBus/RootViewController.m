//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "RootViewController.h"
#import "DetailViewController.h"
#import "BusStop.h"
#import "Annotation.h"

#define kTransitStops @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"
#define kCLLocationDistanceMeters 50000
#define kMobileMakersLatitude 41.89374
#define kMobileMakersLongitude -87.63533

@interface RootViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *busStopArray;
@property NSMutableDictionary *busStopDictionary;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialLocation];
    [self loadTransitStops:kTransitStops];
    self.busStopArray = [NSMutableArray array];
    self.busStopDictionary = [NSMutableDictionary dictionary];
}

- (void)initialLocation
{
    CLLocationCoordinate2D mobileMakers = CLLocationCoordinate2DMake (kMobileMakersLatitude,kMobileMakersLongitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mobileMakers, kCLLocationDistanceMeters, kCLLocationDistanceMeters);
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)loadTransitStops:(NSString *)json
{
    NSURL *url = [NSURL URLWithString:json];
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
                    NSArray *jsonArray = jsonDictionary[@"row"];

                    int indexCount = 0;
                    for (NSDictionary *dictionary in jsonArray)
                    {
                        BusStop *busStop = [[BusStop alloc]initWithDictionary:dictionary];
                        [self.busStopArray addObject: busStop];
                        Annotation *busStopAnnotation = [[Annotation alloc]init];
                        busStopAnnotation.tag = indexCount;
                        busStopAnnotation.coordinate = CLLocationCoordinate2DMake([busStop.latitude doubleValue], [busStop.longitude doubleValue]);
                        busStopAnnotation.title = busStop.name;
                        busStopAnnotation.subtitle = busStop.route;



                        if ([busStop.intermodal isEqual:@"Metra"])
                        {
                            [self.busStopDictionary setObject:busStopAnnotation.title forKey:@"Metra"];
                        }
                        else if ([busStop.intermodal isEqual:@"Pace"])
                        {
                            [self.busStopDictionary setObject:busStopAnnotation.title forKey:@"Pace"];
                        }


                        [self.mapView addAnnotation:busStopAnnotation];
                        indexCount++;
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


    if ([[annotation title] isEqual: self.busStopDictionary[@"Metra"]])
    {
        pin.pinColor = MKPinAnnotationColorGreen;
    }
    if ([[annotation title] isEqual:self.busStopDictionary[@"Pace"]])
    {
        pin.pinColor = MKPinAnnotationColorPurple;
    }




    return pin;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    Annotation *busStopAnnotation = view.annotation;
    int indexCount = busStopAnnotation.tag;
    BusStop *busStop= self.busStopArray[indexCount];
    [self performSegueWithIdentifier:@"detailSegue" sender:busStop];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:busStop
{
    DetailViewController *dvc = segue.destinationViewController;
    dvc.busStop = busStop;
}

@end
