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

@interface RootViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *displaySegmentControl;
@property NSMutableArray *busStopArray;
@property NSMutableArray *metraArray;
@property NSMutableArray *paceArray;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialLocation];
    [self loadTransitStops:kTransitStops];
    self.busStopArray = [NSMutableArray array];
    self.metraArray = [NSMutableArray array];
    self.paceArray = [NSMutableArray array];
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
                            [self.metraArray addObject:busStopAnnotation.title];
                        }

                        if ([busStop.intermodal isEqual:@"Pace"])
                        {
                            [self.paceArray addObject:busStopAnnotation.title];
                        }
                        [self.mapView addAnnotation:busStopAnnotation];
                        indexCount++;
                    }
                    [self.tableView reloadData];
                }
            }
     ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.busStopArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    BusStop *busStopName = self.busStopArray [indexPath.row];

    cell.textLabel.text = busStopName.name;

    BusStop *busStopRoute = self.busStopArray [indexPath.row];

    cell.detailTextLabel.text = busStopRoute.route;

//    cell.textLabel.text = [self.busStopArray [indexPath.row] name];

//    cell.detailTextLabel.text = [self.busStopArray [indexPath.row] route];

    return cell;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    if ([self.metraArray containsObject: [annotation title]])
    {
        pin.pinColor = MKPinAnnotationColorGreen;
    }

    if ([self.paceArray containsObject: [annotation title]])
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

- (IBAction)switchView:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        [UIView transitionFromView:self.mapView toView:self.tableView duration:0.4 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromBottom
                        completion:^(BOOL finished) {
                            [self.tableView reloadData];
                        }];
    }
    else
    {
        [UIView transitionFromView:self.tableView toView:self.mapView duration:0.4 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromBottom
                        completion:^(BOOL finished) {
                            [self.tableView reloadData];
                        }];
    }


}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:busStop
{
    DetailViewController *dvc = segue.destinationViewController;
    dvc.busStop = busStop;
}

@end
