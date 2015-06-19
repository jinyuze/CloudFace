//
//  recognizeViewController.m
//  SantaFace
//
//  Created by 语泽思密达 on 15/6/10.
//  Copyright (c) 2015年 DevBridge. All rights reserved.
//

#import "recognizeViewController.h"
#import "ViewController.h"
#import "uploadImage.h"

@interface recognizeViewController ()

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, strong) UIImageView *faceImageView;
@property (strong, nonatomic) uploadImage *upload;

@end

@implementation recognizeViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 设置背景颜色
    self.view.backgroundColor=[UIColor whiteColor];
    
    //在子视图控制器中设置一个按钮，用来点击返回主视图控制器
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backbtn.frame=CGRectMake(self.view.frame.size.width/2-150, self.view.frame.size.height-45, 300, 30);
    [backbtn setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:189.0/255.0 blue:204.0/255.0 alpha:1.0]];
    backbtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [backbtn setTitle:@"返回" forState:UIControlStateNormal];
    [backbtn setTintColor:[UIColor whiteColor]];
    [backbtn addTarget:self action:@selector(backToButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbtn];

    //
    int x = 10;
    int y = 0;
    int width = self.view.frame.size.width - 20;
    int height = width * 4/3;
    _imageView =[[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageView setImage:_image];
    [self.view addSubview:_imageView];
    
    //在子视图控制器中设置一个textView，用来显示识别出人物信息
    x = 10;
    y = height+5;
    width = self.view.frame.size.width - 20;
    height = self.view.frame.size.height - y - 55;
    _textview = [[UITextView alloc] initWithFrame:CGRectMake(x,y,width,height)];//初始化并定义大小
    _textview.backgroundColor=[UIColor orangeColor]; //背景色
    _textview.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
    _textview.editable = NO;        //是否允许编辑内容，默认为“YES”
    // _textview.delegate = self;       //设置代理方法的实现类
    _textview.font=[UIFont fontWithName:@"Arial" size:18.0]; //设置字体名字和字体大小;
    _textview.returnKeyType = UIReturnKeyDefault;//return键的类型
    _textview.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textview.textAlignment = NSTextAlignmentCenter; //文本显示的位置
    _textview.dataDetectorTypes = UIDataDetectorTypeAll; //显示数据类型的连接模式（如电话号码、网址、地址等）
    _textview.textColor = [UIColor blackColor];
    [self.view addSubview:_textview];
    
    // NSLog(@"con2 image size = %@",NSStringFromCGSize(_image.size));
    
    // Do any additional setup after loading the view.
    // 初始化
    self.upload = [[uploadImage alloc] init];
    _textview.text = @"正在查询...";
    
}


- (void) viewDidAppear:(BOOL)animated{
    // 上传图片
    
    [self.upload sendImageToServer:_image];
    
    // 接受信息，并展示
    NSString * receiveInfo = self.upload->responseString;
    _textview.text = receiveInfo;//设置显示的文本内容
    

}

// 点击“返回”按钮，返回主界面
- (IBAction)backToButton:(id)sender {
    _textview.text = @"正在查询...";
    //用dismissViewControllerAnimated解除关闭这个模式对话窗口即相当于跳转返回
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//}
//
//-(void)backTo{
//    
//    //以下方式是打开新的模式对话窗口的形式来跳转，这样的跳转其实不是返回，而只是打开一个新的，不建议这么做
//    //ViewController *mainvc=[[ViewController alloc]init];
//    //[self presentViewController:mainvc animated:YES completion:^{
//    //
//    //}];
//}

@end
