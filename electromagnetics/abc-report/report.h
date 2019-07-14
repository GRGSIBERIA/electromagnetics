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

/**
* 時刻歴データ
*/
class History
{
	int64_t _nodeid;
	int64_t _axisid;
	std::vector<double> _values;

	const int64_t _ExtractAxisId(const std::string& header) const;

	const double _ExtractValue(const std::string& line) const;

public:
	History();

	History(const int64_t nodeid, const int64_t numof_times, const std::string& header, const int64_t headerpos, const std::vector<std::string>& lines);

	const int64_t nodeid() const { return _nodeid; }

	const int64_t axisid() const { return _axisid; }

	const std::vector<double>& values() const { return _values; }
};

/**
* レポートの本体になるクラス
*/
class Report
{
	std::string _partname;	//!< パート名，抽出できれば
	std::string _attribute;	//!< 属性値，U，V，Aなど

	std::vector<double> _times;			//!< 時間
	std::vector<int64_t> _nodeids;		//!< 節点番号
	std::vector<History> _histories;	//!< 時刻歴

	const std::string _ReadAttribute(std::vector<std::string>& headers) const;

	const std::vector<double> _ReadTimes(const int64_t topheader, const std::vector<std::string>& lines) const;

public:

	Report(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);

	const std::vector<double>& times() const { return _times; }

	const std::vector<int64_t>& nodeids() const { return _nodeids; }

	const std::vector<History>& histories() const { return _histories; }
};