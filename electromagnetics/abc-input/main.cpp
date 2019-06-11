#include <iostream>
using namespace std;

void ShowHelp()
{
	cout << "abci [input file]" << endl;
	cout << "The convert an abaqus input file to normalized"
	cout << "\t [input file] \t An abaqus input file.";

}

int main(int argc, const char** const argv)
{
	if (argc <= 1)
		ShowHelp();
}