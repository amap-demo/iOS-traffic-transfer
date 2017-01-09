//
//  Traffic_Transfer_DemoUITests.m
//  Traffic-Transfer-DemoUITests
//
//  Created by eidan on 17/1/9.
//  Copyright © 2017年 autonavi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Traffic_Transfer_DemoUITests : XCTestCase

@end

@implementation Traffic_Transfer_DemoUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    sleep(2);
    
    XCUIElement *collectionViewsQuery = app.collectionViews.element;
    [collectionViewsQuery swipeLeft];
    
    sleep(1);
    
    [collectionViewsQuery swipeLeft];
    
    sleep(1);
    
    XCUIElement *staticText = collectionViewsQuery.staticTexts[@"\u67e5\u770b\u8be6\u60c5"];
    [staticText tap];
    
    sleep(2);
    
    XCUIElement *publicButtonBackButton = app.buttons[@"public button back"];
    
    [publicButtonBackButton tap];
    
    sleep(1);
    
    [app.buttons[@"\u91cd\u65b0\u89c4\u5212"] tap];
    
    sleep(3);
    
    [staticText tap];
    
    sleep(1);
    
    [publicButtonBackButton tap];
    
    // wait
    XCTestExpectation *e = [self expectationWithDescription:@"empty wait"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [e fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    
}

@end
