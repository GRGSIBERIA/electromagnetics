#pragma once
#include <string>
#include "datafile.h"

namespace cem
{
	class Part
	{
		std::string name;
		DataFile file;

	public:
		Part(const char* name, const char* path);
		Part(const std::string& name, const std::string& path);
	};
}