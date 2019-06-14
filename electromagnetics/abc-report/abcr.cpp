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

const int64_t ReportImporter::_CountLine(const std::string& rawstr) const
{
	int64_t count = 1;

	#pragma omp parallel for reduction(+:count)
	for (int64_t i = 0; i < (int64_t)rawstr.size(); ++i)
	{
		if (rawstr[i] == '\n')
			++count;
	}
	
	return count;
}

std::vector<std::string> ReportImporter::_GetLines(const std::string& rawstr) const
{
	std::string line;
	const int N = 64 + 12;
	line.resize(N);

	// �s�̐���p�ӂ���
	const int64_t count_line = _CountLine(rawstr);
	std::vector<std::string> lines(count_line, line);

	int64_t count = 0;

	// ���s�R�[�h�ŋ�؂�
	for (const char c : rawstr)
	{
		if (c == '\n')
		{
			lines[count] = line;
			line.clear();
			++count;
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
	for (int64_t i = 0; i < (int64_t)lines.size(); ++i)
	{
		if (lines[i].find("  X  ") != std::string::npos)
			++count;
	}

	return count;
}

const std::vector<int64_t> ReportImporter::_MakeHeaderPositions(const std::vector<std::string>& lines) const
{
	std::vector<int64_t> retval;
	retval.reserve(_CountHeader(lines));

	for (int64_t i = 0; i < (int64_t)lines.size(); ++i)
	{
		if (lines[i].find("  X  ") != std::string::npos)
			retval.push_back(i);
	}

	return retval;
}

void ReportImporter::_ReserveHeaderSpace(std::vector<std::string>& headers, const int64_t size)
{
	// �w�b�_�̗e�ʂȂǂ�\�񂵂Ă���
	headers.reserve(size);
	std::string basestr;
	basestr.reserve(128);
	headers.resize(size, basestr);	// �������Ă�resize��ŗ̈悪�m�ۂ���Ȃ�
}

void ReportImporter::_TrimSpace(std::string& line)
{
	const char derim[] = " \t\n\r";
	
	// �����̍폜
	const auto left = line.find_first_not_of(derim);
	if (left != std::string::npos)
		line.erase(0, left);

	// �E���̍폜
	const auto right = line.find_last_not_of(derim);
	if (right != std::string::npos)
		line.erase(right + 1, line.size());
}

void ReportImporter::_CookingHeaders(std::vector<std::string>& headers, std::vector<std::string>& lines, const std::vector<int64_t>& headerpos)
{
	#pragma omp parallel for
	for (int64_t i = 0; i < (int64_t)headerpos.size(); ++i)
	{
		const int64_t lastpos = headerpos[i];
		int64_t count = lastpos - 1;
		if (count < 0)
			count = 0;
		
		// �������ɋ�s��T��
		while (lines[count].size() > 4)
		{
			--count;
			if (count < 0) break;
		}
		const int64_t firstpos = count + 1;

		// firstpos -> lastpos - 1�Ɍ������ăw�b�_�����
		for (int64_t cnt = firstpos; cnt < lastpos; ++cnt)
		{
			_TrimSpace(lines[cnt]);
			headers[i] += lines[cnt];
		}

		// lastpos������O�I��X����菜�������̂����
		const auto xpos = lines[lastpos].find("  X  ");
		if (xpos != std::string::npos)
		{
			lines[lastpos].erase(0, xpos + 5);
			_TrimSpace(lines[lastpos]);
			headers[i] += lines[lastpos];
		}
	}
}

ReportImporter::ReportImporter(const char* const filepath)
	: _path(filepath)
{
	// ���f�[�^����s�x�N�g���̐���
	const char* rawdata = _ReadRawData(filepath, _file_size);
	std::string rawstr(rawdata);
	auto lines = _GetLines(rawstr);
	delete[] rawdata;

	// �w�b�_�̐���
	std::vector<std::string> headers;
	std::vector<int64_t> headerpos = _MakeHeaderPositions(lines);
	_ReserveHeaderSpace(headers, headerpos.size());
	_CookingHeaders(headers, lines, headerpos);

	Report* rp = new Report(headers, headerpos, lines);

	_report = ReportPtr(rp);
}
