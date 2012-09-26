/*
 * in-app-purchase-ios-and-air
 * https://github.com/sharkhack/
 *
 * Copyright (c) 2012 Azer Bulbul
 * Licensed under the MIT license.
 * https://github.com/sharkhack/in-app-purchase-ios-and-air/LICENSE-MIT
 */

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern FREContext g_ctx;
NSMutableString* generateXml(SKPaymentTransaction*);


@interface MyDelegate : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate> {
    
}
//// SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

//// SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
@end
