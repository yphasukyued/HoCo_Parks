//
//  GetJSON.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "GetJSON.h"

@implementation GetJSON

+ (NSMutableArray *)getNearest:(NSString *)type searchItem:(NSString *)item mv:(MKMapView *)mapView {
    NSMutableArray *json;
    NSError *error;
    NSString *filename;
    
    if ([item isEqualToString:@"Parks"]) {
        filename = @"dataParks.json";
    } else if ([item isEqualToString:@"Historic Sites"]) {
        filename = @"dataHistoric.json";
    } else if ([item isEqualToString:@"Pavilions"]) {
        filename = @"dataPavilions.json";
    } else if ([item isEqualToString:@"Playgrounds"]) {
        filename = @"dataPlaygrounds.json";
    } else {
        filename = @"dataAll_Amenities.json";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    NSArray * park;
    NSMutableArray *parks = [[NSMutableArray alloc] init];
    
    if ([item isEqualToString:@"Parks"]
        || [item isEqualToString:@"Historic Sites"]
        ) {
        
        for(int i=0; i< [json count]; i++) {
            NSDictionary *loc = [json objectAtIndex:i];
            
            CLLocation *pinLocation = [[CLLocation alloc]
                                       initWithLatitude:[[loc objectForKey:@"latitude"]floatValue]
                                       longitude:[[loc objectForKey:@"longitude"]floatValue]];
            
            CLLocation *userLocation = [[CLLocation alloc]
                                        initWithLatitude:mapView.userLocation.coordinate.latitude
                                        longitude:mapView.userLocation.coordinate.longitude];
            
            CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
            NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
            
            
            NSDictionary * dict =[NSMutableDictionary new];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_name"]] forKey:@"feature_name"];
            [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"latitude"]] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"longitude"]] forKey:@"longitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"id"]] forKey:@"id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"park_id"]] forKey:@"park_id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"site_name"]] forKey:@"site_name"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_type"]] forKey:@"feature_type"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_id"]] forKey:@"feature_id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"address1"]] forKey:@"address1"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"address2"]] forKey:@"address2"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"description"]] forKey:@"description"];
            park =[[NSArray alloc]initWithObjects:dict, nil];
            [parks addObjectsFromArray:park];
        }
        
    } else if ([item isEqualToString:@"Pavilions"]
                   || [item isEqualToString:@"Playgrounds"]
                   ) {
        
        for(int i=0; i< [json count]; i++) {
            NSDictionary *loc = [json objectAtIndex:i];
            
            CLLocation *pinLocation = [[CLLocation alloc]
                                       initWithLatitude:[[loc objectForKey:@"latitude"]floatValue]
                                       longitude:[[loc objectForKey:@"longitude"]floatValue]];
            
            CLLocation *userLocation = [[CLLocation alloc]
                                        initWithLatitude:mapView.userLocation.coordinate.latitude
                                        longitude:mapView.userLocation.coordinate.longitude];
            
            CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
            NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
            
            
            NSDictionary * dict =[NSMutableDictionary new];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_name"]] forKey:@"feature_name"];
            [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"latitude"]] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"longitude"]] forKey:@"longitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"id"]] forKey:@"id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"park_id"]] forKey:@"park_id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"site_name"]] forKey:@"site_name"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_type"]] forKey:@"feature_type"];
            [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_id"]] forKey:@"feature_id"];
            park =[[NSArray alloc]initWithObjects:dict, nil];
            [parks addObjectsFromArray:park];
        }
    } else {
        for(int i=0; i< [json count]; i++) {
            NSDictionary *loc = [json objectAtIndex:i];
            
            if ([[loc objectForKey:@"feature_type"] isEqualToString:item]) {
                CLLocation *pinLocation = [[CLLocation alloc]
                                           initWithLatitude:[[loc objectForKey:@"latitude"]floatValue]
                                           longitude:[[loc objectForKey:@"longitude"]floatValue]];
                
                CLLocation *userLocation = [[CLLocation alloc]
                                            initWithLatitude:mapView.userLocation.coordinate.latitude
                                            longitude:mapView.userLocation.coordinate.longitude];
                
                CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
                NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
                
                NSDictionary * dict =[NSMutableDictionary new];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_name"]] forKey:@"feature_name"];
                [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"latitude"]] forKey:@"latitude"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"longitude"]] forKey:@"longitude"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"id"]] forKey:@"id"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"park_id"]] forKey:@"park_id"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"site_name"]] forKey:@"site_name"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_type"]] forKey:@"feature_type"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_id"]] forKey:@"feature_id"];
                park =[[NSArray alloc]initWithObjects:dict, nil];
                [parks addObjectsFromArray:park];
            }
        }
    }

    if ([type isEqualToString:@"All"]) {
        return parks;
    } else if ([type isEqualToString:@"Nearest"]) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:TRUE];
        [parks sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        return parks;
    }
    
    return nil;
}

