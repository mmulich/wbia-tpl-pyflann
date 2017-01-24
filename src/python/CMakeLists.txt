configure_file( setup.py.tpl setup.py )
# move the setup.py file back to the source to point to the correct library location
# TODO: it would be nice to find a way to do this without polluting the source directory 
file(COPY ${CMAKE_CURRENT_BINARY_DIR}/setup.py DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})

# Ideally we could just simlink the source directory

install( DIRECTORY pyflann DESTINATION share/flann/python )
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/setup.py DESTINATION share/flann/python )


# python instalation
if (PYTHON_EXECUTABLE)
    #install(CODE "execute_process(
    #    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/setup.py install
    #    WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\")")
    install(CODE "execute_process(
        COMMAND ${PYTHON_EXECUTABLE} -m pip ${CMAKE_CURRENT_SOURCE_DIR} install
        WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\")")
endif()
