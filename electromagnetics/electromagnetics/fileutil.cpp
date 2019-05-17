#include "fileutil.h"
#include <malloc.h>

size_t cem::GetFileSize(FILE * fp)
{
	size_t size;
	size_t current;

	if (sizeof(size_t) == 8)
	{	// 64ビット環境
		current = _ftelli64(fp);
		_fseeki64(fp, 0, SEEK_END);
		size = _ftelli64(fp);
		_fseeki64(fp, current, SEEK_CUR);
	}
	else
	{	// 32ビット環境かもしれない
		current = ftell(fp);
		fseek(fp, 0, SEEK_END);
		size = ftell(fp);
		fseek(fp, current, SEEK_CUR);
	}

	return size;
}

void * cem::SetVBuf(FILE * fp, const size_t size)
{
	void* buf = malloc(size);
	setvbuf(fp, (char*)buf, _IOFBF, size);
	return buf;
}

void * cem::ReadFile(FILE * fp, size_t& size)
{
	size = cem::GetFileSize(fp);

	// バッファを設定
	void* buf = cem::SetVBuf(fp, 128 * 1024 * 1024);

	// ファイルの読み出し
	void* stream = malloc(size);
	fread_s(stream, size, size, 1, fp);

	free(buf);
	
	return stream;
}
