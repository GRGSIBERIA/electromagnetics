#include "strutil.h"
#include <malloc.h>
#include <intrin.h>

void cem::ZeroClear(char * str, const size_t size)
{
	// SIMDの呼び出しを期待する
	double * ptr = (double*)str;
	size_t mod = size % 8;
	size_t num = size / 8;

	#pragma omp parallel for
	for (size_t i = 0; i < num; ++i)
	{
		// 0の代入は不確定要素大きいので直接SIMDでXORかけることにした
		__m128d reg;
		reg = _mm_load_pd(&ptr[i]);
		reg = _mm_xor_pd(reg, reg);
		_mm_store1_pd(&ptr[i], reg);
	}

	for (size_t i = 0; i < mod; ++i)
	{
		str[num * 8 + i] ^= str[num * 8 + i];
	}
}

const size_t cem::CountReturn(const char * str, const size_t size)
{
	size_t count = 0;

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

const char ** cem::StartOfLinePointers(const char * str, const size_t size, const size_t numofLines)
{
	const char ** linePtrs = (const char **)malloc(sizeof(char *) * numofLines);
	size_t count = 1;

	linePtrs[0] = &str[0];
	for (size_t i = 1; i < size; ++i)
	{
		// CRがあるなら文字列の先頭がCRになる
		if (str[i] == '\n')
		{
			linePtrs[count] = &str[i + 1];
			++count;
		}
	}

	return linePtrs;
}

std::vector<std::string> cem::LineToStringArray(const char ** linePointers, const size_t numofLines, const size_t size)
{
	std::vector<std::string> lines;
	lines.resize(numofLines);

	size_t count = 0;

	for (size_t i = 0; i < numofLines - 1; ++i)
	{
		// 文字列の長さを探索する
		lines.emplace_back(linePointers[i], linePointers[i-1]);

		count = 0;
	}

	// 最終行を追加する
	lines.emplace_back(linePointers[numofLines - 1], linePointers[0] + size - 1);

	return lines;
}

