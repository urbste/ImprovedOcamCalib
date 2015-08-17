#include <iostream>
#include <chrono>

#include "cam_model_general.h"

using namespace std;
using namespace cv;

double time2double(std::chrono::steady_clock::time_point start,
	std::chrono::steady_clock::time_point end)
{
	return static_cast<double>(
		std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() * (double)1e-9);
}

double dRand(double fMin, double fMax)
{
	return fMin + (double)rand() / RAND_MAX * (fMax - fMin);
}

int main()
{
	// number of iterations for speed test
	long iterations = 1e8;
	
	// take some real world cam model
	// this is the camera model of data set Fisheye1_
	// ATTENTION!! I also switched the principal point coordinates
	Vec<double, 5> interior_orientation(0.998883018922937, -0.0115128845387445,
		0.0107836324042904, 544.763473297893, 378.781825009886);
	Mat_<double> p = (Mat_<double>(5, 1) << -338.405137634369,
		0.0,
		0.00120189826837736,
		- 1.27438189154991e-06,
		2.85466623521256e-09);
	// attention: this is the reverse order of findinvpoly 
	// as matlab evaluates the polynomials differently
	Mat_<double> pInv = (Mat_<double>(11, 1) << 510.979186217526,
		291.393724562448,
		-13.8758863124724,
		42.4238251854176,
		23.054291112414,
		-7.18539785128328,
		14.1452111052043,
		18.5034196957122,
		-2.39675686593404,
		-7.18896323060144,
		-1.85081569557094);

	// here comes the camera model
	cCamModelGeneral<double> camModel(interior_orientation, p, pInv);

	// test the correctness of the implementation, at least internally
	double x0 = dRand(0, 5);
	double y0 = dRand(0, 5);
	double z0 = dRand(0, 5);

	Vec3d vec3d(x0, y0, z0);
	Vec3d vec3d_normalized = (1/norm(vec3d)) * vec3d;
	Vec2d projection;
	Vec3d unprojected;
	camModel.WorldToImg(vec3d, projection);
	cout << "projected point: " << projection << endl;

	camModel.ImgToWorld(unprojected, projection);
	cerr << "difference after unproject: " << norm(vec3d_normalized - unprojected)<< endl;

	std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
	// timings
	for (int i = 0; i < iterations; ++i)
	{
		camModel.WorldToImg(vec3d, projection);
		camModel.ImgToWorld(unprojected, projection);
	}
	std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
	cout << "total time for " << iterations << " iterations of world2cam and cam2world: " << time2double(begin, end) << " s"<<endl;
	cout << "time for one iteration: " << time2double(begin, end) / iterations * 1e9<<" nano seconds" << endl;
	return 0;
}