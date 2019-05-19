#include "datafile.h"
#include "fileutil.h"
#include "strutil.h"

void cem::DataFile::InitializeDataFile()
{
	size_t size;
	char* stream = (char*)ReadFile(size);
	const size_t numofLines = cem::CountReturn(stream, size) + 1;
	const char ** linePointers = StartOfLinePointers(stream, size, numofLines);

	lines = LineToStringArray(linePointers, numofLines, size);

	free(linePointers);
	free(stream);
}

void * cem::DataFile::ReadFile(size_t & size)
{
	FILE* fp;

	// ファイルを開いて全データを読み込む
	fopen_s(&fp, path.c_str(), "rb");
	void* stream = cem::ReadFile(fp, size);
	fclose(fp);

	return stream;
}

cem::DataFile::DataFile(const std::string & path)
	: path(path)
{
	InitializeDataFile();
}

cem::DataFile::DataFile(const char * path)
	: path(path)
{
	InitializeDataFile();
}

cem::DataFile::~DataFile()
{
	
}
