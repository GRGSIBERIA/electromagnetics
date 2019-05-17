#pragma once
#include <string>
#include <vector>

#include "datafile.h"
#include "part.h"

namespace cem
{
	class ConfigFile
	{
		DataFile file;

		std::vector<Part> parts;

		void InitializeConfigFile();

		void* ReadFile();

	public:
		ConfigFile(const char* path);
		ConfigFile(const std::string& path);
	};
}