#include "datafile.h"
#include "fileutil.h"
#include "strutil.h"

void cem::DataFile::InitializeDataFile()
{
	char* stream = (char*)ReadFile();
	const size_t numofLines = cem::CountReturn(stream, size) + 1;
	const size_t lineOfMaxLength = cem::LineOfMaxLength(stream, size);

	dataSize = sizeof(char) * numofLines * lineOfMaxLength;
	data = (char*)malloc(dataSize);
	ZeroClear(data, dataSize);
}

void * cem::DataFile::ReadFile()
{
	FILE* fp;

	// ファイルを開いて全データを読み込む
	fopen_s(&fp, path.c_str(), "rb");
	void* stream = cem::ReadFile(fp, size);
	fclose(fp);

	return stream;
}

cem::DataFile::DataFile(const std::string & path)
	: path(path), data(nullptr)
{
	InitializeDataFile();
}

cem::DataFile::DataFile(const char * path)
	: path(path), data(nullptr)
{
	InitializeDataFile();
}

cem::DataFile::~DataFile()
{
	if (data != nullptr)
		free(data);
}
