cmake_minimum_required(VERSION 3.25)

project(
  libspectrum
  LANGUAGES C CXX)

add_library(${PROJECT_NAME} SHARED)
add_definitions(-DVERSION="1.5.0.0" -DLIBSPECTRUM_EXPORTS)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(make-perl
    make-perl.c)

find_package(Perl REQUIRED)
include(cmake/config.cmake)

if (HAVE_ZLIB_H)
    target_sources(${PROJECT_NAME}
        PRIVATE
        zip.c
        zlib.c
    )
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        z
    )
endif()

if (HAVE_LIBBZ2)
    target_sources(${PROJECT_NAME}
        PRIVATE
        bzip2.c
    )
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        bz2
    )
endif()

if (HAVE_LIB_GLIB)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        ${GLIB2_LIBRARIES}
    )
endif()

set(CHDIR ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR})
set(RM ${CMAKE_COMMAND} -E rm -f --)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/generate.pl
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/generate.pl
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/make-perl > ${CMAKE_CURRENT_SOURCE_DIR}/tmp.pl
    COMMAND ${CHDIR} ${CMAKE_COMMAND} -E cat tmp.pl generate.pl.in > ${CMAKE_CURRENT_SOURCE_DIR}/generate.pl
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/tmp.pl
    DEPENDS make-perl generate.pl.in
    VERBATIM
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/libspectrum.h
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/libspectrum.h
    COMMAND ${CHDIR} ${PERL_EXECUTABLE} -p generate.pl ./ libspectrum.h.in > ${CMAKE_CURRENT_SOURCE_DIR}/libspectrum.h
    DEPENDS snap_accessors.txt tape_accessors.txt generate.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/snap_accessors.c
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/snap_accessors.c
    COMMAND ${CHDIR} ${PERL_EXECUTABLE} -p accessor.pl snap_accessors.txt > ${CMAKE_CURRENT_SOURCE_DIR}/snap_accessors.c
    DEPENDS snap_accessors.txt accessor.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/tape_accessors.c
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/tape_accessors.c
    COMMAND ${CHDIR} ${PERL_EXECUTABLE} -p tape_accessors.pl tape_accessors.txt > ${CMAKE_CURRENT_SOURCE_DIR}/tape_accessors.c
    DEPENDS tape_accessors.txt tape_accessors.pl
    VERBATIM
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/tape_set.c
    COMMAND ${RM} ${CMAKE_CURRENT_SOURCE_DIR}/tape_set.c
    COMMAND ${CHDIR} ${PERL_EXECUTABLE} -p tape_set.pl tape_accessors.txt > ${CMAKE_CURRENT_SOURCE_DIR}/tape_set.c
    DEPENDS tape_accessors.txt tape_set.pl
    VERBATIM
)

add_custom_target(__generated_${PROJECT_NAME}
    SOURCES
    generate.pl libspectrum.h snap_accessors.c tape_accessors.c tape_set.c
)

add_dependencies(${PROJECT_NAME} __generated_${PROJECT_NAME})

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

    snap_accessors.c
    tape_accessors.c
    tape_set.c

    PUBLIC
    internals.h  libspectrum.h  tape_block.h  zip.h
)

if (NOT DEFINED ${HAVE_LIB_GLIB})
    target_sources(${PROJECT_NAME}
        PRIVATE
        myglib/garray.c  myglib/ghash.c  myglib/glock.c  myglib/gslist.c
    )
endif()

add_custom_target(__perl_scripts_${PROJECT_NAME}
    SOURCES
    accessor.pl generate.pl generate.pl.in  tape_accessors.pl  tape_set.pl
    snap_accessors.txt tape_accessors.txt
    libspectrum.h.in libspectrum.h
)

add_custom_target(__autotools_files_${PROJECT_NAME}
    SOURCES
    configure.ac Makefile.am config.h
)
