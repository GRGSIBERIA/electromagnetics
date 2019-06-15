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

struct Vector3
{
	double v[3];
};

/**
* �������f�[�^
*/
class History
{
	int64_t _nodeid;
	std::vector<Vector3> _values;

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

	std::vector<double> _times;
	std::vector<History> _histories;

	const std::string _ReadAttribute(std::vector<std::string>& headers) const;

	const std::vector<double> _ReadTimes(const int64_t topheader, const std::vector<std::string>& lines) const;

public:

	Report(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines);
};