+ (NSMutableArray *)getAllFeature:(MKMapView *)mapView {
    
    NSError *error;
    NSMutableArray *json;
    NSString *filename = @"dataSome_Amenities.json";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSError *error1;
    NSMutableArray *json1;
    NSString *filename1 = @"dataParks.json";
    
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    
    NSError *jsonError1 = nil;
    
    NSString *jsonFilePath1 = [NSString stringWithFormat:@"%@/%@", documentsDirectory1,filename1];
    NSData *jsonData1 = [NSData dataWithContentsOfFile:jsonFilePath1 options:kNilOptions error:&jsonError1 ];
    json1 = [NSJSONSerialization JSONObjectWithData:jsonData1 options:kNilOptions error:&error1];
    
    NSError *error2;
    NSMutableArray *json2;
    NSString *filename2 = @"dataHistoric.json";
    
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory2 = [paths2 objectAtIndex:0];
    
    NSError *jsonError2 = nil;
    
    NSString *jsonFilePath2 = [NSString stringWithFormat:@"%@/%@", documentsDirectory2,filename2];
    NSData *jsonData2 = [NSData dataWithContentsOfFile:jsonFilePath2 options:kNilOptions error:&jsonError2 ];
    json2 = [NSJSONSerialization JSONObjectWithData:jsonData2 options:kNilOptions error:&error2];
    
    
    NSArray *park;
    NSMutableArray *parks = [[NSMutableArray alloc] init];
    for(int i=0;i<[json count];i++) {
        NSDictionary *entry = [json objectAtIndex:i];
            
        CLLocation *pinLocation = [[CLLocation alloc]
                                   initWithLatitude:[[entry objectForKey:@"latitude"]floatValue]
                                   longitude:[[entry objectForKey:@"longitude"]floatValue]];
        
        CLLocation *userLocation = [[CLLocation alloc]
                                    initWithLatitude:mapView.userLocation.coordinate.latitude
                                    longitude:mapView.userLocation.coordinate.longitude];
        
        CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
        NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
        
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_name"]] forKey:@"feature_name"];
        [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"latitude"]] forKey:@"latitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"longitude"]] forKey:@"longitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"id"]] forKey:@"id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"park_id"]] forKey:@"park_id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"site_name"]] forKey:@"site_name"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_type"]] forKey:@"feature_type"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_id"]] forKey:@"feature_id"];
        park =[[NSArray alloc]initWithObjects:dict, nil];
        [parks addObjectsFromArray:park];
    }
    
    for(int i=0;i<[json1 count];i++) {
        NSDictionary *entry = [json1 objectAtIndex:i];
        
        CLLocation *pinLocation = [[CLLocation alloc]
                                   initWithLatitude:[[entry objectForKey:@"latitude"]floatValue]
                                   longitude:[[entry objectForKey:@"longitude"]floatValue]];
        
        CLLocation *userLocation = [[CLLocation alloc]
                                    initWithLatitude:mapView.userLocation.coordinate.latitude
                                    longitude:mapView.userLocation.coordinate.longitude];
        
        CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
        NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
        
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_name"]] forKey:@"feature_name"];
        [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"latitude"]] forKey:@"latitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"longitude"]] forKey:@"longitude"];
        [dict setValue:[NSString stringWithFormat:@"P%@",[entry objectForKey:@"id"]] forKey:@"id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"park_id"]] forKey:@"park_id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"site_name"]] forKey:@"site_name"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_type"]] forKey:@"feature_type"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_id"]] forKey:@"feature_id"];
        park =[[NSArray alloc]initWithObjects:dict, nil];
        [parks addObjectsFromArray:park];
    }
    
    for(int i=0;i<[json2 count];i++) {
        NSDictionary *entry = [json2 objectAtIndex:i];
        
        CLLocation *pinLocation = [[CLLocation alloc]
                                   initWithLatitude:[[entry objectForKey:@"latitude"]floatValue]
                                   longitude:[[entry objectForKey:@"longitude"]floatValue]];
        
        CLLocation *userLocation = [[CLLocation alloc]
                                    initWithLatitude:mapView.userLocation.coordinate.latitude
                                    longitude:mapView.userLocation.coordinate.longitude];
        
        CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
        NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
        
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_name"]] forKey:@"feature_name"];
        [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"latitude"]] forKey:@"latitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"longitude"]] forKey:@"longitude"];
        [dict setValue:[NSString stringWithFormat:@"H%@",[entry objectForKey:@"id"]] forKey:@"id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"park_id"]] forKey:@"park_id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"site_name"]] forKey:@"site_name"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_type"]] forKey:@"feature_type"];
        [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_id"]] forKey:@"feature_id"];
        park =[[NSArray alloc]initWithObjects:dict, nil];
        [parks addObjectsFromArray:park];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:TRUE];
    [parks sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return parks;
    
}

