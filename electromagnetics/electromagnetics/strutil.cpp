#include "strutil.h"
#include <malloc.h>

void cem::ZeroClear(char * str, const size_t size)
{
	// SIMDの呼び出しを期待する
	size_t mod = size % 8;
	size_t num = size / 8;

	#pragma omp parallel for
	for (size_t i = 0; i < num; ++i)
	{
		((double *)str)[i] = 0;
	}

	for (size_t i = 0; i < mod; ++i)
	{
		str[num * 8 + i] ^= str[num * 8 + i];
	}
}

const size_t cem::CountReturn(const char * str, const size_t size)
{
	size_t count = 0;

	#pragma omp parallel for reduction(+:count)
	for (size_t i = 0; i < size; ++i)
	{
		if (str[i] == '\n')
			++count;
	}

	return count;
}

const size_t cem::LineOfMaxLength(const char * str, const size_t size)
{
	size_t count = 0;
	size_t max = 0;

	for (size_t i = 0; i < size; ++i)
	{
		if (str[i] == '\n')
		{
			if (count > max)
				max = count;
			count = 0;
		}
		else
		{
			++count;
		}
	}

	return max;
}
