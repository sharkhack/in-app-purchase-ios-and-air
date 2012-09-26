/*
 * in-app-purchase-ios-and-air
 * https://github.com/sharkhack/
 *
 * Copyright (c) 2012 Azer Bulbul
 * Licensed under the MIT license.
 * https://github.com/sharkhack/in-app-purchase-ios-and-air/LICENSE-MIT
 */

#import "FlashRuntimeExtensions.h"
#import "MyDelegate.h"

@implementation MyDelegate
////SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<transactions>"];
	for (SKPaymentTransaction *t in transactions)
    {
		NSMutableString* tr = generateXml(t);
		[retXML appendString:tr];
		[tr release];
		
	}
	
	[retXML appendFormat:@"</transactions>"];
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"updatedTransactions", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<transactions>"];
	for (SKPaymentTransaction *t in transactions)
    {
		NSMutableString* tr = generateXml(t);
		[retXML appendString:tr];
		[tr release];
		
	}
	
	[retXML appendFormat:@"</transactions>"];
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"removedTransactions", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"restoreFailed", (const uint8_t*)[[error localizedDescription] stringByAppendingFormat:@":%d",[error code]]);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"restoreComplete", (const uint8_t*)"");
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
	NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<products>"];
	for (SKProduct* p in response.products) {
		[retXML appendFormat:@"<product><title>%@</title><desc>%@</desc><price>%@</price><locale>%@</locale><id>%@</id></product>",p.localizedTitle,p.localizedDescription,p.price,[p.priceLocale localeIdentifier],p.productIdentifier];
	}
	[retXML appendFormat:@"<invalid>"];
	for(NSString* s in response.invalidProductIdentifiers){ 
		[retXML appendFormat:@"<id>%@</id>",s];
	}
	[retXML appendFormat:@"</invalid></products>"]; 
	FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"productsReceived", (const uint8_t*)[retXML UTF8String]);
	[retXML release];
	[request release]; 
}
@end
