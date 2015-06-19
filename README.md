# CloudFace
基于opencv和云端的ios人脸检测系统

使用手册：整次实验完成在 OS  X Yosemite 10.10.3 上

1. CloudFace_ios 文件夹：安装在手机上的程序。

a. 适配手机：	iPhone 6
b. 编译器：	Xcode Version 6.3.2 (6D2105)
c. 编程语言：	object-C
d. 程序功能：	
手机摄像头人脸检测
拍照
截取人脸
人脸显示
上传人脸图片
返回图片查询信息结果

2. CloudFace_server 文件夹：
|
\_  WebFaceRecogServer 文件夹：server端运行人脸识别程序
|	
|		a. 编译语言：Python
|		b. 实验环境：安装 opencv with Python on mac 步骤如下：
|					- 安装 home brew
|						ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
|					- 安装opencv with python
|						#brew install python
|						brew tap homebrew/science
|						brew install opencv
|					- 将opencv 连接到现有库
|						cd /Library/Python/2.7/site-packages
|						ln -s /usr/local/Cellar/opencv/2.4.11_1/lib/python2.7/site-packages/cv.py cv.py
|						ln -s /usr/local/Cellar/opencv/2.4.11_1/lib/python2.7/site-packages/cv2.so cv2.so
|
|		c. 程序功能：
|					server端运行人脸识别程序
|						加载训练好的model，只加载一次
|						接收人脸图片
|						预测人脸信息
|						返回预测结果
|
\_  module_cpp 文件夹：
’	|
|	\_ detectAndCutFaces_cpp 文件夹：检测并截取人脸
|	|
|	|	a. 编程语言：C++
|	| 	b. 实验环境：OS  X Yosemite 10.10.3
|	|			      opencv opencv-2.4.11 安装方法：http://blogs.wcode.org/2014/10/howto-install-build-and-use-opencv-macosx-10-10/
|	|	c. 程序功能：
|	|				图片人脸检测
|	|				人脸截取，并存储
|	|				转换成灰度图，并归一化，并存储
|	|	d. 程序输入输出：
|	|				输入一张图片
|	|				输出一张rgb人脸图像，归一化灰度图
|	|	e. 说明：
|	|		模块中的模块
|	|			
|	|
|	\_ recognizer_cpp 文件夹：功能与 faceRecogServer 文件夹相同	|	|
|	|		a. 编程语言：C++
|	|		b. 说明：不被采用，model需要多次加载
|	|				
|	\_ trainingModel 文件夹： 训练Model
|	|
|	|		a. 编程语言：C++
|	| 		b. 实验环境：OS  X Yosemite 10.10.3
|	|			      	      opencv opencv-2.4.11 安装方法：http://blogs.wcode.org/2014/10/howto-install-build-and-use-opencv-macosx-10-10/
|	|		c. 程序功能：
|	|				根据.csv文件，人脸图像训练Model
|	\_
|
\_ module_python 文件夹：批量检测人脸，并生产csv文件
|	|
|	\_ detectFaceAndSaveCSV_python 文件夹
|	|	a. 编程语言：C++ & Python
| 	|	b. 实验环境：OS  X Yosemite 10.10.3
|	|		                opencv opencv-2.4.11 安装方法：http://blogs.wcode.org/2014/10/howto-install-build-and-use-opencv-macosx-10-10/
|	|	c. 程序功能：
|	|			Python语言，在逐个文件夹下读取图片	|	|			图片人脸检测
|	|			人脸截取，并存储
|	|			转换成灰度图，并归一化，并存储
|	|			将人脸图片生成对应 imagePath_Label 的csv文件
\____\_____________________________________________________________________________________________________________________












