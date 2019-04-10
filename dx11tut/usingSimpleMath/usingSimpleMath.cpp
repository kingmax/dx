// usingSimpleMath.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include "pch.h"
#include <iostream>
#include <d3d11.h>
#include <SimpleMath.h>
using namespace std;
using namespace DirectX::SimpleMath;

ostream& printMatrix(const Matrix& mat, ostream& os = cout)
{
	os << mat._11 << ", " << mat._12 << ", " << mat._13 << ", " << mat._14 << ", " << endl
		<< mat._21 << ", " << mat._22 << ", " << mat._23 << ", " << mat._24 << ", " << endl
		<< mat._31 << ", " << mat._32 << ", " << mat._33 << ", " << mat._34 << ", " << endl
		<< mat._41 << ", " << mat._42 << ", " << mat._43 << ", " << mat._44 << ", " << endl;
	return os;
}

ostream &printVector3(const Vector3 &vec, ostream &os = cout)
{
	os << "(" << vec.x << ", " << vec.y << ", " << vec.z << ")" << endl;
	return os;
}

ostream& printQuaternion(const Quaternion &quat, ostream &os = cout)
{
	os << "(" << quat.x << ", " << quat.y << ", " << quat.z << ", " << quat.w << ")" << endl;
	return os;
}


int main()
{
    std::cout << "Hello SimpleMath!\n"; 

	cout << "Vectors:" << endl;
	Vector3 up(0, 1.f, 0);
	Vector3 left(1.f, 0, 0);
	float dot = up.Dot(left);
	cout << dot << endl;
	Vector3 forward = up.Cross(left);
	cout << "(" << forward.x << ", " << forward.y << ", " << forward.z << ")" << endl;
	printVector3(up);

	cout << "\nMatrices:" << endl;
	Matrix a(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
	Matrix b(1, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 23, 42, 0, 1);
	Matrix c = a * b;
	printMatrix(c);
	Matrix mat;
	printMatrix(mat);

	cout << "\nQuaternions:" << endl;
	Quaternion qa(0.707107f, 0, 0, 0.707107f);
	printQuaternion(qa);
	Quaternion qb(0, 0.707107f, 0, 0.707107f);
	Quaternion qc = Quaternion::Slerp(qa, qb, 0.25f);
	printQuaternion(qc);
	cout << qa.Length() << endl;

	//system("pause");
	getchar();
}

// 运行程序: Ctrl + F5 或调试 >“开始执行(不调试)”菜单
// 调试程序: F5 或调试 >“开始调试”菜单

// 入门提示: 
//   1. 使用解决方案资源管理器窗口添加/管理文件
//   2. 使用团队资源管理器窗口连接到源代码管理
//   3. 使用输出窗口查看生成输出和其他消息
//   4. 使用错误列表窗口查看错误
//   5. 转到“项目”>“添加新项”以创建新的代码文件，或转到“项目”>“添加现有项”以将现有代码文件添加到项目
//   6. 将来，若要再次打开此项目，请转到“文件”>“打开”>“项目”并选择 .sln 文件
