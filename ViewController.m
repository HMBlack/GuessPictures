//
//  ViewController.m
//  猜图软件
//
//  Created by 曾鹏浩 on 16/2/28.
//  Copyright © 2016年 曾鹏浩. All rights reserved.
//

#import "ViewController.h"
#import "Question.h"
#import <UIKit/UIKit.h>

#define kButtonW 35.0
#define kButtonH 35.0
#define kTotalCol 7
#define kButtonMargin 10.0

@interface ViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

//图片
@property (weak, nonatomic) IBOutlet UIButton *iconView;
//序号
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

//标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//分数
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;

//下一题按钮
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

//答案框
@property (weak, nonatomic) IBOutlet UIView *answerView;

//备选答案框
@property (weak, nonatomic) IBOutlet UIView *optionView;

//遮罩按钮
@property (nonatomic,strong) UIButton *cover;

//题目列表
@property (nonatomic,strong) NSArray *questions;

//题目索引
@property (nonatomic,assign) int index;
@end

@implementation ViewController

-(NSArray *)questions
{
    if (!_questions) {
        _questions=[Question questions];
    }
    return _questions;
}

-(UIButton *)cover
{
    //懒加载
    if (!_cover) {
        //1.增加蒙版(和根视图一样大小)
        //在设置子视图大小时，通常使用父视图的bounds属性，可以保证x,y一定是0
        _cover=[[UIButton alloc] initWithFrame:self.view.bounds];
        _cover.backgroundColor=[UIColor blackColor];
        _cover.alpha=0.0f;
        
        [self.view addSubview:_cover];
        
        //加监听方法
        [_cover addTarget:self action:@selector(bigImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}

-(void) viewDidLoad
{
    //如果是加载对象的父类的方法，父类方法的调用，要放在第一句
    [super viewDidLoad];
    
    self.index=-1;
    [self nextQuestion];
    
    [self questions];
}

//修改状态栏
-(UIStatusBarStyle) preferredStatusBarStyle
{
    //修改状态栏的颜色为白色
    return UIStatusBarStyleLightContent;
}

-(IBAction)tips
{
    //1.答案区的按钮都清空
    for(UIButton *btn in self.answerView.subviews)
    {
        [self answerClick:btn];
    }
    
    //2.找到正确答案的第一个字，显示到答案区的第一个按钮上
    Question *question=self.questions[self.index];
    
    //substring 方法，取字符串中的某部分
    NSString *firstWord=[question.answer substringToIndex:1];
    for(UIButton *btn in self.optionView.subviews)
    {
        if([btn.currentTitle isEqualToString:firstWord])
        {
            [self optionClick:btn];
            
            [self addScore:-500];
    
            break;
        }
    }
}

//下一题
- (IBAction)nextQuestion
{
    //1.题目索引递增
    self.index ++;
    
    if (self.index >= self.questions.count)
    {
        self.index=9;
        
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"通关了" message:@"恭喜你" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"发钱啦" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"结束" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }
    
    //2.取出索引对应的题目模型
    Question *question=self.questions[self.index];
    
    //3.设置基本信息
    [self setupBasicInfo:question];
    
    //4.创建答案按钮
    [self createAnswerButtons:question];
    
    //5.创建备选答案按钮
    [self createOptionButtons:question];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"...");
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@".");
}

//设置基本信息
-(void) setupBasicInfo:(Question *)question
{
    self.noLabel.text=[NSString stringWithFormat:@"%d/%lu",self.index +1,self.questions.count];
    self.titleLabel.text=question.title;
    [self.iconView setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];
    
    //这样数组不会超出边界而崩
    self.nextButton.enabled=(self.index!=self.questions.count-1);
}

//创建答案按钮
-(void) createAnswerButtons:(Question *)question
{
    //把答案区的按钮删除
    for(UIButton *btn in self.answerView.subviews)
    {
        [btn removeFromSuperview];
    }
    
    int length=question.answer.length;
    CGFloat answerViewW=self.answerView.bounds.size.width;
    CGFloat answerX=(answerViewW-length * kButtonW-(length-1) * kButtonMargin)*0.5;
    for (int i=0;i<length;i++)
    {
        CGFloat x=answerX+i*(kButtonW+kButtonMargin);
        UIButton *answerBtn=[[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonW, kButtonH)];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        
        [answerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.answerView addSubview:answerBtn];
        
        [answerBtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

//创建备选答案按钮
-(void) createOptionButtons:(Question *)question
{
    //判断备选区按钮的个数，如果不等于question.options.count，删除原有按钮，重新创建
    if (self.optionView.subviews.count!=question.options.count)
    {
        for(UIButton *btn in self.optionView.subviews)
        {
            [btn removeFromSuperview];
        }
        
        CGFloat optionViewW=self.optionView.bounds.size.width;
        CGFloat optionX=(optionViewW-kTotalCol*kButtonW-(kTotalCol-1)*kButtonMargin)*0.5;
        
        for (int i=0; i<question.options.count; i++)
        {
            int row=i/kTotalCol;
            int col=i%kTotalCol;
            
            CGFloat x=optionX+col * (kButtonW+kButtonMargin);
            CGFloat y=row*(kButtonMargin+kButtonH);
            
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(x, y, kButtonW, kButtonH)];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [self.optionView addSubview:btn];
            
            //添加监听方法，点击事件
            [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    //设置按钮标题，遍历optionView，依次设置每一个按钮的标题
    int  i=0;
    for (UIButton *btn in self.optionView.subviews)
    {
        //设置按钮标题
        [btn setTitle:question.options[i++] forState:UIControlStateNormal];
        //恢复所有隐藏的按钮
        btn.hidden=NO;
    }
}

//点击答案
-(void) answerClick:(UIButton *)btn
{
//    for(UIButton *button in self.optionView.subviews)
//    {
//        [button setEnabled:YES];
//    }
    
    //1.是否有文字，如果没有，直接返回
    if (btn.currentTitle.length==0) return;
    
    //2.如果有文字
    //2.1 将对应的备选按钮隐藏恢复
    for (UIButton *button in self.optionView.subviews)
    {
        if ([button.currentTitle isEqualToString:btn.currentTitle] && button.isHidden)
        {
            button.hidden=NO;
            
            //2.2清空答案按钮的文字
            [btn setTitle:nil forState:UIControlStateNormal];
            break;
        }
    }
    
    //3.点击答案按钮后，意味着答案不完整了，将所有按钮的颜色设回黑色
    for (UIButton *btn in self.answerView.subviews)
    {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

//点击备选答案
-(void) optionClick:(UIButton *)btn
{
    //1.把备选按钮文字填充到答案区
    //找答案区中第一个按钮文字为空的按钮
    for(UIButton *button in self.answerView.subviews)
    {
        if (button.currentTitle.length==0)//currentTitle(按钮当前标题)为String类型，所以length，字符串长度为0，就为空
        {
            [button setTitle:btn.currentTitle forState:UIControlStateNormal];
            break;
        }
    }
    
    //2.点击了备选按钮后隐藏
    btn.hidden=YES;
    
    //3.判断胜负
    //3.1》所以的答案按钮都填满了，遍历所有答案区的按钮
    BOOL isFull=YES;//假设已经满了
    
    //创建一个临时答案数组，供下面判断
    NSMutableString *strM=[NSMutableString string];
    
    for(UIButton *btn in self.answerView.subviews)
    {
        if (btn.currentTitle.length==0)//没有填满
        {
            isFull=NO;
            break;
        }
        else
        {
            [strM appendString:btn.currentTitle];//把答案一个个遍历到临时数组
        }
    }
    
    if(isFull)
    {
        Question *question=self.questions[self.index];
        
        if ([question.answer isEqual:strM])
        {
            //修改答案区按钮的颜色为蓝色
            for (UIButton *btn in self.answerView.subviews)
            {
                [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
            
            [self addScore:500];
            
            //等待0.5s后，调到下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
        }
        else
        {
            //修改答案区按钮的颜色为红色
            for (UIButton *btn in self.answerView.subviews)
            {
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

//加减分数
-(void) addScore:(int)score
{
    //currentTitle是字符串转整数，用intValue
    score += [[self.scoreButton titleForState:UIControlStateNormal] intValue];
    [self.scoreButton setTitle:[NSString stringWithFormat:@"%d",score]  forState:UIControlStateNormal];
}

//大图
-(IBAction)bigImage
{
    //增加蒙版
    if (self.cover.alpha==0.0)
    {
        //2.将图片移动的到视图的顶层
        [self.view bringSubviewToFront:self.iconView];
        
        //3.放大图片
        CGFloat viewW=self.view.bounds.size.width;
        CGFloat imageW=viewW;
        CGFloat imageH=imageW;
        CGFloat imageY=(self.view.bounds.size.height-imageH)*0.5;
        
        //块动画
        [UIView animateWithDuration:1.0f animations:^{
            self.cover.alpha=0.5;
            self.iconView.frame=CGRectMake(0, imageY, imageW, imageH);
        }];
    }
    else
    {
        //说明这时候图片已经是放大的了
        [UIView animateWithDuration:1.0 animations:^{
            //1.动画变小
            self.iconView.frame=CGRectMake(85, 80, 150, 150);
            //2.遮罩透明
            self.cover.alpha=0.0f;
        }];
    }
    //    首尾式动画
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:2.0f];
    //    self.iconView.frame=CGRectMake(0, imageY, imageW, imageH);
    //    [UIView commitAnimations];
}

//-(void)smallImage
//{
//    //首尾式动画
////    [UIView beginAnimations:nil context:nil];
////    [UIView setAnimationDuration:1.0f];
////    
////    //拦截首尾式动画结束的方法
////    //delegate：代理，替干活的
////    [UIView setAnimationDelegate:self];
////    //动画完成的时候，让代理去调用removeCover方法
////    [UIView setAnimationDidStopSelector:@selector(removeCover)];
//    
////    1.动画变小
////    self.iconView.frame=CGRectMake(85, 80, 150, 150);
////    self.cover.alpha=0.0f;
//    
//   // [UIView commitAnimations];
//    
//    
//    
//    //块动画
//    [UIView animateWithDuration:1.0 animations:^{
//        //1.动画变小
//        self.iconView.frame=CGRectMake(85, 80, 150, 150);
//        self.cover.alpha=0.0f;
//    } completion:^(BOOL finished) {
////    [self.cover removeFromSuperview];
//    }];
//}
@end

