#include <iostream>

void StopCode();

int main()
{
	std::cout << sizeof(size_t) << std::endl;

	StopCode();
	return 0;
}

void StopCode()
{
	char c;
	std::cin >> c;
}