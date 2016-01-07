#ifndef config
#define config
#include <ShlObj.h>
#include <Strsafe.h>

#define FILE_BUFFER_SIZE 2048

int readConfigurationFileBuffer(char* const& resultConfigurationBuffer);
int writeConfigurationFileBuffer(const char* const configurationBuffer);
bool compareKeys(const char* const key1, const char* const key2);
int extractValue(const char* const configurationBuffer, const char* const targetKey, char* const& resultValue, int const resultValueArraySize);
int searchKeyIndex(const char* const configurationBuffer, const char* const targetKey);
int addValue(const char* const configurationBuffer, const char* const targetKey, const char* const value, char* const& resultConfigurationBuffer, int const resultConfigurationBufferSize);
int formatResultBuffer(const char* const configurationBuffer, char* const& resultConfigurationBuffer, const int resultBufferSize);
int isSetConfigurationValueTrue(const char* const targetKey);
int setConfigurationValue(const char* const targetKey, const char* const value);
int joinPath(LPCTSTR const path1, LPCTSTR const path2, LPTSTR const& resultBuffer, const UINT resBuffLen);
int getConfigFilePath(LPTSTR const& resultBuffer, const UINT resBuffLen);


/*
*	Read the configuration file to some buffer.
*	:param char* const& resultConfigurationBuffer: The buffer into which the configuration file is read.
*	:returns int: 0 indicating success, or 1 indicating failure
*/
int readConfigurationFileBuffer(char* const& resultConfigurationBuffer)
{
	HANDLE hFile;
	DWORD bytesRead = 0;
	char readConfigurationBuffer[FILE_BUFFER_SIZE];
	TCHAR configFilePath[MAX_PATH];

	getConfigFilePath(configFilePath, MAX_PATH);

	hFile = CreateFile(configFilePath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

	if(hFile == INVALID_HANDLE_VALUE)
	{
		// Fails to open the file but continues and create one.
		CloseHandle(hFile);
		return 1;
	}

	if(ReadFile(hFile, readConfigurationBuffer, (FILE_BUFFER_SIZE-1), &bytesRead, NULL) == FALSE)
	{
		MessageBox(NULL, L"Failed to read the config file", L"Error", MB_OK | MB_ICONERROR);
		CloseHandle(hFile);
		return 1;
	}

	if(bytesRead > 0 && bytesRead <= (FILE_BUFFER_SIZE - 1))
	{
		readConfigurationBuffer[FILE_BUFFER_SIZE-1] = '\0';
		int i = 0;
		int j = 0;
		while(readConfigurationBuffer[i]!='\0')
		{
			if( readConfigurationBuffer[i]!=' ' && 
				(readConfigurationBuffer[i]>=65 && readConfigurationBuffer[i]<=122) ||
				readConfigurationBuffer[i]==':' ||
				readConfigurationBuffer[i]==';' ||
				(readConfigurationBuffer[i]>=48 && readConfigurationBuffer[i]<=57) ||
				readConfigurationBuffer[i] == '#' )
			{
				resultConfigurationBuffer[j] = readConfigurationBuffer[i];
				j++;
			}	
			i++;
		}
		resultConfigurationBuffer[j] = '\0';

		CloseHandle(hFile);
		return 0;
	}
	else if( bytesRead == 0)
	{
		resultConfigurationBuffer[0] = '\0';
		CloseHandle(hFile);
		return 0;
	}
	else
	{
		MessageBox(NULL, L"Unexpected value", L"Error", MB_OK | MB_ICONERROR);
		CloseHandle(hFile);
		return 1;
	}
	CloseHandle(hFile);
	return 1;
}


/*
*	Gets a user-specific config file path. Creates directories if necessary.
*	:param LPTSTR const& resultBuffer: A string buffer where the path will be stored.
*	:param const UINT resBuffLen: the buffer length
*	:return int: 0 for success, 1 for error
*/
int getConfigFilePath(LPTSTR const& resultBuffer, const UINT resBuffLen)
{
	TCHAR basePath[MAX_PATH];
	LPCTSTR const kaliteSubdir = TEXT("KA Lite");
	LPCTSTR const filename = TEXT("CONFIG.dat");

	if (FAILED(SHGetFolderPath(NULL, CSIDL_APPDATA, NULL, SHGFP_TYPE_CURRENT, basePath))) {
		return 1;
	}

	joinPath(basePath, kaliteSubdir, resultBuffer, resBuffLen);
	int create_result = CreateDirectory(resultBuffer, NULL);
	if (!create_result && GetLastError() != ERROR_ALREADY_EXISTS ) {
		return 1;
	}

	TCHAR cpy[MAX_PATH];
	StringCchCopy(cpy, MAX_PATH, resultBuffer);
	joinPath(cpy, filename, resultBuffer, resBuffLen);
	return 0;
}



/*
*	Join two path strings. Handles leading & terminating "/" characters well enough.
*	:param LPCTSTR path1, LPCTSTR path2: The two componenets to join.
*	:param LPTSTR resultBuffer: A buffer to hold the result.
*	:param const UINT resBuffLen: The length of the resultBuffer.
*	:return int: 0 for success, 2 if resultBuffer is not long enough.
*/
int joinPath(LPCTSTR const path1, LPCTSTR const path2, LPTSTR const& resultBuffer, const UINT resBuffLen)
{
	if (resBuffLen < 2) { // Must be at least length 1 to be the empty null-terminated string
		return 2;
	}
	resultBuffer[0] = TEXT('\0');
	
	const TCHAR sep = TEXT('\\');
	int path1len;
	if (path1[lstrlen(path1) - 1] == sep) {
		path1len = lstrlen(path1) - 1;
	}
	else {
		path1len = lstrlen(path1);
	}

	if (FAILED(StringCchCatN(resultBuffer, resBuffLen, path1, path1len))) {
		return 2;
	}

	if (FAILED(StringCchCatN(resultBuffer, resBuffLen, TEXT("\\"), 1))) {
		return 2;
	}

	int path2offset;
	if (path2[0] == sep) {
		path2offset = 1;
	}
	else {
		path2offset = 0;
	}
	
	if (FAILED(StringCchCatN(resultBuffer, resBuffLen, &path2[path2offset], lstrlen(&path2[path2offset])))) {
		return 2;
	}

	return 0;
}



/*
*	Write the configuration file from some buffer.
*	:param const char* const configurationBuffer: The buffer from which the configuration file is written.
*	:returns int: 0 indicating success, or 1 indicating failure
*/
int writeConfigurationFileBuffer(const char* const configurationBuffer)
{
	HANDLE hFile;
	DWORD bytesToWrite = (DWORD) strlen(configurationBuffer);
	DWORD bytesWritten = 0;
	BOOL errorFlag = FALSE;
	TCHAR configFilePath[MAX_PATH];

	getConfigFilePath(configFilePath, MAX_PATH);

	hFile = CreateFile(configFilePath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

	if(hFile == INVALID_HANDLE_VALUE)
	{
		MessageBox(NULL, L"Failed to create config file", L"Error", MB_OK | MB_ICONERROR);
		CloseHandle(hFile);
		return 1;
	} else { 

		errorFlag = WriteFile(hFile, configurationBuffer, bytesToWrite, &bytesWritten, NULL);

		if(FALSE == errorFlag)
		{
			MessageBox(NULL, L"Failed to write to config file", L"Error", MB_OK | MB_ICONERROR);
			CloseHandle(hFile);
			return 1;
		}

		CloseHandle(hFile);
		return 0;
	}
	CloseHandle(hFile);
}



/*
*	Compare two buffers.
*	:param const char* const key1, key2: The two string buffers to compare.
*	:returns bool: true if the strings have the same content, otherwise false.
*/
bool compareKeys(const char* const key1, const char* const key2)
{
	return strcmp(key1, key2) == 0 ? true : false;
}



/*
*	Extract the value of a key from a buffer if that key is in the buffer.
*	:param const char* const configurationBuffer: The string buffer to read from.
*	:param const char* const targetKey: The string we're searching for.
*	:char* const& resultValue: String buffer to hold result value.
*	:int const resultValueArraySize: The size of the resultValue array.
*
*	:returns int: 0 for success, 1 if the targetKey is not found, 2 if the resultValue buffer is not long enough.
*/
int extractValue(const char* const configurationBuffer, const char* const targetKey, char* const& resultValue, int const resultValueArraySize)
{
	int tempIndex = 0;
	int index = searchKeyIndex(configurationBuffer, targetKey);

	if (index == -1) return 1;

	while(configurationBuffer[index++] != ':');

	while(configurationBuffer[index] != ';')
	{
		resultValue[tempIndex] = configurationBuffer[index];
		index++;
		tempIndex++;
	}
	resultValue[tempIndex] = '\0';
	return 0;
}



/*
*	Return the index of a key in a buffer if it exists.
*	:param const char* const configurationBuffer: The string buffer to search.
*	:param const char* const targetKey: The key to search for.
*	:returns int: The index in configurationBuffer where the targetKey starts if found, otherwise -1.
*/
int searchKeyIndex(const char* const configurationBuffer, const char* const targetKey)
{
	char * resultValueBuffer = (char*)malloc(sizeof(char) * FILE_BUFFER_SIZE);
	int i = 0;
	int j = 0;
	int lowIndex = 0;
	int highIndex = 0;
	int resultBufferIndex = 0;
	bool ignoreFound = FALSE;

	for(i=0; i<FILE_BUFFER_SIZE; i++)
	{
		if(configurationBuffer[i] == '#')
		{
			ignoreFound = TRUE;
		}

		if(ignoreFound)
		{
			if(configurationBuffer[i] == ';')
			{
				ignoreFound = FALSE;
				lowIndex = i;
				resultBufferIndex = 0;
			}
		}
		else
		{
			if(configurationBuffer[i] == ';')
			{
				for(j=lowIndex; j<=highIndex; j++)
				{
					if(configurationBuffer[j] == ';')
					{
						lowIndex = i+1;
						resultBufferIndex = 0;
						continue;
					}

					if(configurationBuffer[j] ==':')
					{
						resultValueBuffer[resultBufferIndex] = '\0';

						if(compareKeys(resultValueBuffer, targetKey))
						{
							return j;
						}
						else
						{
							lowIndex = i+1;
							resultBufferIndex = 0;
							break;
						}					
					}
					else
					{
						resultValueBuffer[resultBufferIndex] = configurationBuffer[j];
						resultBufferIndex++;
					}				
				}			
			}
		}
		highIndex++;		
	}
	return -1;
}



/*
*	Updates the value of the given key in a configuration buffer, or add it if it doesn't exist.
*	:param const char* const configurationBuffer: The buffer to be searched
*	:param const char* const targetKey: The key we're looking to update.
*	:param const char* const value: The updated value to be set.
*	:param char* const& resultConfigurationBuffer: Another buffer which will hold the updated buffer -- the original cofigurationBuffer is not modified.
*	:param int const resultConfigurationBufferSize: the size of resultConfigurationBuffer.
*
*	:returns int: 0 on success, 1 if the targetKey or value strings are empty, 2 if resultConfigurationBuffer is not long enough.
*/
int addValue(const char* const configurationBuffer, const char* const targetKey, const char* const value, char* const& resultConfigurationBuffer, int const resultConfigurationBufferSize)
{
	const int key_size = (unsigned)strlen(targetKey);
	const int value_size = (unsigned)strlen(value);

	if(key_size == 0 || value_size == 0) return 1;

	int keyIndex = 0;
	char * writeBuffer = (char*)malloc(sizeof(char) * FILE_BUFFER_SIZE);
	keyIndex = searchKeyIndex(configurationBuffer, targetKey);

	int tempIndex = 0;
	int tempUpdateIndex = 0;
	int i = 0;

	if(keyIndex == -1)
	{
		while( configurationBuffer[i] != '\0' )
		{
			resultConfigurationBuffer[i] = configurationBuffer[i];
			i++;
		}
		while( targetKey[tempIndex] != '\0' )
		{
			resultConfigurationBuffer[i] = targetKey[tempIndex];
			i++;
			tempIndex++;
		}
		resultConfigurationBuffer[i] = ':';
		i++;
		tempIndex = 0;
		while( value[tempIndex] != '\0' )
		{
			resultConfigurationBuffer[i] = value[tempIndex];
			i++;
			tempIndex++;
		}
		resultConfigurationBuffer[i] = ';';
		i++;
		resultConfigurationBuffer[i] = '\0';

		return 0;
	}


	for(i=0;i<keyIndex;i++)
	{
		resultConfigurationBuffer[i] = configurationBuffer[i];
	}

	resultConfigurationBuffer[i] = ':';
	i++;
	tempUpdateIndex = i;
	for(tempIndex=0; tempIndex<value_size; tempIndex++)
	{
		if(value[tempIndex] == '\0') break;
		resultConfigurationBuffer[tempUpdateIndex] = value[tempIndex];
		tempUpdateIndex++;
	}

	resultConfigurationBuffer[tempUpdateIndex] = ';';
	tempIndex = tempUpdateIndex;
	while(configurationBuffer[i]!=';')
	{
		i++;
	}

	for(i=i; i<FILE_BUFFER_SIZE; i++)
	{
		if(configurationBuffer[i] == '\0') break;
		resultConfigurationBuffer[tempIndex] = configurationBuffer[i];
		tempIndex++;
	}
	resultConfigurationBuffer[tempIndex] = '\0';

	return 0;
}



/*
*	Prepare the buffer for file writing.
*	:param const char* const configurationBuffer: The input buffer to be prepared.
*	:param char* const& resultConfigurationBuffer: Another buffer to hold the output.
*	:param const int resultBufferSize: The size of resultConfigurationBuffer.
*
*	:returns int: 0 on success, 2 if resultConfigurationBuffer is not long enough.
*/
int formatResultBuffer(const char* const configurationBuffer, char* const& resultConfigurationBuffer, const int resultBufferSize)
{
	int i = 0;
	int tempIndex = 0;
	while(configurationBuffer[i]!='\0' && i<FILE_BUFFER_SIZE)
	{
		resultConfigurationBuffer[tempIndex] = configurationBuffer[i];
		if(resultConfigurationBuffer[tempIndex] == ';')
		{
			tempIndex++;
			resultConfigurationBuffer[tempIndex] = (char)'\r\n';
		}
		i++;
		tempIndex++;
	}

	resultConfigurationBuffer[tempIndex] = '\0';
	return 0;
}



/*
*	Read key from configuration file.
*	:param const char* const targetKey: The key to check.
*	:returns int: TRUE if the file has the key and it's set to "TRUE", otherwise FALSE. TRUE and FALSE are defined by preprocessor directives.
*/
int isSetConfigurationValueTrue(const char* const targetKey)
{
	char configurationFileBuffer[FILE_BUFFER_SIZE];

	const int resultValueBufferSize = 10; 
	char resultValue[resultValueBufferSize];

	if(readConfigurationFileBuffer(configurationFileBuffer) == 1) return 1;	

	if(extractValue(configurationFileBuffer, targetKey, resultValue, resultValueBufferSize) == 1)
	{
		if(setConfigurationValue(targetKey, "FALSE") == 1)
		{
			MessageBox(NULL, L"Failed to set the configuration option", L"Error", MB_OK | MB_ICONERROR);
		}
		return FALSE;
	}

	if(compareKeys(resultValue, "TRUE"))
	{
		return TRUE;
	}

	return FALSE;
}



/*
*	Write a key-value pair to the configuration file.
*	:param const char* const targetKey, value: The key-value pair strings to be written.
*	:reutns int: 0 on success, 1 on any other error.
*/
int setConfigurationValue(const char* const targetKey, const char* const value)
{
	char configurationFileBuffer[FILE_BUFFER_SIZE];
	char resultConfigurationBuffer[FILE_BUFFER_SIZE];
	char formatedResultConfigurationBuffer[FILE_BUFFER_SIZE];

	if(readConfigurationFileBuffer(configurationFileBuffer) == 1) return 1;

	if(addValue(configurationFileBuffer, targetKey, value, resultConfigurationBuffer, FILE_BUFFER_SIZE) == 1) return 1;

	formatResultBuffer(resultConfigurationBuffer, formatedResultConfigurationBuffer, FILE_BUFFER_SIZE);

	if(writeConfigurationFileBuffer(formatedResultConfigurationBuffer) == 1) return 1;

	return 0;
}


#endif