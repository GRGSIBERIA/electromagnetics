#include <iostream>
#include "abcr.h"
using namespace std;

void ShowHelp()
{
	cout << "abcr [report file]" << endl;
	cout << "abcr command converts an abaqus report file to normalized report file." << endl;
	cout << "\t[report file] \t An abaqus report file." << endl;
}

int main(const int argc, const char** const argv)
{
	if (argc <= 1)
		ShowHelp();

	auto importer = ReportImporter(argv[1], 1600);
}