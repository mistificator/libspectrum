cmake_minimum_required(VERSION 3.25)

project(
  libspectrum
  LANGUAGES C CXX)

add_library(${PROJECT_NAME} SHARED)
add_definitions(-DVERSION="1.5.0.0" -DLIBSPECTRUM_EXPORTS)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

set(SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
set(BINDIR ${SRCDIR}/bin/)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINDIR})
set(CMAKE_BINARY_DIR  ${BINDIR})
set(EXECUTABLE_OUTPUT_PATH ${BINDIR})
set(LIBRARY_OUTPUT_PATH ${BINDIR})
set(CMAKE_CACHEFILE_DIR ${BINDIR})

target_include_directories(${PROJECT_NAME} PRIVATE ${SRCDIR})

add_executable(make-perl
    make-perl.c)

find_package(Perl REQUIRED)
include(cmake/config.cmake)

add_custom_command(
    OUTPUT ${SRCDIR}/generate.pl
    COMMAND ${BINDIR}/make-perl > ${SRCDIR}/tmp.pl
    COMMAND ${CMAKE_COMMAND} -E cat ${SRCDIR}/tmp.pl ${SRCDIR}/generate.pl.in > ${SRCDIR}/generate.pl
    COMMAND ${CMAKE_COMMAND} -E rm ${SRCDIR}/tmp.pl
    DEPENDS make-perl ${SRCDIR}/generate.pl.in
    VERBATIM
)

add_custom_command(
    OUTPUT ${SRCDIR}/libspectrum.h
    COMMAND ${PERL_EXECUTABLE} -p ${SRCDIR}/generate.pl ${SRCDIR} ${SRCDIR}/libspectrum.h.in > ${SRCDIR}/libspectrum.h
    DEPENDS ${SRCDIR}/snap_accessors.txt ${SRCDIR}/tape_accessors.txt ${SRCDIR}/generate.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${SRCDIR}/snap_accessors.c
    COMMAND ${PERL_EXECUTABLE} -p ${SRCDIR}/accessor.pl ${SRCDIR}/snap_accessors.txt > ${SRCDIR}/snap_accessors.c
    DEPENDS ${SRCDIR}/snap_accessors.txt ${SRCDIR}/accessor.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${SRCDIR}/tape_accessors.c
    COMMAND ${PERL_EXECUTABLE} -p ${SRCDIR}/tape_accessors.pl ${SRCDIR}/tape_accessors.txt > ${SRCDIR}/tape_accessors.c
    DEPENDS ${SRCDIR}/tape_accessors.txt ${SRCDIR}/tape_accessors.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${SRCDIR}/tape_set.c
    COMMAND ${PERL_EXECUTABLE} -p ${SRCDIR}/tape_set.pl ${SRCDIR}/tape_accessors.txt > ${SRCDIR}/tape_set.c
    DEPENDS ${SRCDIR}/tape_accessors.txt ${SRCDIR}/tape_set.pl
    VERBATIM
)

target_sources(${PROJECT_NAME}
    PRIVATE
    buffer.c
    crypto.c
    libspectrum.c
    microdrive.c
    pzx_read.c
    sp.c
    tap.c
    tape.c
    tzx_read.c
    warajevo_read.c
    csw.c
    dsnap.c
    mmc.c
    rzx.c
    snapshot.c
    symbol_table.c
    tzx_write.c
    wav.c
    creator.c
    dck.c
    ide.c
    memory.c
    plusd.c
    sna.c
    snp.c
    szx.c
    tape_block.c
    timings.c
    utilities.c
    z80.c
    z80em.c
    zxs.c

    ${SRCDIR}/snap_accessors.c
    ${SRCDIR}/tape_accessors.c
    ${SRCDIR}/tape_set.c

    PUBLIC
    internals.h  ${SRCDIR}/libspectrum.h  tape_block.h  zip.h
)

if (NOT DEFINED ${HAVE_LIB_GLIB})
    target_sources(${PROJECT_NAME}
        PRIVATE
        myglib/garray.c  myglib/ghash.c  myglib/glock.c  myglib/gslist.c
    )
endif()

add_custom_target(__perl_scripts
    SOURCES
    accessor.pl generate.pl generate.pl.in  tape_accessors.pl  tape_set.pl
    snap_accessors.txt tape_accessors.txt
    libspectrum.h.in libspectrum.h
)

add_custom_target(__autotools_files
    SOURCES
    configure.ac Makefile.am config.h
)
