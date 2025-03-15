# built-in packages

function(set_define variable)
    set(${variable})
    add_definitions(-D${variable})
endfunction()

find_package(ZLIB)
if (${ZLIB_FOUND})
    set_define(HAVE_ZLIB_H)
    target_sources(${PROJECT_NAME}
        PRIVATE
        zip.c
        zlib.c
    )
endif()

find_package(BZip2)
if (${BZIP2_FOUND})
    set_define(HAVE_LIBBZ2)
    target_sources(${PROJECT_NAME}
        PRIVATE
        bzip2.c
    )
endif()

# other packages

include(FindPkgConfig)

pkg_check_modules (GLIB2 glib-2.0)
if (${GLIB2_VERSION})
    set_define(HAVE_LIB_GLIB)
endif()

# checks

include(CheckIncludeFile)
include(CheckFunctionExists)

function(check_include header variable)
    check_include_file(${header} ${variable})
    if (${variable})
        add_definitions(-D${variable})
    endif()
endfunction()

function(check_function func variable)
    check_function_exists(${func} ${variable})
    if (${variable})
        add_definitions(-D${variable})
    endif()
endfunction()

check_include(dlfcn.h      HAVE_DLFCN_H)
check_include(gcrypt.h     HAVE_GCRYPT_H)
check_include(inttypes.h   HAVE_INTTYPES_H)
check_include(stdatomic.h  HAVE_STDATOMIC_H)
check_include(stdint.h     HAVE_STDINT_H)
check_include(stdio.h      HAVE_STDIO_H)
check_include(stdlib.h     HAVE_STDLIB_H)
check_include(strings.h    HAVE_STRINGS_H)
check_include(string.h     HAVE_STRING_H)
check_include(sys/stat.h   HAVE_SYS_STAT_H)
check_include(sys/types.h  HAVE_SYS_TYPES_H)
check_include(unistd.h     HAVE_UNISTD_H)

check_function(snprintf      HAVE_SNPRINTF)
check_function(strcasecmp    HAVE_STRCASECMP)
check_function(strncasecmp   HAVE_STRNCASECMP)
check_function(_snprintf     HAVE__SNPRINTF)
check_function(_stricmp      HAVE__STRICMP)
check_function(_strnicmp     HAVE__STRNICMP)
