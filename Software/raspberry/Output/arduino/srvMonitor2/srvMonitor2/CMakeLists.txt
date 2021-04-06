project(srvMonitor2)
cmake_minimum_required(VERSION 2.6)
find_package(Qt4 REQUIRED)

include_directories(${QT_INCLUDES} ${CMAKE_CURRENT_BINARY_DIR})

set(srvMonitor2_SRCS main.cpp)
qt4_automoc(${srvMonitor2_SRCS})
add_executable(srvMonitor2 ${srvMonitor2_SRCS})
target_link_libraries(srvMonitor2 ${QT_QTCORE_LIBRARY})
