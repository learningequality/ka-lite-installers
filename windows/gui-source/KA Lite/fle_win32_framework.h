#ifndef fle_win32_framework
#define fle_win32_framework

#include <Windows.h>
#include <stdio.h>
#include <map>
#include "Shlwapi.h"
#include "wininet.h"

#pragma comment(lib, "Wininet")

using namespace std;

#define ID_TRAY_APP_ICON 5000
#define WM_TRAYICON ( WM_USER + 1 )

//GLOBAL and structs

static UINT CURRENT_VALID_ID = WM_TRAYICON + 1;


// GLOBAL functions
UINT getAvailableID();

TCHAR* getTCHAR(char * original)
{
	if(original != NULL)
	{
		size_t SIZE = strlen(original) + 1;
		TCHAR * tchar_string = new TCHAR[SIZE];
		size_t convertedChars = 0;
		mbstowcs_s(&convertedChars, tchar_string, SIZE, original, _TRUNCATE);
		return tchar_string;
	}
	return NULL;
}

UINT getAvailableID()
{
	CURRENT_VALID_ID++;
	return CURRENT_VALID_ID;
}

// CLASS
class fle_BaseWindow;
class fle_TrayMenuItem
{
	private:
		HMENU hMenu;
		HMENU *parent_hMenu;
		UINT id;
		TCHAR * title;
		void (*f_action)(void);
		UINT menuType;
		HWND* p_window;
	public:
		fle_TrayMenuItem(char*, void (*action_function)(void));
		void action(void);
		UINT getID(void);
		TCHAR* getTitle(void);
		void addSubMenu(fle_TrayMenuItem*);
		HMENU getMenu(void);
		void setSubMenu(void);
		UINT getMenuType(void);
		void check(void);
		void uncheck(void);
		void toogleChecked(void);
		bool isChecked(void);
		void enable(void);
		void disable(void);
		void toogleEnabled(void);
		bool isEnabled(void);
		HMENU * getParentMenu(void);
		void setParentMenu(HMENU*);
		void setWindow(HWND*);
		HWND* getWindow(void);
};

fle_TrayMenuItem::fle_TrayMenuItem(char * m_title, void (*action_function)(void))
{
	hMenu = CreatePopupMenu();
	p_window = NULL;
	id = getAvailableID();
	title = getTCHAR(m_title);
	f_action = action_function;
	menuType = MF_STRING;

	CheckMenuItem(hMenu, id, MF_CHECKED);
}

void fle_TrayMenuItem::action(void)
{
	if(f_action != NULL)
	{
		f_action();
	}
}

UINT fle_TrayMenuItem::getID()
{
	return this->id;
}

TCHAR* fle_TrayMenuItem::getTitle()
{
	return this->title;
}

HMENU fle_TrayMenuItem::getMenu()
{
	return this->hMenu;
}

void fle_TrayMenuItem::setSubMenu()
{
	this->menuType = MF_STRING | MF_POPUP;
}

UINT fle_TrayMenuItem::getMenuType()
{
	return this->menuType;
}

void fle_TrayMenuItem::check()
{
	CheckMenuItem(*getParentMenu(), (UINT)getMenu(), MF_CHECKED);
	if(getWindow() != NULL)
	{
		RedrawWindow(*getWindow(), NULL, NULL, RDW_INVALIDATE|RDW_ALLCHILDREN|RDW_FRAME|RDW_ERASE);
	}
}

void fle_TrayMenuItem::uncheck()
{
	CheckMenuItem(*getParentMenu(), (UINT)getMenu(), MF_UNCHECKED);
	if(getWindow() != NULL)
	{
		RedrawWindow(*getWindow(), NULL, NULL, RDW_INVALIDATE|RDW_ALLCHILDREN|RDW_FRAME|RDW_ERASE);
	}
}

void fle_TrayMenuItem::toogleChecked()
{
	if(this->isChecked())
	{
		this->uncheck();
	}
	else
	{
		this->check();
	}
}

