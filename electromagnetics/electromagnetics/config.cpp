#include "config.h"

cem::ConfigFile::ConfigFile(const char * path)
	: path(path)
{

}

cem::ConfigFile::ConfigFile(const std::string & path)
	: path(path)
{
}
