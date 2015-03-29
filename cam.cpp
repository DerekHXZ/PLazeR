/*
 * File:   main.cpp
 * Author: sagar
 *
 * Created on 10 September, 2012, 7:48 PM
 */

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
using namespace cv;
using namespace std;

int main() {
    VideoCapture stream1(1);   //0 is the id of video device.0 if you have only one camera.

    if (!stream1.isOpened()) { //check if video device has been initialised
        cout << "cannot open camera";
    }

    //unconditional loop
    while (true) {
        Mat cameraFrame, blurredFrame, thdFrame;
        Mat rgbFrames[3];
        stream1.read(cameraFrame);

        // cvtColor(blurredFrame, bwFrame, CV_BGR2GRAY);
        split(cameraFrame, rgbFrames);
        GaussianBlur(rgbFrames[1], blurredFrame, Size(7, 7), 3);
        threshold(blurredFrame, thdFrame, 200, 255, THRESH_BINARY);
        vector<Point> out;

        for (int i = 0; i < 480; i += 2) {
            Rect ROI(0, i, 640, 2);
            Mat m = thdFrame(ROI);
            Point min_loc, max_loc;
            double min, max;
            minMaxLoc(m, &min, &max, &min_loc, &max_loc);
            if (max) {
                Rect ROI2(max_loc.x, i, 2, 2);
                int nz = countNonZero(m);
                thdFrame(ROI) = Scalar(0,0,0);
                if (nz <= 25) {
                    thdFrame(ROI2) = Scalar(255,255,255);
                    out.push_back(Point(i, max_loc.x));
                } else {
                    out.push_back(Point(i, -1));
                }
            }
            std::cout << out << std::endl;
        }

        imshow("cam", cameraFrame);
        //imshow("blur", blurredFrame);
        imshow("bw", rgbFrames[1]);
        imshow("thd", thdFrame);

        if (waitKey(30) >= 0)
            break;

    }
    return 0;
}
