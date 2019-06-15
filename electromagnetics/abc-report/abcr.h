#pragma once
#include <string>
#include <vector>
#include <memory>
#include "report.h"

class FailedOpenFileException : public std::exception 
{
public:
	std::string path;
	FailedOpenFileException(const std::string& path) : path(path), exception() {}
};

/**
* レポートを読み込むためのクラス
*/
class ReportImporter
{
	std::string _path;
	int64_t _file_size;
	int64_t _maximum_nodeid;

	ReportPtr _report;

private:
	const char* _ReadRawData(const char* const filepath, int64_t& file_size);
	const int64_t _CountLine(const std::string& rawstr) const;
	std::vector<std::string> _GetLines(const std::string& rawstr) const;
	const int64_t _CountHeader(const std::vector<std::string>& lines) const;
	const std::vector<int64_t> _MakeHeaderPositions(const std::vector<std::string>& lines) const;
	void _ReserveHeaderSpace(std::vector<std::string>& header, const int64_t size);

	void _TrimSpace(std::string& line);

	void _CookingHeaders(std::vector<std::string>& headers, std::vector<std::string>& lines, const std::vector<int64_t>& headerpos);

	const int64_t _ExtractNodeId(const std::string& header) const;

	const std::vector<int64_t> _RejectHeaderOverMaxId(std::vector<std::string>& headers, std::vector<int64_t>& headerpos);

	void _ReshapeHeadersFromNodeId(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos);

public:
	
	ReportImporter(const char* const filepath, const int64_t maximum_nodeid);

	const std::string& path() const { return _path; }

	const ReportPtr report() const { return _report; }

	const int64_t file_size() const { return _file_size; }
};