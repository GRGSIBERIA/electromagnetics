#pragma once
#include <string>

namespace cem
{
	class DataFile
	{
		std::string path;
		char* data;

		void InitializeDataFile();
		void* ReadFile();

	public:
		DataFile(const std::string& path);
		DataFile(const char* path);

		~DataFile();
	};
}