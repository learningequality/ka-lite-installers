#include "fle_win32_framework.h"
#include "config.h"

// Declare global stuff that you need to use inside the functions.
fle_TrayWindow * window;

fle_TrayMenuItem * menu1;
fle_TrayMenuItem * menu2;
fle_TrayMenuItem * menu3;
fle_TrayMenuItem * menu4;
fle_TrayMenuItem * menu5;
fle_TrayMenuItem * menu6;
fle_TrayMenuItem * menu7;
fle_TrayMenuItem * menu8;

bool needNotify = false;
bool isServerStarting = false;

void startServerAction()
{
	if(!runShellScript("start.bat", NULL, "ka-lite\\"))
	{
		// Handle error.
		printConsole("Failed to run the script.\n");
	}
	else
	{
		menu1->disable();
		printConsole("The script was run successfully.\n");

		needNotify = true;
		isServerStarting = true;

		window->sendTrayMessage("KA Lite", "The server is starting... please wait");
	}
}

void stopServerAction()
{
	if(!runShellScript("stop.bat", NULL, "ka-lite\\"))
	{
		// Handle error.
		printConsole("Failed to run the script.\n");
	}
	else
	{
		menu1->enable();
		menu2->disable();
		menu3->disable();
		printConsole("The script was run successfully.\n");
	}
}

void loadBrowserAction()
{
	if(!loadBrowser("http://127.0.0.1:8008/"))
	{
		// Handle error.
	}
}

void exitKALiteAction()
{
	if(ask("Exiting..." , "Really want to exit KA Lite?"))
	{
		stopServerAction();
		window->quit();
	}
}

void runUserLogsInAction()
{
	if(menu5->isChecked())
	{
		if(!runShellScript("guitools.vbs", "1", NULL))
		{
			// Handle error.
			printConsole("Failed to remove startup schortcut.\n");
		}
		else
		{
			menu5->uncheck();
			setConfigurationValue("RUN_AT_LOGIN", "FALSE");
		}
	}
	else
	{
		if(!runShellScript("guitools.vbs", "0", NULL))
		{
			// Handle error.
			printConsole("Failed to add startup schortcut.\n");
		}
		else
		{
			menu5->check();
			setConfigurationValue("RUN_AT_LOGIN", "TRUE");
		}
	}
}

void runAtStartupAction()
{
	if(menu6->isChecked())
	{
		if(!runShellScript("guitools.vbs", "5", NULL))
		{
			// Handle error.
			printConsole("Failed to remove task to run at startup.\n");
		}
		else
		{
			menu6->uncheck();
			setConfigurationValue("RUN_AT_STARTUP", "FALSE");
		}
	}
	else
	{
		if(!runShellScript("guitools.vbs", "4", NULL))
		{
			// Handle error.
			printConsole("Failed to add task to run at startup.\n");
		}
		else
		{
			menu6->check();
			setConfigurationValue("RUN_AT_STARTUP", "TRUE");
		}
	}
}

void autoStartServerAction()
{
	if(menu7->isChecked())
	{
		menu7->uncheck();
		setConfigurationValue("AUTO_START", "FALSE");
	}
	else
	{
		menu7->check();
		setConfigurationValue("AUTO_START", "TRUE");
	}
}

void checkServerThread()
{
	// We can handle things like checking if the server is online and controlling the state of each component.
	if(isServerOnline("KA Lite session", "http://127.0.0.1:8008/"))
	{
		menu1->disable();
		menu2->enable();
		menu3->enable();

		if(needNotify)
		{
			window->sendTrayMessage("KA Lite is running", "The server will be accessible locally at: http://127.0.0.1:8008/ or you can select \"Load in browser.\"");
			needNotify = false;
		}

		isServerStarting = false;
	}
	else
	{
		if(!isServerStarting)
		{
			menu1->enable();
			menu2->disable();
			menu3->disable();
		}
	}
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	startThread(NULL, TRUE, 3000, &checkServerThread);

	window = new fle_TrayWindow(&hInstance);
	window->setTrayIcon("images\\logo48.ico");

	menu1 = new fle_TrayMenuItem("Start Server.", &startServerAction);
	menu2 = new fle_TrayMenuItem("Stop Server.", &stopServerAction);
	menu3 = new fle_TrayMenuItem("Load in browser.", &loadBrowserAction);
	menu4 = new fle_TrayMenuItem("Options", NULL);
	menu5 = new fle_TrayMenuItem("Run KA Lite when the user logs in.", &runUserLogsInAction);
	menu6 = new fle_TrayMenuItem("Run KA Lite at system startup.", &runAtStartupAction);
	menu7 = new fle_TrayMenuItem("Auto-start server when KA Lite is run.", &autoStartServerAction);
	menu8 = new fle_TrayMenuItem("Exit KA Lite.", &exitKALiteAction);

	menu4->setSubMenu();
	menu4->addSubMenu(menu5);
	menu4->addSubMenu(menu6);
	menu4->addSubMenu(menu7);
	
	window->addMenu(menu1);
	window->addMenu(menu2);
	window->addMenu(menu3);
	window->addMenu(menu4);
	window->addMenu(menu8);

	menu2->disable();
	menu3->disable();

	// Load configurations.
	if(isSetConfigurationValueTrue("RUN_AT_LOGIN"))
	{
		menu5->check();
	}
	if(isSetConfigurationValueTrue("RUN_AT_STARTUP"))
	{
		menu6->check();
	}
	if(isSetConfigurationValueTrue("AUTO_START"))
	{
		menu7->check();
		startServerAction();
	}

	window->show();

	return 0;
}

