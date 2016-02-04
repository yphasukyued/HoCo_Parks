//
//  AvailableMemory.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 12/1/15.
//  Copyright © 2015 Howard County. All rights reserved.
//


#import "AvailableMemory.h"
#include <sys/sysctl.h>
#include <mach/mach.h>

@implementation UIDevice (AvailableMemory)

- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

@end
