#pragma once
#include <string>
#include <vector>

namespace cem
{
	// 文字列をゼロクリアする
	void ZeroClear(char* str, const size_t size);

	// 改行の個数を返す，行数は+1する
	const size_t CountReturn(const char* str, const size_t size);

	// 最も長い行を探す
	const size_t LineOfMaxLength(const char * str, const size_t size);

	// 行頭のポインタ配列を返す
	const char** StartOfLinePointers(const char * str, const size_t size, const size_t numofLines);

	// 行ごとに区切った文字列の配列を返す
	std::vector<std::string> LineToStringArray(const char ** linePointers, const size_t numofLines, const size_t size);
}