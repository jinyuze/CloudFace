//
//  Created by 语泽思密达 on 15/6/18.
//  Copyright (c) 2015年 语泽思密达. All rights reserved.
//
// 版本 3.0: 编译在mac上（MacBook Pro Os X Yosemite 10.10.3）
// 作者：金语泽;

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/contrib/contrib.hpp>
#include <opencv2/core/core.hpp>
#include "opencv2/imgproc/imgproc_c.h"
#include <vector>
#include <utility>

#include <cctype>
#include <iostream>
#include <iterator>
#include <stdio.h>

using namespace std;
using namespace cv;

void detectionandSave(string inputImagePath, string outputImagePath1, string outputImagePath2);

string cascadeName = "./data/haarcascades/haarcascade_frontalface_alt.xml";
string nestedCascadeName = "./data/haarcascades/haarcascade_eye_tree_eyeglasses.xml";
double scale = 1.0;
bool tryflip = false;

int main( int argc, const char** argv )
{
    // Check for valid command line arguments, print usage
    // if no arguments were given.
    if (argc < 4) {
        cout << "usage: " << " <./facedetect> <input image path> <output rgb image path> <output gray image path>" << endl;
        exit(1);
    }
    
    // 检测图片的人脸，并截取人脸保持成图片
    string inputImagePath = string(argv[1]);
    string outputImagePath1 = string(argv[2]);
    string outputImagePath2 = string(argv[3]);
    detectionandSave(inputImagePath, outputImagePath1, outputImagePath2);
    
    return 0;
}


// 训练样本集，将图片中的人脸提取出来，并统一格式保存;
void detectionandSave(string inputImagePath, string outputImagePath1, string outputImagePath2)
{
    
    // 读取图像
    Mat originalImage = imread(inputImagePath, 1);
    
    // 人脸检测，并返回人脸矩形大小
    Mat img = originalImage;
    CascadeClassifier cascade, nestedCascade;
    if( !cascade.load( cascadeName ) ||!nestedCascade.load( nestedCascadeName))
    {
        cerr << "ERROR: Could not load classifier cascade or nestedCascade" << endl;
        exit(1);
    }
    
    vector<Rect> faces, faces2;
    Mat gray, smallImg( cvRound(img.rows/scale), cvRound(img.cols/scale), CV_8UC1 );
    cvtColor( img, gray, COLOR_BGR2GRAY );
    resize( gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    double t = (double)cvGetTickCount();
    cascade.detectMultiScale( smallImg, faces,
                             1.1, 2, 0
                             //|CASCADE_FIND_BIGGEST_OBJECT
                             //|CASCADE_DO_ROUGH_SEARCH
                             |CASCADE_SCALE_IMAGE
                             ,
                             Size(30, 30) );
    if( tryflip )
    {
        flip(smallImg, smallImg, 1);
        cascade.detectMultiScale( smallImg, faces2,
                                 1.1, 2, 0
                                 //|CASCADE_FIND_BIGGEST_OBJECT
                                 //|CASCADE_DO_ROUGH_SEARCH
                                 |CASCADE_SCALE_IMAGE
                                 ,
                                 Size(30, 30) );
        for( vector<Rect>::const_iterator r = faces2.begin(); r != faces2.end(); r++ )
        {
            faces.push_back(Rect(smallImg.cols - r->x - r->width, r->y, r->width, r->height));
        }
    }
    t = (double)cvGetTickCount() - t;
    
    // 记录人脸规格
    vector<Rect> Rvec = faces;
    
    // 在一张图像中，检测出所有人脸，提取出一张图像中面积最大的人脸;
    int maxxsize=0, id=-1, area;
    for (unsigned int i=0;i<Rvec.size();i++)
    {
        area = Rvec[i].width*Rvec[i].height;
        if(maxxsize<area)
        {
            maxxsize = area;
            id = i;
        }
    }
    
    // 裁剪出人脸
    Mat croppedFaceImage;
    if(id != -1)
    {
        cv::Rect myROI(Rvec[id].x, Rvec[id].y, Rvec[id].width, Rvec[id].height);
        croppedFaceImage = originalImage(myROI);
    } 
    else 
    {
        printf("该图片没有检测到人脸.");
        return;
    }
    
    // 存储原始人脸图像
    if(croppedFaceImage.size)
    {
        imwrite(format("%s", outputImagePath1.c_str()), croppedFaceImage);
        printf( "存储原始人脸图像.\r\n" );
    }
    
    // 将人脸图转成灰度图
    Mat MGrayFaceImg;
    cvtColor(croppedFaceImage, MGrayFaceImg, CV_BGR2GRAY);//转换成灰度图
    
    // 统一格式
    Mat standard;
    resize(MGrayFaceImg, standard, Size(200, 200), 0, 0, INTER_CUBIC);

    // 归一化
    Mat desMat;
    cv::normalize(standard, desMat, 0, 255, NORM_MINMAX, CV_8UC1);
    
    // 保存归一化图像
    if(desMat.size)
    {
        imwrite(format("%s", outputImagePath2.c_str()), desMat);
        printf( "存储归一化人脸图像.\r\n" );
    }
    
    printf( "该图像操作完成.\r\n" );
}