bool fle_TrayMenuItem::isChecked()
{
	UINT result = GetMenuState(*getParentMenu(), (UINT)getMenu(), MF_BYCOMMAND);

	if(result & MF_CHECKED)
	{
		return true;
	}
	return false;
}

void fle_TrayMenuItem::enable()
{
	EnableMenuItem(*getParentMenu(), (UINT)getMenu(), MF_ENABLED);
	if(getWindow() != NULL)
	{
		RedrawWindow(*getWindow(), NULL, NULL, RDW_INVALIDATE|RDW_ALLCHILDREN|RDW_FRAME|RDW_ERASE);
	}
}

void fle_TrayMenuItem::disable()
{
	EnableMenuItem(*getParentMenu(), (UINT)getMenu(), MF_DISABLED | MF_GRAYED);
	if(getWindow() != NULL)
	{
		RedrawWindow(*getWindow(), NULL, NULL, RDW_INVALIDATE|RDW_ALLCHILDREN|RDW_FRAME|RDW_ERASE);
	}
}

void fle_TrayMenuItem::toogleEnabled()
{
	if(this->isEnabled())
	{
		this->disable();
	} 
	else
	{
		this->enable();
	}
}

bool fle_TrayMenuItem::isEnabled()
{
	UINT result = GetMenuState(*getParentMenu(), (UINT)getMenu(), MF_BYCOMMAND);

	if(!(result & (MF_DISABLED | MF_GRAYED)))
	{
		return true;
	}
	return false;
}

HMENU * fle_TrayMenuItem::getParentMenu()
{
	return this->parent_hMenu;
}

void fle_TrayMenuItem::setParentMenu(HMENU * parent)
{
	this->parent_hMenu = parent;
}

void fle_TrayMenuItem::setWindow(HWND * window)
{
	this->p_window = window;
}

HWND* fle_TrayMenuItem::getWindow()
{
	return this->p_window;
}





class fle_BaseWindow
{
	private:
		HINSTANCE * p_hInstance;
		WNDCLASSEX * p_wc;
		static HWND hwnd;

		static void (*main_loop_function)(void);
		static HMENU hMenu;
		static std::map<UINT, fle_TrayMenuItem*> tray_children_map;
		static LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
	public:
		fle_BaseWindow(HINSTANCE*, int, int, TCHAR*, TCHAR*);
		void show(void);
		void test(void);
		static HWND& getWindowReference(void);
		HINSTANCE* getInstanceReference(void);
		static void processTrayMenu(WPARAM, LPARAM, HWND*, HMENU*, fle_BaseWindow*);
		static HMENU& getMainMenu(void);
		static void addTrayMenu(fle_TrayMenuItem*);
		static std::map<UINT, fle_TrayMenuItem*>& getTrayMap(void);
		static void setMainLoopFunction(void (*main_loop_function)(void));
		static void quit(void);

};

std::map<UINT, fle_TrayMenuItem*> &fle_BaseWindow::getTrayMap()
{
	return fle_BaseWindow::tray_children_map;
}

fle_BaseWindow::fle_BaseWindow(HINSTANCE * hInstance, int WIDTH, int HEIGHT, TCHAR * CLASS_NAME, TCHAR * TITLE)
{
	p_hInstance = hInstance;
	WNDCLASSEX wc = { 0 };
	hMenu = CreatePopupMenu();

	// Registering the window class.
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.lpfnWndProc = &fle_BaseWindow::WndProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = *p_hInstance;
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH) COLOR_APPWORKSPACE;
	wc.lpszClassName = CLASS_NAME;
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.hIcon = NULL;
	wc.hIconSm = NULL;

	p_wc = &wc;

	if(!RegisterClassEx(&wc)){
		MessageBox(NULL, L"Failed to register the window.", L"Error", MB_ICONEXCLAMATION | MB_OK);
	}

	// Creating the window.
	DWORD windowStyle = WS_OVERLAPPED | WS_MINIMIZEBOX | WS_SYSMENU;
	this -> hwnd = CreateWindowEx(NULL, CLASS_NAME, TITLE, windowStyle, CW_USEDEFAULT, CW_USEDEFAULT, WIDTH, HEIGHT, NULL,  NULL, *p_hInstance, this);	

	if(hwnd == NULL){
		MessageBox(NULL, L"Failed to create the window.", L"Error", MB_ICONEXCLAMATION | MB_OK);
	}

	tray_children_map = map<UINT, fle_TrayMenuItem*>();
}

