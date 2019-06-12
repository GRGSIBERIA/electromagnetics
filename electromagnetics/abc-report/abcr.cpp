#include "abcr.h"
#include <stdio.h>
#include <iostream>

#pragma warning(disable:6387)

const char* ReportImporter::_ReadRawData(const char* const filepath, int64_t& file_size)
{
	FILE* fp = nullptr;
	auto error = fopen_s(&fp, filepath, "rb");

	// ファイルを開いたときのエラーハンドリング
	if (error != 0) {
		std::cerr << "Failed open an input file." << std::endl;
		std::cerr << filepath << std::endl;
		throw new FailedOpenFileException(filepath);
	}

	// ファイルのバッファを指定する
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
	std::vector<std::string> lines;
	std::string line;
	line.reserve(128);
	lines.resize(_CountLine(rawstr), line);
	int64_t count = 0;

	// 改行コードで区切る
	for (const char c : rawstr)
	{
		if (c == '\n')
		{
			lines[count] = line;
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
	for (int64_t i = 0; i < (int64_t)lines.size(); ++i)
	{
		if (lines[i].find("  X  ") > 0)
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
		if (lines[i].find("  X  ") > 0)
			retval.push_back(i);
	}

	return retval;
}

void ReportImporter::_ReserveHeaderSpace(std::vector<std::string>& headers, const int64_t size)
{
	// ヘッダの容量などを予約しておく
	headers.reserve(size);
	std::string basestr;
	basestr.reserve(128);
	headers.resize(size, basestr);
}

void ReportImporter::_CookingHeaders(std::vector<std::string>& headers, const std::vector<std::string>& lines, const std::vector<int64_t>& headerpos)
{
	for (int64_t i = 0; i < (int64_t)headerpos.size(); ++i)
	{
		int64_t pos = headerpos[i];
		headers[i] = lines[pos];
		--pos;

		
	}
}

ReportImporter::ReportImporter(const char* const filepath)
	: path(filepath)
{
	// 生データから行ベクトルの生成
	const char* rawdata = _ReadRawData(filepath, file_size);
	std::string rawstr(rawdata);
	auto lines = _GetLines(rawstr);
	delete[] rawdata;

	// ヘッダの生成
	std::vector<std::string> headers;
	std::vector<int64_t> headerpos = _MakeHeaderPositions(lines);
	_ReserveHeaderSpace(headers, headerpos.size());
	_CookingHeaders(headers, lines, headerpos);

	Report* rp = new Report(headers, headerpos, lines);
	report = ReportPtr(rp);
}
