/*    Steffen Urban (Karlsruhe Institute of Technology)
*     Email : urbste@googlemail.com
*     Copyright(C) 2015  Steffen Urban
*
*     This program is free software; you can redistribute it and / or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation; either version 2 of the License, or
*     (at your option) any later version.
*
*     This program is distributed in the hope that it will be useful,
*     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
*     GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License along
*     with this program; if not, write to the Free Software Foundation, Inc.,
*     51 Franklin Street, Fifth Floor, Boston, MA 02110 - 1301 USA.
*/

#ifndef CAM_MODEL_GENERAL_H
#define CAM_MODEL_GENERAL_H

#include <opencv2/opencv.hpp>

// horner scheme for evaluating polynomials at a value x
template<typename T>
T horner(T* coeffs, int s, T x)
{
	T res = 0.0;
	for (int i = s - 1; i >= 0; i--)
		res = res * x + coeffs[i];

	return res;
}

// template class implementation of the general atan model
template <typename T>
class cCamModelGeneral
{
public:
	// construtors
	cCamModelGeneral() :
		c(T(1)),
		d(T(0)),
		e(T(0)),
		u0(T(0)),
		v0(T(0)),
		p((cv::Mat_<T>(1, 1) << T(1))),
		invP((cv::Mat_<T>(1, 1) << T(1))),
		p_deg(1),
		invP_deg(1),
		Iwidth(T(0)), Iheight(T(0))
	{}

	cCamModelGeneral(cv::Vec<T, 5> cdeu0v0, 
		cv::Mat_<T> p_, 
		cv::Mat_<T> invP_) :
		c(cdeu0v0[0]),
		d(cdeu0v0[1]),
		e(cdeu0v0[2]),
		u0(cdeu0v0[3]),
		v0(cdeu0v0[4]),
		p(p_),
		invP(invP_)
	{
		// initialize degree of polynomials
		p_deg = (p_.rows > 1) ? p_.rows : p_deg = p_.cols;
		invP_deg = (p_.rows > 1) ? invP_deg = invP_.rows : invP_deg = invP_.cols;

		cde1 = (cv::Mat_<T>(2, 2) << c, d, e, T(1));
	}

	cCamModelGeneral(cv::Vec<T, 5> cdeu0v0, 
		cv::Mat_<T> p_, 
		cv::Mat_<T> invP_, 
		int Iw_, int Ih_) :
		c(cdeu0v0[0]),
		d(cdeu0v0[1]),
		e(cdeu0v0[2]),
		u0(cdeu0v0[3]),
		v0(cdeu0v0[4]),
		p(p_),
		invP(invP_),
		Iwidth(Iw_),
		Iheight(Ih_)
	{
		// initialize degree of polynomials
		p_deg = (p_.rows > 1) ? p_.rows : p_deg = p_.cols;
		invP_deg = (p_.rows > 1) ? invP_deg = invP_.rows : invP_deg = invP_.cols;

		cde1 = (cv::Mat_<T>(2, 2) << c, d, e, T(1));
	}

	~cCamModelGeneral(){}


	template <typename T> inline void
		WorldToImg(const T& x, const T& y, const T& z,    // 3D scene point
		                 T& u, T& v)					  // 2D image point
	{
		T norm = sqrt(x*x + y*y);
		if (norm == T(0))
			norm = 1e-14;

		T theta = atan(-z / norm);
		T rho = horner<T>((T*)invP.data, invP_deg, theta);

		T uu = x / norm * rho;
		T vv = y / norm * rho;

		u = uu*c + vv*d + u0;
		v = uu*e + vv + v0;

	}

	template <typename T> inline void
		WorldToImg(const cv::Point3_<T>& X,			// 3D scene point
		                 cv::Point_<T>& m)			// 2D image point
	{
		T norm = sqrt(X.x*X.x + X.y*X.y);

		if (norm == T(0))
			norm = 1e-14;

		T theta = atan(-X.z / norm);

		T rho = horner<T>((T*)invP.data, invP_deg, theta);

		T uu = X.x / norm * rho;
		T vv = X.y / norm * rho;

		m.x = uu*c + vv*d + u0;
		m.y = uu*e + vv + v0;
	}

