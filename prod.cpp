#include <iostream>
#include <cmath>

using namespace std;

int main(int na, char** args)
{
	int i = 0;
	cout << "reg[15:0] sq_tbl[30:0];";
	for(i = 0; i <= 30; i++)
	{
		cout << "sq_tbl[" << i << "] = " <<  (i == 0 ? 0 : round(16940 * (95.28 / (8128 / i + 100)))) << ";" << endl;
	}
	
	cout << "reg[15:0] tnd_tbl[202:0];" << endl;
	for(i = 0; i <= 202; i++)
	{
		cout << "tnd_tbl[" << i << "] = " << (i == 0 ? 0 : round(48596 * (159.79 / (23329.161 / i + 100)))) << ";" << endl;
	}
	return 0;
}
