#pragma once
#include <string>
#include <vector>

class FailedOpenFileException : public std::exception 
{
public:
	std::string path;
	FailedOpenFileException(const std::string& path) : path(path), exception() {}
};

class ReportImporter
{
	std::string path;
	int64_t file_size;

private:
	const char* _ReadRawData(const char* const filepath, int64_t& file_size);
	std::vector<std::string> _GetLines(const std::string& rawstr) const;
	const int64_t _CountHeader(const std::vector<std::string>& lines) const;
	const std::vector<int64_t> _MakeHeaderPositions(const std::vector<std::string>& lines) const;
	void _ReserveHeaderSpace(std::vector<std::string>& header, const int64_t size);

public:
	
	ReportImporter(const char* const filepath);
};