HWND& fle_BaseWindow::getWindowReference()
{
	return fle_BaseWindow::hwnd;
}

HINSTANCE * fle_BaseWindow::getInstanceReference()
{
	return this->p_hInstance;
}

LRESULT CALLBACK fle_BaseWindow::WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	fle_BaseWindow * p_Window;


	if(fle_BaseWindow::main_loop_function != NULL)
	{
		fle_BaseWindow::main_loop_function();
	}

	if(msg == WM_NCCREATE)
	{
		p_Window = static_cast<fle_BaseWindow*>(reinterpret_cast<CREATESTRUCT*>(lParam)->lpCreateParams);

		SetLastError(0);
		if(!SetWindowLongPtr(hwnd, GWL_USERDATA, reinterpret_cast<LONG_PTR>(p_Window)))
		{
			if(GetLastError() != 0)
			{
				return false;
			}
		}
	}
	else
	{
		p_Window = reinterpret_cast<fle_BaseWindow*>(GetWindowLongPtr(hwnd, GWL_USERDATA));
	}

	switch(msg)
		{
			/*case WM_INITDIALOG:
				{
					//SetTimer(hwnd, 500, 500, NULL);
				}
				break;

			case WM_TIMER:
				{
					if(wParam == 500)
					{
						InvalidateRect(hwnd, NULL, FALSE);
					}
				}
				break;
				
			case WM_PAINT:
				{
					PAINTSTRUCT ps;
					BeginPaint(hwnd, &ps);
					EndPaint(hwnd, &ps);
				}
				break;

			case WM_CREATE:
				{
			
				}
				break;
				*/
			case WM_COMMAND:
				{
					/*switch(LOWORD(wParam))
						{
							//case ID_MINIMIZE_BUTTON:
							//case ID_OPEN_IN_BROWSER:
							//case ID_OPTIONS_RUNUSERLOGIN:
							//case ID_OPTIONS_RUNSTARTUP:
							//case ID_OPTIONS_AUTOMINIMIZE:
							//case ID_OPTIONS_AUTOSTART:
							//case ID_HELP_ABOUT:
							//case ID_FILE_EXIT:
							//case ID_STUFF_GO:
						}*/
				}
				break;

			case WM_TRAYICON:
				{
					processTrayMenu(wParam, lParam, &hwnd, &getMainMenu(), p_Window);
				}
				break;

			/*case WM_NCHITTEST:
				{
				}
				break;*/

			case WM_CLOSE:
				{
					PostQuitMessage(0);
				}
				break;

			/*case WM_DESTROY:
				{

				}
				break;
				*/
			default:
				{
					return DefWindowProc(hwnd, msg, wParam, lParam);
				}
		}

	return 0;
};

void fle_BaseWindow::processTrayMenu(WPARAM wParam, LPARAM lParam, HWND * hwnd, HMENU * hMenu, fle_BaseWindow * p_Window)
{
	switch(wParam)
		{
			case ID_TRAY_APP_ICON:
			// Its the ID_TRAY_APP_ICON. One app can have several tray icons
			break;
		}

	// React when the mouse button is released.
	if (lParam == WM_LBUTTONUP)
	{
		p_Window->test();
	}
	else if (lParam == WM_RBUTTONDOWN) 
	{
		// Show the context menu.
		// Get current mouse position.
		POINT curPoint ;
		GetCursorPos(&curPoint);

		// Sets the main window in foreground.
		SetForegroundWindow(*hwnd);        

		// TrackPopupMenu blocks the application until TrackPopupMenu returns.
		UINT clicked = TrackPopupMenu(
			*hMenu,
			TPM_RETURNCMD | TPM_NONOTIFY, // Don't send WM_COMMAND messages about this window, instead return the identifier of the clicked menu item.
			curPoint.x,
			curPoint.y,
			0,
			*hwnd,
			NULL
			);



		for (std::map<UINT,fle_TrayMenuItem*>::iterator it=tray_children_map.begin(); it!=tray_children_map.end(); ++it) 
		{
			if(clicked == it->first)
			{
				(it->second)->action();
			}
		}
	}		  
};

