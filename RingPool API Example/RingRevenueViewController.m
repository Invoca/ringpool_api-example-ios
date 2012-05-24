//
//  RingRevenueViewController.m
//  RingPool API Example
//
//  Copyright (c) 2012 RingRevenue, Inc. All rights reserved.
//

#define RING_POOL_API_URL_WITH_KEY  @"http://www2.ringrevenue.com/api/2012-01-10/ring_pools/1943/allocate_number.json?ring_pool_key=edvNTn67ft4KzruHeqUfUFy5v2w" /* Set RingPool URL here */
#define NUMBER_NOT_FOUND_TEXT       @"No number found"

#import "RingRevenueViewController.h"


@interface RingRevenueViewController ()

@end

@implementation RingRevenueViewController

@synthesize responseField;

@synthesize textField;
@synthesize label;

@synthesize ringPoolResponseData;
@synthesize ringPoolStatusCode;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


/*
 ------------------------------------------------------------------------
 RING POOL API interface
 ------------------------------------------------------------------------
 */
- (IBAction)fetchRingPoolNumber:(id)sender
{
    self.label.text = @"Loading...";
    
    // Create the request with dynamic RingPool parameter values (specific to your RingPool, some examples are below)
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                // RingPool param values                    // RingPool param names
                                self.textField.text,                        @"sid",
                                [[UIDevice currentDevice] systemVersion],   @"os_version",
                                nil];
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL : [self ringPoolUrl: parameters]
                                           cachePolicy    : NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval: 20.0];
    
    // create the connection with the request
    // the callbacks defined below will get called asynchronously
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        self.ringPoolResponseData = [NSMutableData data];
    }
    else
    {
        self.label.text = @"An error occurred.";
    }
}

- (NSURL*)ringPoolUrl: (NSDictionary*) parameters
{   
    NSString* fullUrl = [self addQueryStringToUrlString: RING_POOL_API_URL_WITH_KEY withDictionary:parameters];
    
    NSLog( @"Fetching API from: %@", fullUrl );
    return [NSURL URLWithString: fullUrl];
}

- (NSString*)urlEscapeString:(NSString *)unencodedString 
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

- (NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}


/*
 ------------------------------------------------------------------------
 NSURLConnection delegate methods for asynchronous requests
 ------------------------------------------------------------------------
 */

#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* Called when the server has determined that it has enough  
     information to create the NSURLResponse. It can be called 
     multiple times (for example in the case of a redirect), so 
     each time we reset the data. */
    
    [self.ringPoolResponseData setLength:0];
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        self.ringPoolStatusCode = [((NSHTTPURLResponse *)response) statusCode];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* appends the new data to the received data */
    [self.ringPoolResponseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.label.text = NUMBER_NOT_FOUND_TEXT;
    
    NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:self.ringPoolResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    self.responseField.text = responseString;
    
    if (self.ringPoolStatusCode >= 400)
    {
        [connection cancel];  // stop connecting; no more delegate messages
        
        NSDictionary *errorInfo
        = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                              NSLocalizedString(@"status code %d",@""),
                                              self.ringPoolStatusCode]
                                      forKey:NSLocalizedDescriptionKey];
        NSError *statusError
        = [NSError errorWithDomain:@"Error"
                              code:self.ringPoolStatusCode
                          userInfo:errorInfo];
        [self connection:connection didFailWithError:statusError];
        
        return;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.ringPoolResponseData
                                                         options:kNilOptions 
                                                           error:&error];
    
    if (error != nil)
    {
        NSLog(@"Error decoding JSON: %@", error);
        self.label.text = NUMBER_NOT_FOUND_TEXT;
        return;
    }
    
    self.label.text  = [json objectForKey:@"promo_number_formatted"];
}




- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.textField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