+ (NSMutableArray *)getFeatureByParkID:(NSString *)park_id searchItem:(NSString *)item mv:(MKMapView *)mapView {

    NSError *error;
    NSMutableArray *json;
    NSString *filename;
    
    if ([item isEqualToString:@"Pavilions"]) {
        filename = @"dataPavilions.json";
    } else if ([item isEqualToString:@"Playgrounds"]) {
        filename = @"dataPlaygrounds.json";
    } else if ([item isEqualToString:@"All_Amenities"]) {
        filename = @"dataAll_Amenities.json";
    } else if ([item isEqualToString:@"Some_Amenities"]) {
        filename = @"dataSome_Amenities.json";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSArray *park;
    NSMutableArray *parks = [[NSMutableArray alloc] init];
    for(int i=0;i<[json count];i++) {
        NSDictionary *entry = [json objectAtIndex:i];
        if ([park_id isEqualToString:@"All"]) {
            
            CLLocation *pinLocation = [[CLLocation alloc]
                                       initWithLatitude:[[entry objectForKey:@"latitude"]floatValue]
                                       longitude:[[entry objectForKey:@"longitude"]floatValue]];
            
            CLLocation *userLocation = [[CLLocation alloc]
                                        initWithLatitude:mapView.userLocation.coordinate.latitude
                                        longitude:mapView.userLocation.coordinate.longitude];
            
            CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
            NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
            
            NSDictionary * dict =[NSMutableDictionary new];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_name"]] forKey:@"feature_name"];
                [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"latitude"]] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"longitude"]] forKey:@"longitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"id"]] forKey:@"id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"park_id"]] forKey:@"park_id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"site_name"]] forKey:@"site_name"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_type"]] forKey:@"feature_type"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_id"]] forKey:@"feature_id"];
            park =[[NSArray alloc]initWithObjects:dict, nil];
            [parks addObjectsFromArray:park];
        } else if ([park_id isEqualToString:[entry objectForKey:@"park_id"]]) {
            
            CLLocation *pinLocation = [[CLLocation alloc]
                                       initWithLatitude:[[entry objectForKey:@"latitude"]floatValue]
                                       longitude:[[entry objectForKey:@"longitude"]floatValue]];
            
            CLLocation *userLocation = [[CLLocation alloc]
                                        initWithLatitude:mapView.userLocation.coordinate.latitude
                                        longitude:mapView.userLocation.coordinate.longitude];
            
            CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
            NSString *distance = [NSString stringWithFormat:@"%.02f", dist/1609.34];
            
            NSDictionary * dict =[NSMutableDictionary new];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_name"]] forKey:@"feature_name"];
            [dict setValue:[NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@", distance]floatValue]] forKey:@"distance"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"latitude"]] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"longitude"]] forKey:@"longitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"id"]] forKey:@"id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"park_id"]] forKey:@"park_id"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"site_name"]] forKey:@"site_name"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_type"]] forKey:@"feature_type"];
            [dict setValue:[NSString stringWithFormat:@"%@",[entry objectForKey:@"feature_id"]] forKey:@"feature_id"];
            park =[[NSArray alloc]initWithObjects:dict, nil];
            [parks addObjectsFromArray:park];
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:TRUE];
    [parks sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return parks;

}

