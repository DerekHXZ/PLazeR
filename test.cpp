#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"       // Basic OpenCV structures (cv::Mat)
#include "opencv2/highgui/highgui.hpp"  // Video write

#include "string.h"

using namespace cv;
using namespace std;

void calibrateCamera();
void getCameraVals();
VideoCapture cam(1);
//variables for cam camera
int brightness_slider=25;
int contrast_slider=86;
int gain_slider=77;
int saturation_slider=34;
int exposure_slider=6; //exposure range is from 0 to -7. 

int main()
{

    namedWindow("camera 1",WINDOW_AUTOSIZE);
    Mat frame;
    getCameraVals();
    createTrackbar("Brightness", "camera 1", &brightness_slider, 100);
    createTrackbar("Contrast", "camera 1", &contrast_slider, 100);
    createTrackbar("Gain", "camera 1", &gain_slider, 100);
    createTrackbar("Saturation", "camera 1", &saturation_slider, 100);
    createTrackbar("Exposure", "camera 1", &exposure_slider, 100);

    while(true)
    {
        calibrateCamera();
        cam>>frame;
        imshow("camera 1",frame);
        if(waitKey(3)>=0) break;
    }
    return(0);
}

void getCameraVals()
{
    brightness_slider = cam.get(CV_CAP_PROP_BRIGHTNESS)*100;
    /* contrast_slider = cam.get(CV_CAP_PROP_CONTRAST)*100; */
    /* gain_slider=cam.get(CV_CAP_PROP_GAIN)*100; */
    /* saturation_slider=cam.get(CV_CAP_PROP_SATURATION)*100; */
    exposure_slider=cam.get(CV_CAP_PROP_EXPOSURE)*100;

}
void calibrateCamera()
{
    cam.set(CV_CAP_PROP_BRIGHTNESS, double(brightness_slider/100));
    /* cam.set(CV_CAP_PROP_CONTRAST, double(contrast_slider/100)); */
    /* cam.set(CV_CAP_PROP_GAIN, double(gain_slider/100)); */
    /* cam.set(CV_CAP_PROP_SATURATION, double(saturation_slider/100)); */
    cam.set(CV_CAP_PROP_EXPOSURE, double(exposure_slider/100));
    //cam.set(CV_CAP_PROP_FRAME_WIDTH, 1280);
    //cam.set(CV_CAP_PROP_FRAME_HEIGHT, 720);
}
