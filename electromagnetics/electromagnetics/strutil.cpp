#include "strutil.h"

size_t cem::CountReturn(const char * str, const size_t size)
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
