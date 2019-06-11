#include <iostream>
using namespace std;

void ShowHelp()
{
	cout << "emc [configure file]" << endl;
	cout << "emc command computes electromagnetics." << endl;
	cout << "\t[configure file] \t A configuration file." << endl;
}

int main(const int argc, const char** const argv)
{
	if (argc <= 1)
		ShowHelp();
}