HMENU& fle_BaseWindow::getMainMenu()
{
	return fle_BaseWindow::hMenu;
};

void fle_BaseWindow::addTrayMenu(fle_TrayMenuItem * menu)
{
	if(menu != NULL && menu->getID() != NULL && menu->getTitle() != NULL)
	{
		menu->setWindow(&getWindowReference());
		menu->setParentMenu(&getMainMenu());
		AppendMenu(getMainMenu(), menu->getMenuType(), (UINT)menu->getMenu(), menu->getTitle());
		tray_children_map.insert(std::pair<UINT, fle_TrayMenuItem*>((UINT)menu->getMenu(), menu));
	}
}

void fle_BaseWindow::test()
{
	static const TCHAR * str = TEXT("WELCOME FLE FRAMEWORKKKKKKKKKK\n");
    OutputDebugString(str);
};

void fle_BaseWindow::setMainLoopFunction(void (*target_function)(void))
{
	fle_BaseWindow::main_loop_function = target_function;
}

void fle_BaseWindow::quit()
{
	PostQuitMessage(0);
}

HWND fle_BaseWindow::hwnd;
HMENU fle_BaseWindow::hMenu;
std::map<UINT, fle_TrayMenuItem*> fle_BaseWindow::tray_children_map;
void (*fle_BaseWindow::main_loop_function)(void);



void fle_TrayMenuItem::addSubMenu(fle_TrayMenuItem * menu)
{
	menu->setParentMenu(&hMenu);
	menu->setWindow(getWindow());
	AppendMenu(hMenu, menu->getMenuType(), (UINT)menu->getMenu(), menu->getTitle());
	fle_BaseWindow::getTrayMap().insert(std::pair<UINT, fle_TrayMenuItem*>((UINT)menu->getMenu(), menu));
}



class fle_TrayWindow : public fle_BaseWindow
{
	private:
		NOTIFYICONDATA *notifyIconData;
		HINSTANCE * p_hInstance;
		HMENU hMenu;
	public:
		fle_TrayWindow(HINSTANCE*);
		NOTIFYICONDATA* getNotifyIconDataStructure(void);
		HINSTANCE* getInstanceReference(void);
		void setTrayIcon(char*);
		void show(void);
		void addMenu(fle_TrayMenuItem *);
		void setStatusFunction(void (*target_function)(void));
		void sendTrayMessage(char*, char*);
		void quit(void);
};

fle_TrayWindow::fle_TrayWindow(HINSTANCE * hInstance) : fle_BaseWindow(hInstance, 0, 0, L"DEFAULT", L"DEFAULT")
{
	p_hInstance = hInstance;
	hMenu = CreatePopupMenu();

	// Allocate memory for the structure.
	//memset(notifyIconData, 0, sizeof(NOTIFYICONDATA));
	notifyIconData = (NOTIFYICONDATA*)malloc(sizeof(NOTIFYICONDATA));
	notifyIconData->cbSize = sizeof(NOTIFYICONDATA);

	// Bind the NOTIFYICONDATA structure to our global hwnd ( handle to main window ).
	notifyIconData->hWnd = fle_BaseWindow::getWindowReference();

	// Set the NOTIFYICONDATA ID. HWND and uID form a unique identifier for each item in system tray.
	notifyIconData->uID = ID_TRAY_APP_ICON;

	// Set up flags.
	// 1 - Guarantees that the hIcon member will be a valid icon.
	// 2 - When someone clicks in the system tray icon, we want a WM_ type message to be sent to our WNDPROC.
	// 3 -
	// 4 -
	// 5 - // Show tooltip.
	notifyIconData->uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP | NIF_INFO | NIF_SHOWTIP;

	// This message must be handled in hwnd's window procedure.
	notifyIconData->uCallbackMessage = WM_TRAYICON;

	// Set the tooltip text.
	lstrcpy(notifyIconData->szTip, L"KA Lite");

	// Time to display the tooltip.
	notifyIconData->uTimeout = 100;

	// Type of tooltip (balloon).
	notifyIconData->dwInfoFlags = NIIF_INFO;

	// Copy text to the structure.
	lstrcpy(notifyIconData->szInfo, L"");
	lstrcpy(notifyIconData->szInfoTitle, L"");
}