	// fastest by about factor 2
	template <typename T> inline void
		WorldToImg(const cv::Vec<T, 3>& X,			// 3D scene point
		                 cv::Vec<T, 2>& m)			// 2D image point
	{

		double norm = cv::sqrt(X(0)*X(0) + X(1)*X(1));

		if (norm == 0.0)
			norm = 1e-14;

		double theta = atan(-X(2) / norm);

		double rho = horner<T>((T*)invP.data, invP_deg, theta);

		double uu = X(0) / norm * rho;
		double vv = X(1) / norm * rho;

		m(0) = uu*c + vv*d + u0;
		m(1) = uu*e + vv + v0;
	}

	template <typename T> inline void
		ImgToWorld(T& x, T& y, T& z,				// 3D scene point
		     const T& u, const T& v) 			    // 2D image point
	{
		T invAff = c - d*e;
		T u_t = u - u0;
		T v_t = v - v0;
		// inverse affine matrix image to sensor plane conversion
		x = (1 * u_t - d * v_t) / invAff;
		y = (-e * u_t + c * v_t) / invAff;
		T X2 = x*x;
		T Y2 = y*y;
		z = -horner<T>((T*)p.data, p_deg, sqrt(X2 + Y2));

		// normalize vectors spherically
		T norm = sqrt(X2 + Y2 + z*z);
		x /= norm;
		y /= norm;
		z /= norm;
	}

	template <typename T> inline void
		ImgToWorld(cv::Point3_<T>& X,						// 3D scene point
		     const cv::Point_<T>& m) 			            // 2D image point
	{
		T invAff = c - d*e;
		T u_t = m.x - u0;
		T v_t = m.y - v0;
		// inverse affine matrix image to sensor plane conversion
		X.x = (1 * u_t - d * v_t) / invAff;
		X.y = (-e * u_t + c * v_t) / invAff;
		T X2 = X.x*X.x;
		T Y2 = X.y*X.y;
		X.z = -horner<T>((T*)p.data, p_deg, sqrt(X2 + Y2));

		// normalize vectors spherically
		T norm = sqrt(X2 + Y2 + X.z*X.z);
		X.x /= norm;
		X.y /= norm;
		X.z /= norm;
	}

	template <typename T> inline void
		ImgToWorld(cv::Vec<T, 3>& X,						// 3D scene point
		     const cv::Vec<T, 2>& m) 			            // 2D image point
	{
		T invAff = c - d*e;
		T u_t = m(0) - u0;
		T v_t = m(1) - v0;
		// inverse affine matrix image to sensor plane conversion
		X(0) = (1 * u_t - d * v_t) / invAff;
		X(1) = (-e * u_t + c * v_t) / invAff;
		T X2 = X(0)*X(0);
		T Y2 = X(1)*X(1);
		X(2) = -horner<T>((T*)p.data, p_deg, sqrt(X2 + Y2));

		// normalize vectors spherically
		T norm = sqrt(X2 + Y2 + X(2)*X(2));
		X(0) /= norm;
		X(1) /= norm;
		X(2) /= norm;
	}

	// get functions
	T Get_c() { return c; }
	T Get_d() { return d; }
	T Get_e() { return e; }

	T Get_u0() { return u0; }
	T Get_v0() { return v0; }

	int GetInvDeg() { return invP_deg; }
	int GetPolDeg() { return p_deg; }

	cv::Mat_<T> Get_invP() { return invP; }
	cv::Mat_<T> Get_P() { return p; }

	T GetWidth() { return Iwidth; }
	T GetHeight() { return Iheight; }

	cv::Mat GetMirrorMask(int pyrL) { return mirrorMasks[pyrL]; }
	void SetMirrorMasks(std::vector<cv::Mat> mirrorMasks_) { mirrorMasks = mirrorMasks_; }

	bool isPointInMirrorMask(const T& u, const T& v, int pyr)
	{
		int ur = cvRound(u);
		int vr = cvRound(v);
		// check image bounds
		if (ur >= mirrorMasks[pyr].cols || ur <= 0 ||
			vr >= mirrorMasks[pyr].rows || vr <= 0)
			return false;
		// check mirror
		if (mirrorMasks[pyr].at<uchar>(vr, ur) > 0)
			return true;
		else return false;
	}

private:
	// affin parameters
	T c;
	T d;
	T e;
	cv::Mat_<T> cde1;
	// principal point
	T u0;
	T v0;
	// polynomial
	cv::Mat_<T> p;
	int p_deg;
	// inverse polynomial
	cv::Mat_<T> invP;
	int invP_deg;
	// image width and height
	int Iwidth;
	int Iheight;
	// mirror mask on pyramid levels
	std::vector<cv::Mat> mirrorMasks;
};


#endif