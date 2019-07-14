#pragma once
#include <memory>
#include <string>
#include <vector>

class Report;
typedef std::shared_ptr<Report> ReportPtr;

/**
* ���|�[�g���S���L�^����ĂȂ��ł���
*/
class NotReportException : public std::exception {};

/**
* �����ȓ��̓f�[�^������Ă���
*/
class InvalidFormatException : public std::exception {};

/**
* �������f�[�^
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
* ���|�[�g�̖{�̂ɂȂ�N���X
*/
class Report
{
	std::string _partname;	//!< �p�[�g���C���o�ł����
	std::string _attribute;	//!< �����l�CU�CV�CA�Ȃ�

	std::vector<double> _times;			//!< ����
	std::vector<int64_t> _nodeids;		//!< �ߓ_�ԍ�
	std::vector<History> _histories;	//!< ������

	const std::string _ReadAttribute(std::vector<std::string>& headers) const;

	const std::vector<double> _ReadTimes(const int64_t topheader, const std::vector<std::string>& lines) const;

public:

	Report(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);

	const std::vector<double>& times() const { return _times; }

	const std::vector<int64_t>& nodeids() const { return _nodeids; }

	const std::vector<History>& histories() const { return _histories; }
};