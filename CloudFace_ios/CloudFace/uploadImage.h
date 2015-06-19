//
//  uploadImage.h
//  SantaFace
//
//  Created by 语泽思密达 on 15/6/11.
//  Copyright (c) 2015年 DevBridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface uploadImage : NSObject {
    @public
    NSString *responseString;
}

-(void)sendImageToServer:(UIImage *)imageToPost;



@end

