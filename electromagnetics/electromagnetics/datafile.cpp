#include "datafile.h"
#include "fileutil.h"

void cem::DataFile::InitializeDataFile()
{
	char* stream = (char*)ReadFile();
}

void * cem::DataFile::ReadFile()
{
	FILE* fp;
	size_t size;

	// ファイルを開いて全データを読み込む
	fopen_s(&fp, path.c_str(), "rb");
	void* stream = cem::ReadFile(fp);
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
