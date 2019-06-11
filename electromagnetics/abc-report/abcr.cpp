#include "abcr.h"
#include <stdio.h>
#include <iostream>

#pragma warning(disable:6387)

const char* ReportImporter::_ReadRawData(const char* const filepath, int64_t& file_size)
{
	FILE* fp = nullptr;
	auto error = fopen_s(&fp, filepath, "rb");

	// �t�@�C�����J�����Ƃ��̃G���[�n���h�����O
	if (error != 0) {
		std::cerr << "Failed open an input file." << std::endl;
		std::cerr << filepath << std::endl;
		throw new FailedOpenFileException(filepath);
	}

	// �t�@�C���̃o�b�t�@���w�肷��
	_fseeki64(fp, 0, SEEK_END);
	file_size = _ftelli64(fp);
	char* buf = new char[file_size];
	memset(buf, 0, file_size);
	setvbuf(fp, buf, _IOFBF, file_size);

	char* rawdata = new char[file_size];
	_fseeki64(fp, 0, SEEK_SET);
	fread_s(rawdata, file_size, file_size, 1, fp);

	fclose(fp);
	delete[] buf;

	return rawdata;
}

std::vector<std::string> ReportImporter::_GetLines(const std::string& rawstr) const
{
	std::vector<std::string> lines;
	std::string line;
	line.reserve(128);

	// ���s�R�[�h�ŋ�؂�
	for (const char c : rawstr)
	{
		if (c == '\n')
		{
			lines.push_back(line);
			line.clear();
		}
		else
		{
			line.push_back(c);
		}
	}
	return lines;
}

const int64_t ReportImporter::_CountHeader(const std::vector<std::string>& lines) const
{
	int64_t count = 1;

	#pragma omp parallel for reduction(+:count)
	for (int64_t i = 0; i < lines.size(); ++i)
	{
		if (lines[i].find("  X  ") > 0)
			++count;
	}

	return count;
}

const std::vector<int64_t> ReportImporter::_MakeHeaderPositions(const std::vector<std::string>& lines) const
{
	std::vector<int64_t> retval;

	for (int64_t i = 0; i < lines.size(); ++i)
	{
		if (lines[i].find("  X  ") > 0)
			retval.push_back(i);
	}

	return retval;
}

void ReportImporter::_ReserveHeaderSpace(std::vector<std::string>& headers, const int64_t size)
{
	// �w�b�_�̗e�ʂȂǂ�\�񂵂Ă���
	headers.reserve(size);
	headers.resize(size, "");

#pragma omp parallel for
	for (int64_t i = 0; i < size; ++i)
		headers[i].reserve(128);
}

ReportImporter::ReportImporter(const char* const filepath)
	: path(filepath)
{
	// ���f�[�^����s�x�N�g���̐���
	const char* rawdata = _ReadRawData(filepath, file_size);
	std::string rawstr(rawdata);
	auto lines = _GetLines(rawstr);

	// �w�b�_�̐���
	std::vector<std::string> headers;
	std::vector<int64_t> headerpos = _MakeHeaderPositions(lines);
	_ReserveHeaderSpace(headers, headerpos.size());

	delete[] rawdata;
}