+ (NSMutableArray *)getTrail:(NSString *)trailID searchItem:(NSString *)trailName {
    
    NSString *str;
    str = @"https://gis.howardcountymd.gov/iOS/HoCoParks/GetTrail.aspx?searchItem=";
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", str,trailID];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSMutableArray *json;
    json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *latlngArray;
    NSArray *latitudelngitude;
    
    NSArray * coord0;
    NSMutableArray *coords0 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [json count]; i++) {
        NSDictionary *info = [json objectAtIndex:i];
        latlngArray = [[info objectForKey:@"WKT"] componentsSeparatedByString:@"|"];
    }
    
    for (int j = 0; j < [latlngArray count]; j++) {
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",latlngArray[j]] forKey:@"latlng"];
        coord0 =[[NSArray alloc]initWithObjects:dict, nil];
        [coords0 addObjectsFromArray:coord0];
    }
    
    NSArray * coord;
    NSMutableArray *coords = [[NSMutableArray alloc] init];
    
    for (int k = 0; k < [coords0 count]; k++) {
        NSDictionary *info = [coords0 objectAtIndex:k];
        latitudelngitude = [[info objectForKey:@"latlng"] componentsSeparatedByString:@" "];
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",latitudelngitude[1]] forKey:@"latitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",latitudelngitude[0]] forKey:@"longitude"];
        coord =[[NSArray alloc]initWithObjects:dict, nil];
        [coords addObjectsFromArray:coord];
    }
    return coords;
}
+ (NSMutableArray *)getDistanceProfile:(NSMutableArray *)trails {
    NSMutableArray *distances = [[NSMutableArray alloc] init];
    NSArray *distance;
    CLLocation *previousLocation;
    float sumDist = 0.0;
    
    NSArray *items = [trails valueForKeyPath:@"results"];
    for (NSDictionary *item in items) {
        NSLog(@"latlong = %@,%@",  [[item objectForKey:@"location"]objectForKey:@"lat"],[[item objectForKey:@"location"]objectForKey:@"lng"]);
        
        CLLocation *nextLocation = [[CLLocation alloc]
                                    initWithLatitude:[[[item objectForKey:@"location"]objectForKey:@"lat"]floatValue]
                                    longitude:[[[item objectForKey:@"location"]objectForKey:@"lng"]floatValue]];
        
        CLLocationDistance dist = [previousLocation distanceFromLocation:nextLocation];
        sumDist = sumDist + dist;
        NSDictionary *dict =[NSMutableDictionary new];
        [dict setValue:[item objectForKey:@"elevation"] forKey:@"elevation"];
        [dict setValue:[[item objectForKey:@"location"]objectForKey:@"lat"] forKey:@"latitude"];
        [dict setValue:[[item objectForKey:@"location"]objectForKey:@"lng"] forKey:@"longitude"];
        [dict setValue:[NSString stringWithFormat:@"%f",dist] forKey:@"distance"];
        [dict setValue:[NSString stringWithFormat:@"%f",sumDist] forKey:@"sum_distance"];
        distance =[[NSArray alloc]initWithObjects:dict, nil];
        [distances addObjectsFromArray:distance];
        previousLocation = nextLocation;
    }
    return distances;
}

