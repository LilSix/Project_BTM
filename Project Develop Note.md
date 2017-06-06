# Project Develop Note

### 使用 `@try` 避免因產生例外造成彈出

```
@try {

    // Code that can potentially throw an exception.
} @catch (NSException *exception) {

    // Handle an exception thrown in the @try block.
} @finally {

    // Code that gets executed whether or not an exception is thrown.
}
```

### 使用 `NSURLSessionDownloadDelegate` 執行背景下載

```
#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    @try {

        NSData *data = [NSData dataWithContentsOfURL:location];
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
        for (NSDictionary *dictionary in array) {

            NSString *routeUID = [dictionary objectForKey:@"RouteUID"];
            NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
            NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
            NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
            NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];

            if (![departureStopNameZh isEqualToString:@""]) {
                NSString *editedZhTW = [self editStringFromHalfWidthToFullWidth:zhTW];
                NSString *editedDepartureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
                NSString *editedDestinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];
                NSString *departureToDestination = [NSString stringWithFormat:@"%@－%@", editedDepartureStopNameZh, editedDestinationStopNameZh];

                [[cityBus routeUID] addObject:routeUID];
                [[cityBus routeName] addObject:editedZhTW];
                [busStopStartToEnd addObject:departureToDestination];
            }
        }

        NSLog(@"[cityBus routeUID]: %@", [cityBus routeUID]);
        NSLog(@"[cityBus routeName]: %@", [cityBus routeName]);
    } @catch (NSException *exception) {

        NSLog(@"Caught: %@, %@", [exception name], [exception reason]);
    } @finally {

        NSLog(@"Download compeleted.");

        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        [_searchBusList reloadData];
    }
}
```

### 在 `NSObject` 使用泛型（Generics）容器

```
//
//  CityBus.h
//  Project_BTM
//

@interface CityBus : NSObject

@property (strong, nonatomic) NSMutableArray<NSString *> *routeUID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeName;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSMutableArray<NSString *> *departureStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *destinationStopName;
@property (strong, nonatomic) NSString *estimateTime;

@end
```

### 使用 Segue 傳遞參數

```
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"showBusDetail"]) {

        BusDetailViewController *busDetailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [_searchBusList indexPathForSelectedRow];  /*  An index path identifying the row and
                                                                                section of the selected row.    */
        NSString *string = [[cityBus routeName] objectAtIndex:[indexPath row]];
        [busDetailViewController setCityBusRouteTitle:string];
    }
}
```

### JSON

`[{Key: Value}]`

> 若 Value 為 `BOOL` 或是數字，則回傳進 Objective-C 會被讀取為 `NSNumber`。

### Thread 1: signal SIGABRT

[Xcode error - Thread 1: signal SIGABRT [closed]](https://stackoverflow.com/questions/9750224/xcode-error-thread-1-signal-sigabrt)

SIGABRT is, as stated in other answers, a general uncaught exception. You should definitely learn a little bit more about Objective-C. The problem is probably in your UITableViewDelegate method didSelectRowAtIndexPath.

```
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
```

I can't tell you much more until you show us something of the code where you handle the table data source and delegate methods.
