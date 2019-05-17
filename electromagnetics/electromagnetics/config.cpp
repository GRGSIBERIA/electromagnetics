#include "config.h"
#include <stdio.h>
#include "fileutil.h"
#include <fcntl.h>



void cem::ConfigFile::InitializeConfigFile()
{
}

cem::ConfigFile::ConfigFile(const char * path)
	: file(path)
{
	InitializeConfigFile();
}

cem::ConfigFile::ConfigFile(const std::string & path)
	: file(path)
{
	InitializeConfigFile();
}
