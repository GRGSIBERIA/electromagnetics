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

Report::Report(const std::vector<int64_t>& nodeids, std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines)
	: _nodeids(nodeids), _histories()
{
	_attribute = _ReadAttribute(headers);
	_times = _ReadTimes(headerpos[0], lines);

	_histories.reserve(_nodeids.size());
	for (int64_t i = 0; i < (int64_t)_nodeids.size(); ++i)
	{
		_histories.emplace_back(nodeids[i], (int64_t)_times.size(), headers[i], headerpos[i], lines);
	}
}

History::History()
	: _values(), _nodeid(-1)
{
}

const int64_t History::_ExtractAxisId(const std::string& header) const
{
	const auto left = header.find_first_of(" ");
	return (int64_t)header[left - 1] - 48;
}

const double History::_ExtractValue(const std::string& line) const
{
	const auto left = line.find_first_not_of(" ");
	const auto center = line.find(" ", left);
	return std::strtod(&line[center], nullptr);
}

History::History(const int64_t nodeid, const int64_t numof_times, const std::string& header, const int64_t headerpos, const std::vector<std::string>& lines)
	: _nodeid(nodeid), _axisid(_ExtractAxisId(header))
{
	_values.resize(numof_times);

	int64_t count = headerpos + 2;
	for (int i = 0; i < numof_times; ++i)
	{
		const std::string& line = lines[count];
		double value = _ExtractValue(line);
		_values[i] = value;

		++count;
	}
}
