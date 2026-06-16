/* vi:set ts=8 sts=4 sw=4 noet:
 *
 * VIM - Vi IMproved	Vim launcher
 */

#include <windows.h>
#include <shlwapi.h>

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
    lstrcpyW(PathFindFileNameW(path), L"vim.exe");
#endif
}

// Show an error message
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
// E.g. (g)vim(diff), (g)view, e(g)vim
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

    if (StrCmpNIW(p, L"vim", 3) == 0)
    {
	// "vim"
	p += 3;
    }
    else if (StrCmpNIW(p, L"view", 3) == 0)
    {
	// "view"
	return L'R';    // read only mode
    }

    if (StrCmpNIW(p, L"diff", 3) == 0)
    {
	// "diff"
	return L'd';	    // diff mode
    }

    return 0;
}

// Check the -f (--nofork) option
    BOOL
check_nofork(LPCWSTR args)
{
    while (args[0] != L'\0')
    {
	int quote = 0;

	if (args[0] == L'"')
	{
	    ++args;
	    quote = 1;
	}
	if (StrCmpNW(args, L"-f", 2) == 0)
	{
	    // Other short options can be appended after "-f".
	    // XXX: Should we check "f" following other options? (e.g. -gf)
	    return TRUE;
	}
	else if (StrCmpNW(args, L"--nofork\"", 8 + quote) == 0)
	{
	    if (args[8 + quote] == L' ' || args[8 + quote] == L'\0')
		return TRUE;
	}
	else if (StrCmpNW(args, L"--\"", 2 + quote) == 0)
	{
	    if (args[2 + quote] == L' ' || args[2 + quote] == L'\0')
		break;
	}
	args = PathGetArgsW(args);
    }

    return FALSE;
}

    int
launch(void)
{
    WCHAR path[MAX_PATH];
    WCHAR opt = 0;
    LPCWSTR cmdline, args;
    LPWSTR buf;
    DWORD pathlen, argslen, len, optlen = 0;
    BOOL nofork;

    get_vim_path(path);
    if (path[0] == L'\0')
    {
	error_msg("Vim executable not found.");
	return 1;
    }

    cmdline = GetCommandLineW();
    //OutputDebugStringW(cmdline);
    args = PathGetArgsW(cmdline);
    //OutputDebugStringW(args);
    opt = parse_exename(PathFindFileNameW(cmdline));

#ifdef FEAT_GUI
    nofork = check_nofork(args);
#else
    nofork = TRUE;
#endif

    pathlen = lstrlenW(path);
    argslen = lstrlenW(args);
    len = pathlen + 1 + argslen + 3 + 3;    // option, two quotes and a NUL

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
    buf[pathlen + 2] = L' ';
    if (opt)
    {
	buf[pathlen + 3] = L'-';
	buf[pathlen + 4] = opt;
	buf[pathlen + 5] = L' ';
	optlen = 3;
    }
    lstrcpyW(buf + pathlen + 3 + optlen, args);
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

    DWORD exit = 0;
    if (nofork)
    {
	// Wait for exit
	WaitForSingleObject(pi.hProcess, INFINITE);
	GetExitCodeProcess(pi.hProcess, &exit);
    }
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
