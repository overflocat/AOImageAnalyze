Run the function AutoConeCounter and all images in the folder Data will be processed, and both
a) Image with red dots that corresponds to center of the detected circles
b) Voronoi diagram image that marks cones and their Voronoi diagrams
will be saved respectively in the folders ImageA and ImageB in the workpath.
Hough Transform input parameters for "different size and circles" could be set in the file Rules.txt. The first column reqresents the coordinates, the second column represents cone_radius and the third column represents p-radiusDelta.
Besides, detected cone numbers and their corresponding file names will be saved in Result.xlsx.

All the parameters could be set in the head of the function:
DEBUG_FLAG: if it is set to 1, all figures will be displayed on the screen.
IMAGE_TYPE: the type of input images.
RULE_FILENAME: the file which includes the rules for cone_radius and radiusDelta. The format of it is illustrated above.
RESULT_FILENAME: the name of file which is used for saving detected cone numbers and their corresponding file names. It must be with a suffix .xlsx or .xls.
DATA_PATH: the path which includes input images.
IMAGEA_PATH: for saving A type images, which is mentioned above.
IMAGEB_PATH: for saving B type images, which is mentioned above.
IMAGE_SAVE_TYPE: All A type images and B type images will be saved with this suffix.
IMAGE_SAVE_PARA: the parameter for matlab function print. If you set IMAGE_SAVE_TYPE as 'png', then the IMAGE_SAVE_PARA will be '-dpng'. For other IMAGE_SAVE_TYPE, please refer matlab help docs.
ENLARGE_TIMES: because the original images are too small (only 67*67 in most of the cases), the circles illustrated in the center of each cone will be really small and look congested if the results are illustrated in the original size. Set this parameter to 5 or larger, the result will be enlarge ENLARGE_TIMES and look better.
BACKGROUND_PERPROCESSED: the background of results. if it is set to 1, both A type images and B type imagse will use preprocessed images as background. Set it to 0 for original images.
BCAKGROUND_VORONOI: the background of B type images. If you set it to 0, the Voronoi images will be saved without background.
CLOSE_WARNING: set it to 1 for closing the warning message of cone detector.

Besides, some simple comments are embed in the code. If you want to change the output format, such as the line width, you could dircetly modify the code rather than flags mentioned above.