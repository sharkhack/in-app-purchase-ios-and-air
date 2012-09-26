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

FREContext g_ctx = nil;
MyDelegate *observer = nil;

FREObject getProducts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSMutableSet* pids = nil;
    
    uint32_t len = 0;
    const uint8_t* str = nil;
    
    if(FREGetObjectAsUTF8(argv[0], &len, &str) == FRE_OK){
        NSString* p = [NSString stringWithUTF8String:(const char*)str];
        pids = [NSSet setWithArray:[p componentsSeparatedByString:@","]]; 
    }else{
       
    }
    
    SKProductsRequest* req = [[SKProductsRequest alloc] initWithProductIdentifiers:pids]; 
    req.delegate = observer;
    [req start];
    
    return nil;
}

FREObject startAppPayment(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    uint32_t len = 0;
    const uint8_t* str = nil;
    int quantity = -1;
    
    if(FREGetObjectAsUTF8(argv[0], &len, &str) == FRE_OK && FREGetObjectAsInt32(argv[1], &quantity) == FRE_OK){
        if(quantity == 1){
            
            SKPayment* singleP = [SKPayment paymentWithProductIdentifier:[NSString stringWithUTF8String:(const char*)str] ];
            
            [[SKPaymentQueue defaultQueue] addPayment:singleP];
        }else if (quantity > 1) {
            SKMutablePayment* manyP = [SKMutablePayment paymentWithProductIdentifier:[NSString stringWithUTF8String:(const char*)str]];
            manyP.quantity = quantity;
            [[SKPaymentQueue defaultQueue] addPayment:manyP];
        }else {
           
        }
        
    }else{
       
    }
    
    return nil;
}

FREObject finishTransaction1(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    BOOL matchFound = NO;
    const uint8_t* str = nil;
    uint32_t len = -1;
    
    if(FREGetObjectAsUTF8(argv[0], &len, &str) == FRE_OK){
        NSString* paramId = [NSString stringWithUTF8String:(const char *) str];
        
        NSArray* trans = [[SKPaymentQueue defaultQueue] transactions];
        
        for (SKPaymentTransaction* t in trans) {
            if ([t.transactionIdentifier isEqualToString:paramId]) {
                [[SKPaymentQueue defaultQueue] finishTransaction:t];
                matchFound = YES;
                break;
            }else if (t.transactionState == SKPaymentTransactionStateRestored) {
                if ([t.originalTransaction.transactionIdentifier isEqualToString:paramId]) {
                    [[SKPaymentQueue defaultQueue] finishTransaction:t.originalTransaction];
                    matchFound = YES;
                     break;
                }
            }
        }
    }
    
    FREObject retVal;
    if(FRENewObjectFromBool(matchFound, &retVal) == FRE_OK){
        return retVal;
    }else{
        return nil;
    }
}

FREObject muted(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
   
    FREObject retVal;
    if(FRENewObjectFromBool(![SKPaymentQueue canMakePayments], &retVal) == FRE_OK){
        return retVal;
    }else {
        return nil;
    }
}

FREObject restoreTrans(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    return NULL;
}

FREObject getTrans(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    FREObject retVal;
    NSMutableString* retXML = [[NSMutableString alloc] initWithString:@"<transactions>"];
    NSLog(@"obj Created");
    for (SKPaymentTransaction *t in [SKPaymentQueue defaultQueue].transactions)
    {
        NSMutableString* tr = generateXml(t);
        [retXML appendString:tr];
        
    }
    
    [retXML appendFormat:@"</transactions>"];
    
    if(FRENewObjectFromUTF8((uint32_t)[retXML length], (const uint8_t*)[retXML UTF8String], &retVal) == FRE_OK){
        return retVal;
    }else {
        return NULL; 
    }
}

void SharkyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    *numFunctionsToTest = 6;
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)*6);
    func[0].name = (const uint8_t*)"getProducts";
    func[0].functionData = NULL;
    func[0].function = &getProducts; 
    
    func[1].name = (const uint8_t*)"startPayment";
    func[1].functionData = NULL;
    func[1].function = &startAppPayment; 
    
    func[2].name = (const uint8_t*)"finish"; 
    func[2].functionData = NULL;
    func[2].function = &finishTransaction1;
    
    func[3].name = (const uint8_t*)"muted"; 
    func[3].functionData = NULL;
    func[3].function = &muted;
    
    func[4].name = (const uint8_t*)"restore"; 
    func[4].functionData = NULL;
    func[4].function = &restoreTrans;
    
    func[5].name = (const uint8_t*)"trans"; 
    func[5].functionData = NULL;
    func[5].function = &getTrans;
    
    *functionsToSet = func;
    
    g_ctx = ctx;
    
    observer = [[MyDelegate alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    
}

void SharkyContextFinalizer(FREContext ctx) { 
}

void SharkyExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                            FREContextFinalizer* ctxFinalizerToSet) {
    NSLog(@"Extension Initialized");
    *extDataToSet = NULL;
    *ctxInitializerToSet = &SharkyExtInitializer;
    *ctxFinalizerToSet = &SharkyExtInitializer;
}

void SharkyExtFinalizer(void* extData) {}

NSMutableString* generateXml(SKPaymentTransaction* t){
    NSLog(@"In Loop");
    NSMutableString* retXML = [[NSMutableString alloc] initWithCapacity:128];
    [retXML appendFormat:@"<transaction>"];
    [retXML appendFormat:@"<error>%@</error>",(t.transactionState == SKPaymentTransactionStateFailed?[[t.error localizedDescription] stringByAppendingFormat:@":%d",[t.error code]]:@"")];
    [retXML appendFormat:@"<pid>%@</pid>",t.payment.productIdentifier];
    [retXML appendFormat:@"<q>%d</q>",t.payment.quantity];
    [retXML appendFormat:@"<date>%f</date>",[t.transactionDate timeIntervalSince1970]];
    [retXML appendFormat:@"<id>%@</id>",t.transactionIdentifier];
    if(t.transactionState == SKPaymentTransactionStatePurchased){
        NSString* d = [[NSString alloc] initWithData:t.transactionReceipt encoding:NSASCIIStringEncoding];
        [retXML appendFormat:@"<receipt>%@</receipt>",d];
        [d release];
    }else {
        [retXML appendFormat:@"<receipt> </receipt>"];
    }
    [retXML appendFormat:@"<state>%d</state>",t.transactionState];
    if(t.transactionState == SKPaymentTransactionStateRestored){
        [retXML appendFormat:@"<og>"];
        [retXML appendFormat:@"<error>%@</error>",(t.originalTransaction.transactionState == SKPaymentTransactionStateFailed?[[t.originalTransaction.error localizedDescription] stringByAppendingFormat:@":%d",[t.error code]]:@"")];
        [retXML appendFormat:@"<pid>%@</pid>",t.originalTransaction.payment.productIdentifier];
        [retXML appendFormat:@"<q>%d</q>",t.originalTransaction.payment.quantity];
        [retXML appendFormat:@"<date>%f</date>",[t.originalTransaction.transactionDate timeIntervalSince1970]];
        [retXML appendFormat:@"<id>%@</id>",t.originalTransaction.transactionIdentifier];
        if(t.originalTransaction.transactionState == SKPaymentTransactionStatePurchased){
            NSString* d = [[NSString alloc] initWithData:t.originalTransaction.transactionReceipt encoding:NSASCIIStringEncoding]; 
            [retXML appendFormat:@"<receipt>%@</receipt>",d];
            [d release];
        }else {
            [retXML appendFormat:@"<receipt> </receipt>"];
        }
        [retXML appendFormat:@"<state>%d</state>",t.originalTransaction.transactionState];
        [retXML appendFormat:@"</og>"];
    }else {
        [retXML appendFormat:@"<og> </og>"];
    }
    [retXML appendFormat:@"</transaction>"];
    return retXML;
}




