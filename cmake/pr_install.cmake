function(pr_install_files)
    set(options)
    set(oneValueArgs INSTALL_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 PA "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED PA_INSTALL_DIR)
        set(PA_INSTALL_DIR "${BINARY_OUTPUT_DIR}")
    endif()

	foreach(FILE_PATH ${PA_UNPARSED_ARGUMENTS})
        string(REPLACE "\\" "/" FILE_PATH ${FILE_PATH})
        message("Adding install rule for \"${FILE_PATH}\" to \"${PA_INSTALL_DIR}\"...")
        install(
            FILES "${FILE_PATH}"
            DESTINATION "${PA_INSTALL_DIR}"
            OPTIONAL
            COMPONENT ${PRAGMA_INSTALL_COMPONENT})
	endforeach()
endfunction(pr_install_files)

function(pr_install_libraries)
    set(options)
    set(oneValueArgs INSTALL_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 PA "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED PA_INSTALL_DIR)
        set(PA_INSTALL_DIR "${BINARY_OUTPUT_DIR}")
    endif()

    foreach(TARGET ${PA_UNPARSED_ARGUMENTS})
        pr_get_normalized_identifier_name(${TARGET})
        set(FILE_PATH "${DEPENDENCY_${NORMALIZED_IDENTIFIER}_LIBRARY}")
        string(REPLACE "\\" "/" FILE_PATH ${FILE_PATH})
        message("Adding install rule for library \"${TARGET}\" (\"${FILE_PATH}\") to \"${PA_INSTALL_DIR}\"...")
        install(
            FILES "${FILE_PATH}"
            DESTINATION "${PA_INSTALL_DIR}"
            OPTIONAL
            COMPONENT ${PRAGMA_INSTALL_COMPONENT})
    endforeach()
endfunction(pr_install_libraries)

function(pr_install_targets)
    set(options)
    set(oneValueArgs INSTALL_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 PA "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED PA_INSTALL_DIR)
        set(PA_INSTALL_DIR "${BINARY_OUTPUT_DIR}")
    endif()

    foreach(TARGET ${PA_UNPARSED_ARGUMENTS})
        set(FILE_PATH "$<TARGET_FILE:${TARGET}>")
        string(REPLACE "\\" "/" FILE_PATH ${FILE_PATH})
        message("Adding install rule for target \"${TARGET}\" (\"${FILE_PATH}\") to \"${PA_INSTALL_DIR}\"...")

        # Install the actual library file
        install(
            FILES "${FILE_PATH}"
            DESTINATION "${PA_INSTALL_DIR}"
            OPTIONAL
            COMPONENT ${PRAGMA_INSTALL_COMPONENT})

        # Check if the file is a symbolic link
        get_filename_component(FILE_TYPE ${FILE_PATH} TYPE)
        if(FILE_TYPE STREQUAL "SYMLINK")
            file(READLINK ${FILE_PATH} LINK_TARGET)
            string(REPLACE "\\" "/" LINK_TARGET ${LINK_TARGET})
            message("Adding install rule for symlink target \"${TARGET}\" (\"${LINK_TARGET}\") to \"${PA_INSTALL_DIR}\"...")
            install(
                FILES "${LINK_TARGET}"
                DESTINATION "${PA_INSTALL_DIR}"
                OPTIONAL
                COMPONENT ${PRAGMA_INSTALL_COMPONENT})
        endif()
    endforeach()
endfunction(pr_install_targets)

function(pr_install_directory FILE_PATH)
    set(options)
    set(oneValueArgs INSTALL_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 PA "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED PA_INSTALL_DIR)
        set(PA_INSTALL_DIR "${BINARY_OUTPUT_DIR}")
    endif()

    string(REPLACE "\\" "/" FILE_PATH ${FILE_PATH})
    message("Adding install rule for \"${FILE_PATH}\" to \"${PA_INSTALL_DIR}\"...")
    install(
        DIRECTORY "${FILE_PATH}"
        DESTINATION "${PA_INSTALL_DIR}"
        OPTIONAL
        COMPONENT ${PRAGMA_INSTALL_COMPONENT} ${PA_UNPARSED_ARGUMENTS})
endfunction(pr_install_directory)

function(pr_install_create_directory DIR_NAME)
    add_custom_command(
        TARGET pragma-install
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${DIR_NAME})
endfunction(pr_install_create_directory)

function(pr_install_binary)
    set(options)
    set(oneValueArgs BIN_DIR WIN LIN INSTALL_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 PA "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED PA_INSTALL_DIR)
        set(PA_INSTALL_DIR "${BINARY_OUTPUT_DIR}")
    endif()

    if(NOT DEFINED PA_BIN_DIR)
        set(IDENTIFIER "${PA_UNPARSED_ARGUMENTS}")
        pr_get_normalized_identifier_name(${IDENTIFIER})
        get_filename_component(DIR_PATH "${DEPENDENCY_${NORMALIZED_IDENTIFIER}_LIBRARY}" DIRECTORY)
    else()
        set(DIR_PATH "${PA_BIN_DIR}")
    endif()
    if(WIN32)
        file(TO_NATIVE_PATH "${DIR_PATH}/${PA_WIN}" PA_BIN_DIR)
    else()
        file(TO_NATIVE_PATH "${DIR_PATH}/${PA_LIN}" PA_BIN_DIR)
    endif()

    message("Installing binary \"${PA_BIN_DIR}\" to \"${PA_INSTALL_DIR}\"...")
    pr_install_files(
        "${PA_BIN_DIR}"
        INSTALL_DIR "${PA_INSTALL_DIR}"
    )
endfunction()
