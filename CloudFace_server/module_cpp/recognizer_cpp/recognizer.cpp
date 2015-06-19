#include "opencv2/contrib/contrib.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"

#include <iostream>
#include <fstream>
#include <sstream>

using namespace cv;
using namespace std;

int main(int argc, const char *argv[]) {
    // Check for valid command line arguments, print usage
    // if no arguments were given.
    if (argc < 2) {
        cout << "usage: " << " <recognizer> <image path> <output_folder> " << endl;
        exit(1);
    }
    
    string output_folder = ".";
    if (argc == 3) {
        output_folder = string(argv[2]);
    }
    
    //
    // Now create a new Eigenfaces Recognizer
    //
    Ptr<FaceRecognizer> model = createEigenFaceRecognizer();
    model->load("eigenfaces_at.yml");
    //cout<< "加载完成" <<endl;
    
    /// Load the source image， and chage
    Mat inputImage = imread( argv[1], 0);
//    cout<< "保存输入脸图" <<endl;
//    imwrite(format("%s/inputImage.png", output_folder.c_str()), inputImage);
    
//
//    Mat grayImage = norm_0_255(inputImage);
//    //Mat grayImage = norm_0_255(inputImage);
//    cout<< "保存灰度图" <<endl;
//    imwrite(format("%s/grayImage.png", output_folder.c_str()), grayImage);
    
    Mat dst;
    resize(inputImage, dst, Size(100, 100), 0, 0, INTER_CUBIC); // resize to 92x112 resolution
//    imwrite(format("%s/test2.png", output_folder.c_str()), dst2);
//    cout<< "保存test2图" <<endl;
    
    
    // The following line predicts the label of a given
    // To get the confidence of a prediction call the model with:
    int predictedLabel = -1;
    double confidence = 0.0;
    model->predict(dst, predictedLabel, confidence);
    
    cout <<"识别结果:" << predictedLabel << endl;
    cout <<"可信度:" << confidence << endl;
    
    return predictedLabel;
}
