#pragma once
#include <memory>
#include <string>
#include <vector>

class Report;
typedef std::shared_ptr<Report> ReportPtr;

/**
* レポートの本体になるクラス
*/
class Report
{
	int64_t numof_headers;
	std::string partname;

	std::vector<std::string> headers;

	std::vector<double> times;
	std::vector<double[3]> histories;
public:

	Report(std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);
};