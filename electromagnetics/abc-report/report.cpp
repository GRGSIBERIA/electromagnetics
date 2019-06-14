#include "report.h"
#include <stdio.h>

const std::string Report::_ReadAttribute(std::vector<std::string>& headers) const
{
	if (headers.size() <= 0)
		throw new NotReportException();

	const auto colon = headers[0].find_first_of(":", 0);
	return headers[0].substr(0, colon);
}

const std::vector<double> Report::_ReadTimes(const int64_t topheader, const std::vector<std::string>& lines) const
{
	int64_t lineid = topheader + 2;
	int64_t numof_times = 0;
	
	while (lines[lineid].size() > 4)
	{
		++lineid;
		++numof_times;
	}

	lineid = topheader + 2;
	std::vector<double> times;
	times.resize(numof_times);

	for (int64_t i = 0; i < numof_times; ++i)
	{
		double unuse;
		std::string str = lines[lineid + i];
		const auto _ = sscanf_s(str.data(), "%lf %lf", &times[i], &unuse);
	}

	return times;
}

Report::Report(std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines)
{
	_attribute = _ReadAttribute(headers);
	_times = _ReadTimes(headerpos[0], lines);

}

History::History():
	_nodeid(-1), _values()
{
}
