find_program(NIM_EXECUTABLE nim REQUIRED)

set(SKETCHCAD_NIM_CACHE "${CMAKE_CURRENT_BINARY_DIR}/nimcache")
set(SKETCHCAD_NIM_LIBRARY
    "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}sketchcad_core${CMAKE_SHARED_LIBRARY_SUFFIX}")

add_custom_command(
    OUTPUT ${SKETCHCAD_NIM_LIBRARY}
    COMMAND ${NIM_EXECUTABLE} c
            --app:lib
            --noMain:on
            --nimcache:${SKETCHCAD_NIM_CACHE}
            --out:${SKETCHCAD_NIM_LIBRARY}
            -d:release
            ${CMAKE_CURRENT_SOURCE_DIR}/sketchcad_core/src/sketchcad_core.nim
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/sketchcad_core/src/sketchcad_core.nim
        ${CMAKE_CURRENT_SOURCE_DIR}/sketchcad_core/src/cad_geometry.nim
    COMMENT "Building the SketchCAD Nim geometry core"
    VERBATIM
)

add_custom_target(SketchCADNimCore ALL DEPENDS ${SKETCHCAD_NIM_LIBRARY})

install(FILES ${SKETCHCAD_NIM_LIBRARY} DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES sketchcad_core/include/sketchcad_core.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
