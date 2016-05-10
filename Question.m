//
//  Question.m
//  猜图软件
//
//  Created by 曾鹏浩 on 16/2/28.
//  Copyright © 2016年 曾鹏浩. All rights reserved.
//

#import "Question.h"
#import <UIKit/UIKit.h>

@interface Question()

@end

@implementation Question

-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        //方法一
//        self.answer=dict[@"answer"];
//        self.icon=dict[@"icon"];
//        self.title=dict[@"title"];
//        self.options=dict[@"options"];
        
        //KVC.键值编码，允许间接修改对象的属性值
        
        //方法二，第一个参数是字典的数值，第二个是类的属性
//        [self setValue:dict[@"answer"] forKey:@"answer"];
//        [self setValue:dict[@"icon"] forKey:@"icon"];
//        [self setValue:dict[@"title"] forKey:@"title"];
//        [self setValue:dict[@"options"] forKey:@"options"];
        
        //方法三，KVC,大招,等于上面四句话
        //使用setValuesForKeys要求类的属性必须在字典中存在，可以多但不能少
        [self setValuesForKeysWithDictionary:dict];
}
    return self;
}

+(instancetype) questionWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+(NSArray *)questions
{
    NSArray *array=[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil]];
    
    NSMutableArray *arrayM=[NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        [arrayM addObject:[Question questionWithDict:dict]];
    }
    return arrayM;
}

@end
