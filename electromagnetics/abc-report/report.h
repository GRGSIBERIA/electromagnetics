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
* �������f�[�^
*/
class History
{
	int64_t _nodeid;
	std::vector<double[3]> _values;

public:
	History();
};

/**
* ���|�[�g�̖{�̂ɂȂ�N���X
*/
class Report
{
	std::string _partname;	// �p�[�g���C���o�ł����
	std::string _attribute;	// �����l�CU�CV�CA�Ȃ�

	std::vector<std::string> _headers;

	std::vector<double> _times;
	std::vector<History> _histories;

	const std::string _ReadAttribute(std::vector<std::string>& headers) const;

public:

	Report(std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);
};