#pragma once
#include <string>
#include <vector>

namespace cem
{
	class DataFile
	{
		std::string path;
		std::vector<std::string> lines;

		void InitializeDataFile();
		void* ReadFile(size_t& size);

	public:
		DataFile(const std::string& path);
		DataFile(const char* path);

		~DataFile();
	};
}