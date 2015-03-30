#ifndef config
#define config

#define FILE_BUFFER_SIZE                            2048



/*
*	Functions declaration.
*/
int readConfigurationFileBuffer(char * resultConfigurationBuffer);
int writeConfigurationFileBuffer(char * configurationBuffer);
bool compareKeys(const char * key1, const char * key2);
int extractValue(const char * configurationBuffer, const char * targetKey, char * resultValue, int resultValueArraySize);
int searchKeyIndex(const char * configurationBuffer, const char * targetKey);
int addValue(const char * configurationBuffer, const char * targetKey, const char * value, char * resultConfigurationBuffer, int resultConfigurationBufferSize);
void formatResultBuffer(const char * configurationBuffer, char * resultConfigurationBuffer);
int getConfigurationValue(char * targetKey, char * resultValue, int resultValueBufferSize);
int setConfigurationValue(const char * targetKey, const char * value);


/*
*	Read the configuration file to some buffer.
*/
int readConfigurationFileBuffer(char * resultConfigurationBuffer)
{
	HANDLE hFile;
	DWORD bytesRead = 0;
	char readConfigurationBuffer[FILE_BUFFER_SIZE];

	hFile = CreateFile(L"CONFIG.dat", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

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
*	Write the configuration file from some buffer.
*/
int writeConfigurationFileBuffer(char * configurationBuffer)
{
	HANDLE hFile;
	DWORD bytesToWrite = (DWORD) strlen(configurationBuffer);
	DWORD bytesWritten = 0;
	BOOL errorFlag = FALSE;

	hFile = CreateFile(L"CONFIG.dat", GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

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
*/
bool compareKeys(const char * key1, const char * key2)
{
	const int key1_size = (unsigned)strlen(key1);
	const int key2_size = (unsigned)strlen(key2);

	if(key1_size != key1_size) return false;

	int size_test = 0;

	while( (*key1++ == *key2++) && (size_test < key1_size) )
	{
		size_test++;
	}

	if( (size_test == key1_size) && (size_test == key2_size) ) return true;
	return false;
}



/*
*	Extract the value of a key if that key exists.
*/
int extractValue(const char * configurationBuffer, const char * targetKey, char * resultValue, int resultValueArraySize)
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
*	Return the index of a key if it exists.
*/
int searchKeyIndex(const char * configurationBuffer, const char * targetKey)
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
*	Updates the value of the given key or add it if it doesn't exist.
*/
int addValue(const char * configurationBuffer, const char * targetKey, const char * value, char * resultConfigurationBuffer, int resultConfigurationBufferSize)
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
*/
void formatResultBuffer(char * configurationBuffer, char * resultConfigurationBuffer)
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
}



/*
*	Read key from configuration file.
*/
int isSetConfigurationValueTrue(char * targetKey)
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
*	General write key to configuration file.
*/
int setConfigurationValue(const char * targetKey, const char * value)
{
	char configurationFileBuffer[FILE_BUFFER_SIZE];
	char resultConfigurationBuffer[FILE_BUFFER_SIZE];
	char formatedResultConfigurationBuffer[FILE_BUFFER_SIZE];

	if(readConfigurationFileBuffer(configurationFileBuffer) == 1) return 1;

	if(addValue(configurationFileBuffer, targetKey, value, resultConfigurationBuffer, FILE_BUFFER_SIZE) == 1) return 1;

	formatResultBuffer(resultConfigurationBuffer, formatedResultConfigurationBuffer);

	if(writeConfigurationFileBuffer(formatedResultConfigurationBuffer) == 1) return 1;

	return 0;
}


#endif