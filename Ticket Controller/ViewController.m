//
//  ViewController.m
//  Ticket Controller
//
//  Created by Gilberto Villani on 20/10/2014.
//  Copyright (c) 2014 Infragistics. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import <UIKit/UIKit.h>

@interface igViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;

    UIView *_highlightView;
    UILabel *_label;
    NSArray *_tableData;
    NSMutableArray *_tableIndex;
    NSMutableArray *_columns;

}
@end

@implementation igViewController

@synthesize _littleView;
@synthesize _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableData = [NSArray arrayWithObjects:@"02451736", @"02281617", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    _tableIndex = [NSMutableArray arrayWithObjects:@"02451736", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];

    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];

    _session.sessionPreset = AVCaptureSessionPreset352x288;
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;

    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }

    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];

    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self._littleView.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self._littleView.layer addSublayer:_prevLayer];

    [_session startRunning];

    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
}

// Table View
// add Columns
/*- (void)addColumn:(CGFloat)position {
    [_columns addObject:[NSNumber numberWithFloat:position]];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [_tableData objectAtIndex:indexPath.row];
    return cell;
}

/*
- (void)tableView :(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:@"Bloqueado" message:@"TESTE" delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [messageAlert show];
    
    //    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    _label.text = cell.textLabel.text;
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}
*/

// QRCode scan
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];

    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:                (AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        _highlightView.frame = highlightViewRect;

        if (detectionString != nil)
        {
            _label.text = detectionString;
            
            BOOL e = false;
            int i = 0;
            while (i < [_tableData count]) {
                
                if ([[NSString stringWithFormat:@"%@",[_tableData objectAtIndex:i]] isEqualToString:detectionString]) {
                    
                    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    
                    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                        [_session stopRunning];
                        UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:@"Bloqueado" message:[NSString stringWithFormat:@"Convidado %@ já entrou.", detectionString] delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
                        [messageAlert show];
                        _label.text = @"BLOQUEADO";
                        e = true;
                        break;
                    }
                    else
                    {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [_session stopRunning];
                    UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:@"Liberado" message:[NSString stringWithFormat:@"Convite %@ válido.", detectionString] delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
                    [messageAlert show];
                    _label.text = @"LIBERADO";
                        e = true;
                    }
                    break;
                }
                else
                {
                i++;
                }
                
            }
            if (!e) {
            [_session stopRunning];
            UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:@"Bloqueado" message:[NSString stringWithFormat:@"Convite %@ não existe.", detectionString] delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
            [messageAlert show];
            _label.text = @"FALSO";
            break;
            }
        }
        else
            _label.text = @"(none)";
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
//    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _highlightView.frame = CGRectZero;
    [_session startRunning];
}

@end