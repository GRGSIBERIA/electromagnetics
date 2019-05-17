#include "part.h"

cem::Part::Part(const char * name, const char * path)
	: name(name), file(path)
{
}

cem::Part::Part(const std::string & name, const std::string & path)
	: name(name), file(path)
{
}