NOTIFYICONDATA* fle_TrayWindow::getNotifyIconDataStructure()
{
	return notifyIconData;
}

HINSTANCE* fle_TrayWindow::getInstanceReference()
{
	return p_hInstance;
}

void fle_TrayWindow::setTrayIcon(char * icon_path_string)
{
	TCHAR * icon_path = getTCHAR(icon_path_string);
	fle_TrayWindow::getNotifyIconDataStructure()->hIcon = (HICON) LoadImage(NULL, icon_path, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE | LR_SHARED); 
}

void fle_TrayWindow::addMenu(fle_TrayMenuItem * menu)
{
	fle_BaseWindow::addTrayMenu(menu);
}

void fle_TrayWindow::setStatusFunction(void (*target_function)(void))
{
	fle_BaseWindow::setMainLoopFunction(target_function);
}

void fle_TrayWindow::sendTrayMessage(char * title, char * message)
{
	TCHAR * t_title = getTCHAR(title);
	TCHAR * t_message = getTCHAR(message);
	lstrcpy(fle_TrayWindow::getNotifyIconDataStructure()->szInfoTitle , t_title);
	lstrcpy(fle_TrayWindow::getNotifyIconDataStructure()->szInfo, t_message);

	Shell_NotifyIcon(NIM_MODIFY, fle_TrayWindow::getNotifyIconDataStructure());
}

void fle_TrayWindow::quit()
{
	Shell_NotifyIcon(NIM_DELETE, fle_TrayWindow::getNotifyIconDataStructure());
	fle_BaseWindow::quit();
}

void fle_TrayWindow::show()
{
	Shell_NotifyIcon(NIM_ADD, notifyIconData);

	MSG Msg;

	while(GetMessage(&Msg, NULL, 0 , 0) > 0){
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}
	
	fle_BaseWindow::test();
}









class fle_Window : public fle_BaseWindow
{
	private:
		HINSTANCE * p_hInstance;
	public:
		fle_Window(HINSTANCE*, int, int, TCHAR*, TCHAR*);
		void show(void);
};

fle_Window::fle_Window(HINSTANCE * hInstance, int WIDTH, int HEIGHT, TCHAR * CLASS_NAME, TCHAR * TITLE) : fle_BaseWindow(hInstance, WIDTH, HEIGHT, CLASS_NAME, TITLE)
{
	p_hInstance = hInstance;
}

void fle_Window::show()
{
	MSG Msg;

	ShowWindow(fle_BaseWindow::getWindowReference(), SW_SHOW);

	while(GetMessage(&Msg, NULL, 0 , 0) > 0){
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}
	
	fle_BaseWindow::test();
}



// RunSript
bool runShellScript(char * script_name, char * script_parameters, char * script_path)
{
	TCHAR * t_script_name = getTCHAR(script_name);
	TCHAR * t_script_parameters = getTCHAR(script_parameters);
	TCHAR * t_script_path = getTCHAR(script_path);

	SHELLEXECUTEINFO shellExecuteInfo;
	shellExecuteInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	shellExecuteInfo.fMask = SEE_MASK_NOCLOSEPROCESS | SEE_MASK_FLAG_NO_UI;
	shellExecuteInfo.hwnd = NULL;
	shellExecuteInfo.lpVerb = L"open";
	shellExecuteInfo.lpFile = t_script_name;
	shellExecuteInfo.lpParameters = t_script_parameters;
	shellExecuteInfo.lpDirectory = t_script_path;
	shellExecuteInfo.nShow = SW_HIDE;
	shellExecuteInfo.hInstApp = NULL;
	
	if(ShellExecuteEx(&shellExecuteInfo))
	{
		return true;
	}

	return false;
}

