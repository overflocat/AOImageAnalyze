Set the path of imread and run the function. Image will be automatically cropped and the results will be saved in the SAVEPATH.

You can adjust the parameters in the function, and their functions are explained below:
1. CENTRE_DETECT_WINDOW: create a small window to make the centre detect faster. You should make sure the circle is completely contained in the window.
2. AXIAL_LENGTH: The unit of it is milimeter;
3. CROPPED_WINDOW_SIZE: The unit of it is micrometer;
4. ODorOS: Set it to 'OD' or 'OS' for right eye and left eye respectively;
5. COORDINATES_PATH: The path of the txtfile which contains the coordinates;
6. DEBUGFLAG: Set it to 1 for illustrating the results;
7. SAVEPATH: Indicating where the cropped images will be saved;
8. NAME: The name of the patient. It will be used as a filename prefix of cropped image;
9. FOCUS_OPERATOR: Indicating which focus operator will be chosed. It will be used by auto-select function;
10. CROP_OPTION: 1 for mid, 2 for tl, 3 for bl, 4 for tr, 5 for br, 6 for all, 7 for auto selecting the best one from five results;
11. COLOR_OF_CIRCLE: The rgb color of the circle. if you are not quite sure what it is and the circle is red, you can try to use AutoColorDetect to detect the value.

