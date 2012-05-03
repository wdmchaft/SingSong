/*
     File: AVCamUtilities.m
 Abstract: A utility class containing a method to find an AVCaptureConnection of a particular media type from an array of AVCaptureConnections.
  Version: 1.2
 
 */

#import "AVCamUtilities.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVCamUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

@end
