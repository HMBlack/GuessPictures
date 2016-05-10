//
//  Question.h
//  猜图软件
//
//  Created by 曾鹏浩 on 16/2/28.
//  Copyright © 2016年 曾鹏浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property(nonatomic,copy) NSString *answer;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic,strong) NSArray *options;

//用字典实例化对象的成员方法
-(instancetype) initWithDict:(NSDictionary *)dict;

//用字典实例化对象的类方法，又称工厂方法
+(instancetype) questionWithDict:(NSDictionary *)dict;

//从plist加载对象数组
+(NSArray *) questions;



@end
