#pragma once
#include <string>
#include <vector>

#include "part.h"

namespace cem
{
	class ConfigFile
	{
		std::string path;

		std::vector<Part> parts;

	public:
		ConfigFile(const char* path);
		ConfigFile(const std::string& path);
	};
}