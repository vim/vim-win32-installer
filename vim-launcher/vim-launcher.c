/* vi:set ts=8 sts=4 sw=4 noet:
 *
 * VIM - Vi IMproved	Vim launcher
 */

#include <windows.h>

#define TOLOWER_ASC(c) \
    (((c) < L'A' || (c) > L'Z') ? (c) : (c) + (L'a' - L'A'))


// Get path of (g)vim.exe
    void
get_vim_path(WCHAR *path)
{
    DWORD len;
    const LPCWSTR gvim_key = L"Software\\Vim\\Gvim";
    const LPCWSTR gvim_val = L"path";

    path[0] = L'\0';

    len = MAX_PATH * sizeof(WCHAR);
    if (RegGetValueW(HKEY_CURRENT_USER, gvim_key, gvim_val,
		RRF_RT_REG_SZ, NULL, path, &len) != ERROR_SUCCESS)
    {
	len = MAX_PATH * sizeof(WCHAR);
	if (RegGetValueW(HKEY_LOCAL_MACHINE, gvim_key, gvim_val,
		RRF_RT_REG_SZ, NULL, path, &len) != ERROR_SUCCESS)
	{
	    return;
	}
    }
#ifndef FEAT_GUI
    // Replace "gvim.exe" with "vim.exe"
    for (DWORD i = len / 2; i > 0; i--)
    {
	if (path[i] == L'\\')
	{
	    lstrcpyW(path + i + 1, L"vim.exe");
	    break;
	}
    }
#endif
}

// Get command line arguments by skipping the executable name
// Returns the pointer just after the exename. (includes leading space)
    LPCWSTR
get_cmd_args(LPCWSTR cmdline, LPCWSTR *exename)
{
    LPCWSTR p = cmdline;
    BOOL inquote = FALSE;

    *exename = p;
    while (*p)
    {
	if (inquote)
	{
	    if (*p == L'"')
	    {
		inquote = FALSE;
	    }
	}
	else
	{
	    if (*p == L'"')
	    {
		inquote = TRUE;
	    }
	    else if (*p == L' ' || *p == L'\t')
	    {
		return p;
	    }
	}
	if (*p == L'\\')
	{
	    *exename = p + 1;
	}
	++p;
    }
    return p;
}

    void
error_msg(const char *msg)
{
#ifdef FEAT_GUI
    MessageBoxA(NULL, msg, "Vim launcher", MB_OK | MB_ICONERROR);
#else
    HANDLE hStdErr = GetStdHandle(STD_ERROR_HANDLE);
    WriteConsoleA(hStdErr, msg, lstrlenA(msg), NULL, NULL);
    WriteConsoleA(hStdErr, "\r\n", 2, NULL, NULL);
#endif
}

// Parse executable name
// E.g. (g)vim(diff), (g)view, evim, egvim
    WCHAR
parse_exename(LPCWSTR exename)
{
    LPCWSTR p = exename;

    if (TOLOWER_ASC(p[0]) == L'r')
	++p;	// restricted mode ('-Z') (ignore it for now)

    if (TOLOWER_ASC(p[0]) == L'e'
	    && (TOLOWER_ASC(p[1]) == L'v'
		|| TOLOWER_ASC(p[1]) == L'g'))
    {
	// "evim" or "egvim"
	return L'y';	// easy mode
    }

    if (TOLOWER_ASC(p[0]) == L'g')
	++p;	// GUI

    if (TOLOWER_ASC(p[0]) == L'v'
	    && TOLOWER_ASC(p[1]) == L'i')
    {
	if (TOLOWER_ASC(p[2]) == L'm')
	{
	    // "vim"
	    p += 3;
	}
	else if (TOLOWER_ASC(p[2]) == L'e'
		&& TOLOWER_ASC(p[3]) == L'w')
	{
	    // "view"
	    return L'R';    // read only mode
	}
    }
    if (TOLOWER_ASC(p[0]) == L'd'
	    && TOLOWER_ASC(p[1]) == L'i'
	    && TOLOWER_ASC(p[2]) == L'f'
	    && TOLOWER_ASC(p[3]) == L'f')
    {
	// "diff"
	return L'd';	    // diff mode
    }

    return 0;
}

    int
launch(void)
{
    WCHAR path[MAX_PATH];
    WCHAR opt = 0;
    LPCWSTR cmdline, args, exename;
    LPWSTR buf;
    DWORD pathlen, argslen, len, optlen = 0;

    get_vim_path(path);
    if (path[0] == L'\0')
    {
	error_msg("Vim executable not found.");
	return 1;
    }

    cmdline = GetCommandLineW();
    //OutputDebugStringW(cmdline);
    args = get_cmd_args(cmdline, &exename);
    //OutputDebugStringW(args);
    opt = parse_exename(exename);

    pathlen = lstrlenW(path);
    argslen = lstrlenW(args);
    len = pathlen + argslen + 3 + 3;    // option, two quotes and a NUL

    buf = (LPWSTR)LocalAlloc(LMEM_FIXED, len * sizeof(WCHAR));
    if (buf == NULL)
    {
	error_msg("Not enough memory.");
	return 1;
    }

    // Build command line: '"path" opt args'
    buf[0] = L'"';
    lstrcpyW(buf + 1, path);
    buf[pathlen + 1] = L'"';
    if (opt)
    {
	buf[pathlen + 2] = L' ';
	buf[pathlen + 3] = L'-';
	buf[pathlen + 4] = opt;
	optlen = 3;
    }
    lstrcpyW(buf + pathlen + 2 + optlen, args);
    //OutputDebugStringW(buf);

    // Execute Vim
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;

    GetStartupInfoW(&si);
    BOOL ret = CreateProcessW(NULL, buf, NULL, NULL,
	    TRUE,   // stdio handles should be inherited.
	    0, NULL, NULL, &si, &pi);
    LocalFree(buf);
    if (!ret)
    {
	error_msg("Fail to execute Vim.");
	return 1;
    }
    // Wait for exit
    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD exit = 0;
    GetExitCodeProcess(pi.hProcess, &exit);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);

    return (int)exit;
}

#ifdef FEAT_GUI
    int WINAPI
wWinMain(
    HINSTANCE	hInstance,
    HINSTANCE	hPrevInst,
    LPWSTR	lpszCmdLine,
    int		nCmdShow)
{
    UNREFERENCED_PARAMETER(hInstance);
    UNREFERENCED_PARAMETER(hPrevInst);
    UNREFERENCED_PARAMETER(lpszCmdLine);
    UNREFERENCED_PARAMETER(nCmdShow);

    ExitProcess(launch());
}
#else
    int
wmain(int argc, wchar_t **argv)
{
    UNREFERENCED_PARAMETER(argc);
    UNREFERENCED_PARAMETER(argv);

    ExitProcess(launch());
}
#endif

// Use our own entry point and don't use the default CRT startup code to
// reduce the size of (g)vim.exe.
#ifdef FEAT_GUI
    void WINAPI
wWinMainCRTStartup(void)
{
    ExitProcess(launch());
}
#else
    void
wmainCRTStartup(void)
{
    ExitProcess(launch());
}
#endif
