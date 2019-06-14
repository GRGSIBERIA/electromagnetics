#include "report.h"

const std::string Report::_ReadAttribute(std::vector<std::string>& headers) const
{
	if (headers.size() <= 0)
		throw new NotReportException();

	const auto colon = headers[0].find_first_of(":", 0);
	return headers[0].substr(0, colon);
}

Report::Report(std::vector<std::string>& headers, std::vector<int64_t>& headerpos, std::vector<std::string>& lines)
	: _headers(headers), _attribute(_ReadAttribute(headers))
{
	
}
