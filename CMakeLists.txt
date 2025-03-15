cmake_minimum_required(VERSION 3.25)

project(
  libspectrum
  LANGUAGES C CXX)

set(SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
set(BINDIR ${SRCDIR}/bin/)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINDIR})
set(CMAKE_BINARY_DIR  ${BINDIR})
set(EXECUTABLE_OUTPUT_PATH ${BINDIR})
set(LIBRARY_OUTPUT_PATH ${BINDIR})
set(CMAKE_CACHEFILE_DIR ${BINDIR})

add_executable(make-perl
    make-perl.c)

find_package(Perl REQUIRED)

add_custom_command(
    OUTPUT generate.pl
    COMMAND ${BINDIR}/make-perl > ${SRCDIR}/tmp.pl
    COMMAND cat ${SRCDIR}/tmp.pl ${SRCDIR}/generate.pl.in > ${SRCDIR}/generate.pl
    COMMAND rm ${SRCDIR}/tmp.pl
    DEPENDS make-perl
    VERBATIM
)

add_custom_command(
    OUTPUT libspectrum.h
    COMMAND ${PERL_EXECUTABLE} -p ${SRCDIR}/generate.pl ${SRCDIR} ${SRCDIR}/libspectrum.h.in > ${SRCDIR}/libspectrum.h
    DEPENDS snap_accessors.txt tape_accessors.txt generate.pl
    VERBATIM
)

add_library(${PROJECT_NAME} SHARED)

add_definitions(-DVERSION="1.5.0.0")
target_include_directories(${PROJECT_NAME} PRIVATE ${SRCDIR})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

target_sources(${PROJECT_NAME}
    PRIVATE
    buffer.c   crypto.c  libspectrum.c  microdrive.c  pzx_read.c  snap_accessors.c  sp.c            tap.c             tape.c      tzx_read.c   warajevo_read.c
    csw.c      dsnap.c   mmc.c    rzx.c          snapshot.c    symbol_table.c                tape_accessors.c  tape_set.c      tzx_write.c wav.c
    creator.c  dck.c     ide.c    memory.c       plusd.c       sna.c       snp.c             szx.c           tape_block.c      timings.c   utilities.c  z80.c  z80em.c  zxs.c

    myglib/garray.c  myglib/ghash.c  myglib/glock.c  myglib/gslist.c

    PUBLIC
    internals.h  libspectrum.h  tape_block.h  zip.h
)

find_package(ZLIB)
if (${ZLIB_FOUND})
    set(HAVE_ZLIB_H BOOL ON)
    target_sources(${PROJECT_NAME}
        PRIVATE
        zip.c
        zlib.c
    )
endif()

find_package(BZip2)
if (${BZIP2_FOUND})
    set(HAVE_LIBBZ2 BOOL ON)
    target_sources(${PROJECT_NAME}
        PRIVATE
        bzip2.c
    )
endif()

add_custom_target(__perl_scripts
    SOURCES
    accessor.pl generate.pl generate.pl.in  tape_accessors.pl  tape_set.pl
    snap_accessors.txt tape_accessors.txt
    libspectrum.h.in
)

add_custom_target(__autotools_files
    SOURCES
    configure.ac Makefile.am config.h
)