void printConsole(char * message)
{
	TCHAR * t_message = getTCHAR(message);
	OutputDebugString(t_message);
}

struct TDATA
{
	HANDLE * mutex;
	DWORD time;
	void (*target_function)(void);
	bool isloop;
};

DWORD WINAPI threadFunction( LPVOID lpParam )
{ 
	TDATA* t = (TDATA*) lpParam;
    DWORD dwWaitResult;

	if(t->isloop)
	{
		while(TRUE)
		{ 
			Sleep(t->time);

			if((t->mutex) != NULL)
			{
				dwWaitResult = WaitForSingleObject(*(t->mutex), INFINITE);
		
				switch (dwWaitResult) 
				{
					case WAIT_OBJECT_0: 
						__try {
					
							if(t->target_function != NULL)
							{
								t->target_function();						
							}
						} 

						__finally {
							if (! ReleaseMutex(*(t->mutex))) 
							{ 
								// Handle error.
							} 
						} 
						break; 

					case WAIT_ABANDONED:
						break;
				}
			}
			else
			{
				if(t->target_function != NULL)
				{
					t->target_function();						
				}
			}
		}
	}
	else
	{
		if(t->target_function != NULL)
		{
			t->target_function();						
		}
	}

    return TRUE; 
}

void startThread(HANDLE * mutex, bool loop, DWORD time_m, void (*target_function)(void)) 
{
	TDATA * data = new TDATA();
	data->mutex = mutex;
	data->isloop = loop;
	data->time = time_m;
	data->target_function = target_function;

	DWORD ThreadID;
	HANDLE aThread;
	aThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) threadFunction, data, 0, &ThreadID);
	if( aThread == NULL )
    {
		//return 1;
	}
	//CloseHandle(aThread);
}

void handleMutex(HANDLE * mutex, DWORD time_m, void (*target_function)(void))
{
	DWORD dwWaitResult = WaitForSingleObject(*mutex, time_m);
		
	switch (dwWaitResult) 
    {
        // The thread got ownership of the mutex
        case WAIT_OBJECT_0: 
            __try { 
                if(target_function != NULL)
				{
					target_function();
				}
            } 

            __finally {
                if (! ReleaseMutex(*mutex)) 
                { 
                    // Handle error.
                } 
            } 
            break; 

        case WAIT_ABANDONED: 
			break;
			// Error
    }
}

bool isServerOnline(char * session_name, char * url)
{
	TCHAR * t_session_name = getTCHAR(session_name);
	TCHAR * t_url = getTCHAR(url);

	HINTERNET hSession = InternetOpen(t_session_name, 0, NULL, NULL, 0);
	HINTERNET hOpenUrl = InternetOpenUrl(hSession, t_url, NULL, 0, INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_PRAGMA_NOCACHE, 1);

	if( hOpenUrl == NULL){

		InternetCloseHandle(hOpenUrl);
		InternetCloseHandle(hSession);

		return FALSE;
	}

	InternetCloseHandle(hOpenUrl);
	InternetCloseHandle(hSession);

	return TRUE;
}

int ask(char * title, char * message)
{
	TCHAR * t_title = getTCHAR(title);
	TCHAR * t_message = getTCHAR(message);

	if(MessageBox(NULL, t_message, t_title, MB_YESNO | MB_ICONQUESTION) == IDYES)
	{
		return TRUE;
	}
	return FALSE;
}

int loadBrowser(char * url)
{
	TCHAR * t_url = getTCHAR(url);
	if((int)ShellExecute(NULL, L"open", t_url, NULL, NULL, SW_MAXIMIZE) <= 36)
	{
		return FALSE;
	}
	return TRUE;
}

#endif