#pragma once
#include <memory>
#include <string>
#include <vector>

class Report;
typedef std::shared_ptr<Report> ReportPtr;

/**
* レポートが全く記録されてないですよ
*/
class NotReportException : public std::exception {};

/**
* 無効な入力データが流れてきた
*/
class InvalidFormatException : public std::exception {};

struct Vector3
{
	double v[3];
};

/**
* 時刻歴データ
*/
class History
{
	int64_t _nodeid;
	std::vector<Vector3> _values;

public:
	History();
};

/**
* レポートの本体になるクラス
*/
class Report
{
	std::string _partname;	// パート名，抽出できれば
	std::string _attribute;	// 属性値，U，V，Aなど

	std::vector<double> _times;
	std::vector<History> _histories;

	const std::string _ReadAttribute(std::vector<std::string>& headers) const;

	const std::vector<double> _ReadTimes(const int64_t topheader, const std::vector<std::string>& lines) const;

public:

	Report(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);
};