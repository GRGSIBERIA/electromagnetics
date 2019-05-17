#pragma once
#include <stdio.h>

namespace cem
{
	size_t GetFileSize(FILE* fp);

	void* SetVBuf(FILE* fp, const size_t size);

	void* ReadFile(FILE* fp);
}