+ (NSMutableArray *)getProfile:(NSMutableArray *)trails {
    NSError *error;
    NSString *strCoords = @"path=";
    
    for (int i = 0; i < [trails count]; i++) {
        NSDictionary *info = [trails objectAtIndex:i];
        strCoords = [strCoords stringByAppendingString:[NSString stringWithFormat:@"%.04f,%.04f|",[[info objectForKey:@"latitude"]floatValue],[[info objectForKey:@"longitude"]floatValue]]];
    }
    
    NSString *newStr;
    newStr = [strCoords substringToIndex:[strCoords length]-1];
    
    NSString *str1 = @"https://maps.googleapis.com/maps/api/elevation/json?";
    NSString *str2 = @"&samples=60&key=AIzaSyDnJsvZgkDWDLc1xKj-rermfgprQPvve_0";
    NSString *stringURL = [[NSString stringWithFormat:@"%@%@%@", str1,newStr,str2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    NSMutableArray *myprofiles;
    myprofiles = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
    
    return myprofiles;
}
+ (NSString *)getNearestTrail:(CGFloat)latItem lng:(CGFloat)lngItem {
    NSString *str;
    str = @"https://gis.howardcountymd.gov/iOS/HoCoParks/GetNearestTrails.aspx";
    NSString *stringURL = [NSString stringWithFormat:@"%@?latItem=%f&lngItem=%f", str,latItem,lngItem];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSMutableArray *json;
    NSString *hadIt;
    
    json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    for (int i = 0; i < [json count]; i++) {
        NSDictionary *dist = [json objectAtIndex:i];
        if ([[dist objectForKey:@"DISTANCE"]doubleValue] <= 10) {
            hadIt = [NSString stringWithFormat:@"%@-%@-%@-%@",[dist objectForKey:@"ID"],[dist objectForKey:@"Name"],[dist objectForKey:@"TrailLength"],[dist objectForKey:@"PathType"]];
        } else {
            hadIt = @"NO";
        }
    }
    return hadIt;
}

+ (NSMutableArray *)countFeatureByParkID:(NSString *)park_id {
    
    NSError *error;
    NSMutableArray *json;
    NSString *filename;
    
    filename = @"dataAll_Amenities.json";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSInteger amphitheater_count = 0;
    NSInteger archery_count = 0;
    NSInteger ballfield_count = 0;
    NSInteger basketball_count = 0;
    NSInteger bench_count = 0;
    NSInteger boatramp_count = 0;
    NSInteger bocceball_count = 0;
    NSInteger bridge_count = 0;
    NSInteger building_count = 0;
    NSInteger cricket_count = 0;
    NSInteger discgolf_count = 0;
    NSInteger dog_count = 0;
    NSInteger fountain_count = 0;
    NSInteger entrance_count = 0;
    NSInteger equestrian_count = 0;
    NSInteger firering_count = 0;
    NSInteger fishing_count = 0;
    NSInteger gazebo_count = 0;
    NSInteger grill_count = 0;
    NSInteger handball_count = 0;
    NSInteger hockeyrink_count = 0;
    NSInteger horseshoe_count = 0;
    NSInteger kiosk_count = 0;
    NSInteger multipurpose_count = 0;
    NSInteger observatory_count = 0;
    NSInteger parking_count = 0;
    NSInteger pavilion_count = 0;
    NSInteger picnictable_count = 0;
    NSInteger playground_count = 0;
    NSInteger restroom_count = 0;
    NSInteger portable_count = 0;
    NSInteger rqball_count = 0;
    NSInteger skatespot_count = 0;
    NSInteger skillspark_count = 0;
    NSInteger tennis_count = 0;
    NSInteger trailhead_count = 0;
    NSInteger volleyball_count = 0;
    
    NSArray *park;
    NSMutableArray *parks = [[NSMutableArray alloc] init];
    for(int i=0;i<[json count];i++) {
        NSDictionary *entry = [json objectAtIndex:i];
        if ([park_id isEqualToString:[entry objectForKey:@"park_id"]]) {
            NSString *ftype = [entry objectForKey:@"feature_type"];
            NSString *fname = [entry objectForKey:@"feature_name"];
            if ([ftype isEqualToString:@"AMPHITHEATER"]) {
                amphitheater_count += 1;
            } else if ([ftype isEqualToString:@"ARCHERY"]) {
                archery_count += 1;
            } else if ([ftype isEqualToString:@"BALLFIELD"]) {
                ballfield_count += 1;
            } else if ([ftype isEqualToString:@"BASKETBALL"]) {
                basketball_count += 1;
            } else if ([ftype isEqualToString:@"BENCH"]) {
                bench_count += 1;
            } else if ([ftype isEqualToString:@"BOATRAMP"]) {
                boatramp_count += 1;
            } else if ([ftype isEqualToString:@"BOCCEBALL"]) {
                bocceball_count += 1;
            } else if ([ftype isEqualToString:@"BRIDGE"]) {
                bridge_count += 1;
            } else if ([ftype isEqualToString:@"BUILDING"]) {
                building_count += 1;
            } else if ([ftype isEqualToString:@"CRICKET"]) {
                cricket_count += 1;
            } else if ([ftype isEqualToString:@"DISCGOLF"]) {
                discgolf_count += 1;
            } else if ([ftype isEqualToString:@"DOG"]) {
                dog_count += 1;
            } else if ([ftype isEqualToString:@"FOUNTAIN"]) {
                fountain_count += 1;
            } else if ([ftype isEqualToString:@"ENTRANCE"]) {
                entrance_count += 1;
            } else if ([ftype isEqualToString:@"EQUESTRIAN"]) {
                equestrian_count += 1;
            } else if ([ftype isEqualToString:@"FIRERING"]) {
                firering_count += 1;
            } else if ([ftype isEqualToString:@"FISHING"]) {
                fishing_count += 1;
            } else if ([ftype isEqualToString:@"GAZEBO"]) {
                gazebo_count += 1;
            } else if ([ftype isEqualToString:@"GRILL"]) {
                grill_count += 1;
            } else if ([ftype isEqualToString:@"HANDBALL"]) {
                handball_count += 1;
            } else if ([ftype isEqualToString:@"HOCKEYRINK"]) {
                hockeyrink_count += 1;
            } else if ([ftype isEqualToString:@"HORSESHOE"]) {
                horseshoe_count += 1;
            } else if ([ftype isEqualToString:@"KIOSK"]) {
                kiosk_count += 1;
            } else if ([ftype isEqualToString:@"MULTIPURPOSE"]) {
                multipurpose_count += 1;
            } else if ([ftype isEqualToString:@"OBSERVATORY"]) {
                observatory_count += 1;
            } else if ([ftype isEqualToString:@"PARKING"]) {
                parking_count += 1;
            } else if ([ftype isEqualToString:@"PAVILION"]) {
                pavilion_count += 1;
            } else if ([ftype isEqualToString:@"PICNICTABLE"]) {
                picnictable_count += 1;
            } else if ([ftype isEqualToString:@"PLAYGROUND"]) {
                playground_count += 1;
            } else if ([ftype isEqualToString:@"RESTROOM"]) {
                if ([fname isEqualToString:@"Portable Toilet"]) {
                    portable_count += 1;
                } else {
                    restroom_count += 1;
                }
            } else if ([ftype isEqualToString:@"RQBALL"]) {
                rqball_count += 1;
            } else if ([ftype isEqualToString:@"SKATESPOT"]) {
                skatespot_count += 1;
            } else if ([ftype isEqualToString:@"SKILLSPARK"]) {
                skillspark_count += 1;
            } else if ([ftype isEqualToString:@"TENNIS"]) {
                tennis_count += 1;
            } else if ([ftype isEqualToString:@"TRAILHEAD"]) {
                trailhead_count += 1;
            } else if ([ftype isEqualToString:@"VOLLEYBALL"]) {
                volleyball_count += 1;
            }
        }
    }

    NSDictionary * dict =[NSMutableDictionary new];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)amphitheater_count] forKey:@"AMPHITHEATER"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)archery_count] forKey:@"ARCHERY"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)ballfield_count] forKey:@"BALLFIELD"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)basketball_count] forKey:@"BASKETBALL"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)bench_count] forKey:@"BENCH"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)boatramp_count] forKey:@"BOATRAMP"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)bocceball_count] forKey:@"BOCCEBALL"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)bridge_count] forKey:@"BRIDGE"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)building_count] forKey:@"BUILDING"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)cricket_count] forKey:@"CRICKET"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)discgolf_count] forKey:@"DISCGOLF"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)dog_count] forKey:@"DOG"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)fountain_count] forKey:@"FOUNTAIN"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)entrance_count] forKey:@"ENTRANCE"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)equestrian_count] forKey:@"EQUESTRIAN"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)firering_count] forKey:@"FIRERING"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)fishing_count] forKey:@"FISHING"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)gazebo_count] forKey:@"GAZEBO"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)grill_count] forKey:@"GRILL"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)handball_count] forKey:@"HANDBALL"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)hockeyrink_count] forKey:@"HOCKEYRINK"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)horseshoe_count] forKey:@"HORSESHOE"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)kiosk_count] forKey:@"KIOSK"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)multipurpose_count] forKey:@"MULTIPURPOSE"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)observatory_count] forKey:@"OBSERVATORY"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)parking_count] forKey:@"PARKING"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)pavilion_count] forKey:@"PAVILION"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)picnictable_count] forKey:@"PICNICTABLE"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)playground_count] forKey:@"PLAYGROUND"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)restroom_count] forKey:@"RESTROOM"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)portable_count] forKey:@"PORTABLETOILET"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)rqball_count] forKey:@"RQBALL"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)skatespot_count] forKey:@"SKATESPOT"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)skillspark_count] forKey:@"SKILLSPARK"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)tennis_count] forKey:@"TENNIS"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)trailhead_count] forKey:@"TRAILHEAD"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)volleyball_count] forKey:@"VOLLEYBALL"];
    park =[[NSArray alloc]initWithObjects:dict, nil];
    [parks addObjectsFromArray:park];
    
    return parks;
}
@end
