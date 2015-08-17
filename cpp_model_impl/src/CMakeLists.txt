include_directories(../)

add_executable(cam_model_general_test  cam_model_general_test.cpp)
add_library(cam_model_general cam_model_general.cpp 
                              cam_model_general.h)
target_link_libraries(cam_model_general_test
					            cam_model_general
                      ${OpenCV_LIBRARIES})