//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *detailOfRoute;
@property (weak, nonatomic) IBOutlet UILabel *detailOfIntermodal;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.busStop.name;

    self.detailOfRoute.text = self.busStop.route;

    self.detailOfIntermodal.text = self.busStop.intermodal;

    NSURL *url = [NSURL URLWithString :self.busStop.address];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL : url];
    
    [self.detailWebView loadRequest : urlRequest];

}

@end
