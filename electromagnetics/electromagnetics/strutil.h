#pragma once

namespace cem
{
	// 文字列をゼロクリアする
	void ZeroClear(char* str, const size_t size);

	// 改行の個数を返す
	const size_t CountReturn(const char* str, const size_t size);

	// 最も長い行を探す
	const size_t LineOfMaxLength(const char * str, const size_t size);
}