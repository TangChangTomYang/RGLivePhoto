//
//  ViewController.m
//  RGLivePhoto
//
//  Created by yangrui on 2018/12/29.
//  Copyright © 2018 yangrui. All rights reserved.
/  https://blog.csdn.net/findhappy117/article/details/82732247
//  https://blog.csdn.net/qq_30143179/article/details/81093453




#import "ViewController.h"
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) PHLivePhotoView *livePhotoView;
@end

@implementation ViewController

-(PHLivePhotoView *)livePhotoView{
    if (!_livePhotoView) {
        _livePhotoView= [[PHLivePhotoView alloc] initWithFrame:self.view.bounds];
        _livePhotoView.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:_livePhotoView];
    }
    return  _livePhotoView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self jump2ChooseLivePhotoView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self playLivePhoto];
}

-(void)stopLivePhoto{
    [self.livePhotoView stopPlayback];
}

-(void)playLivePhoto{
    
    //PhotosUI框架为我们提供了两种LivePhoto的动态效果，一种为持续数秒，第二种为全部循环展示。
    if (self.livePhotoView.livePhoto != nil) {
        // 动图 循环动
        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        // 动图 播放一次
        //        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }
}


#pragma mark- 从相册获取livePhoto
-(void)jump2ChooseLivePhotoView{
    
    UIImagePickerController *pickerCtr = [[UIImagePickerController alloc] init] ;
    pickerCtr.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerCtr.delegate = self;
    
    //如果报错,就导入MobileCoreServices 框架
    NSArray *mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeLivePhoto];
    pickerCtr.mediaTypes = mediaTypes;
    [self  presentViewController:pickerCtr animated:YES completion:nil];
}




#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    
    PHLivePhoto *livePhoto = info[UIImagePickerControllerLivePhoto];
    if (livePhoto != nil) { // 动图
        
        self.livePhotoView.livePhoto = livePhoto;
        NSLog(@"-------选择了动图--------");
    }
    else{
        NSLog(@"--------没有选择动图----------");
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark- 从服务器请求生成一张LivePhoto
/**PHLivePhoto
 
 livePhoto 实际上是由一张 jpg图片 和一段mov视频的组合, 想要从网络获取livePhoto
 后台应该是以一张图片对应一段视频的方式存储 livePhoto,
 手机端通过网络下载好对应的图片和视频之后, 利用系统 Photos.framework 中提供的方法将图片合成PHLivePhoto
 之后通过PPHPhotoUI 中的PHLivePhotoView 来展示PPHLiveView对象, 或者通过PHAssetCreateRequest 保存livePhoto 到相册
 */
-(void)httpRequestCreateLivePhoto{
    
    NSURL *movieUrl ;
    NSURL *imageUrl;
    NSArray *urlArr = @[movieUrl,imageUrl ];
    UIImage *placeHolder;
    CGSize targetSize ;
    PHImageContentMode contentMode;
    // 从服务器端 请求一段视频 加上 图片, 系统生成PHLivePhoto
    __weak typeof(self) weakSelf = self;
    PHLivePhotoRequestID livePhotoRequestID = [PHLivePhoto requestLivePhotoWithResourceFileURLs:urlArr placeholderImage:placeHolder targetSize:targetSize contentMode:contentMode resultHandler:^(PHLivePhoto *  livePhoto, NSDictionary * info) {
        
        if (livePhoto != nil) {
            self.livePhotoView.livePhoto = livePhoto;
        }
        
    }];
}


-(void)saveLivePhoto{
    
    NSURL *imageUrl;
    NSURL *videoUrl;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest * req = [PHAssetCreationRequest creationRequestForAsset];
        [req addResourceWithType:PHAssetResourceTypePhoto fileURL:imageUrl options:nil];
        [req addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoUrl options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"已保存至相册");
        }else
        {
            NSLog(@"已保存至相册");
        }
    }];
    
    
}


@end
