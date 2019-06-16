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
	std::string line;
	const int N = 64 + 12;
	line.reserve(N);

	// 行の数を用意する
	const int64_t count_line = _CountLine(rawstr);
	std::vector<std::string> lines(count_line, line);

	int64_t count = 0;

	// 改行コードで区切る
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
	// ヘッダの容量などを予約しておく
	headers.reserve(size);
	headers.resize(size);	// これやってもresize先で領域が確保されない
	for (auto& h : headers)
		h.reserve(128);
}

void ReportImporter::_TrimSpace(std::string& line)
{
	const char derim[] = " \t\n\r";
	
	// 左側の削除
	const auto left = line.find_first_not_of(derim);
	if (left != std::string::npos)
		line.erase(0, left);

	// 右側の削除
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
		int64_t count = lastpos;
		if (count < 0)
			count = 0;
		
		// 後ろ向きに空行を探す
		while (lines[count].size() > 4)
		{
			--count;
			if (count < 0) break;
		}
		const int64_t firstpos = count + 1;

		// firstpos -> lastpos - 1に向かってヘッダを作る
		headers[i] = "";
		for (int64_t cnt = firstpos; cnt < lastpos; ++cnt)
		{
			std::string& line = lines[cnt];
			_TrimSpace(line);
			headers[i] += line;
		}

		// lastposだけ例外的にXを取り除いたものを作る
		const auto xpos = lines[lastpos].find("  X  ");
		if (xpos != std::string::npos)
		{
			lines[lastpos].erase(0, xpos + 5);
			_TrimSpace(lines[lastpos]);
			headers[i] += lines[lastpos];
		}
	}
}

// なぜかよくわからないけど，このコード自体が実行されないので，_RejectHeaderOverMaxIdにインライン展開しました
const int64_t ReportImporter::_ExtractNodeId(const std::string& header) const
{
	const auto last_colon = header.find_last_of(":");
	char* stop;
	return strtoll(&header[last_colon], &stop, 10);
}

const std::vector<int64_t> ReportImporter::_RejectHeaderOverMaxId(std::vector<std::string>& headers, std::vector<int64_t>& headerpos)
{
	std::vector<int64_t> nodeids;
	nodeids.reserve(headers.size());

	for (int64_t i = 0; i < (int64_t)headers.size(); ++i)
	{
		char* stop;
		const auto last_colon = headers[i].find_last_of(":") + 1;
		int64_t nodeid = strtoll(&headers[i][last_colon], &stop, 10);

		if (nodeid > _maximum_nodeid)
		{
			headerpos[i] = -1;
		}
		else
		{
			nodeids.push_back(nodeid);
		}
	}

	return nodeids;
}

// headerposが-1だと使う必要のないIDなのでこれを無視するように組み替える
void ReportImporter::_ReshapeHeadersFromNodeId(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos)
{
	std::vector<std::string> reshape_headers;
	std::vector<int64_t> reshape_headerpos;
	std::string basestr;
	basestr.reserve(128);
	reshape_headers.resize(nodeids.size(), basestr);
	reshape_headerpos.resize(nodeids.size(), -1);

	int64_t count = 0;
	for (int64_t i = 0; i < (int64_t)headers.size(); ++i)
	{
		if (headerpos[i] != -1)
		{
			reshape_headerpos[count] = headerpos[i];
			reshape_headers[count].swap(headers[i]);
			++count;
		}
	}

	headers = reshape_headers;
	headerpos = reshape_headerpos;
}

ReportImporter::ReportImporter(const char* const filepath, const int64_t maximum_nodeid)
	: _path(filepath), _maximum_nodeid(maximum_nodeid)
{
	// 生データから行ベクトルの生成
	const char* rawdata = _ReadRawData(filepath, _file_size);
	std::string rawstr(rawdata);
	auto lines = _GetLines(rawstr);
	delete[] rawdata;

	// ヘッダの生成
	std::vector<std::string> headers;
	std::vector<int64_t> headerpos = _MakeHeaderPositions(lines);
	_ReserveHeaderSpace(headers, headerpos.size());
	_CookingHeaders(headers, lines, headerpos);

	// いらないヘッダを削除する
	// maximumnodeidより大きいIDのヘッダをheaderposと一緒にpopする
	std::vector<int64_t> nodeids = _RejectHeaderOverMaxId(headers, headerpos);
	_ReshapeHeadersFromNodeId(nodeids, headers, headerpos);

	Report* rp = new Report(nodeids, headers, headerpos, lines);

	_report = ReportPtr(rp);
}
