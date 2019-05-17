#pragma once
#include <string>

namespace cem
{
	class Part
	{
		std::string name;
		std::string path;

	public:
		Part(const char* name, const char* path);
		Part(const std::string& name, const std::string& path);
	};
}