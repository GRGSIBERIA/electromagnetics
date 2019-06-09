#include <iostream>
#include <string>
#include <vector>
using namespace std;

void ShowHelp()
{
	cout << "abc-time <report file> <output path>" << endl;
	cout << "abc-time command is extract a time define file from an abaqus report file." << endl;
	cout << "\t<report file>\t: An abaqus report file." << endl;;
	cout << "\t<output path>\t: An output file path." << endl;
}

std::vector<std::string> MakeVectorArgument(const int argc, const char** const argv)
{
	std::vector<std::string> retval;
	retval.reserve(argc);

	for (size_t i = 0; i < argc; ++i)
		retval.emplace_back(argv[i]);

	return retval;
}

int main(int argc, const char** const argv)
{
	if (argc <= 1)
		ShowHelp();

	auto commands = MakeVectorArgument(argc, argv);

	return 0;
}