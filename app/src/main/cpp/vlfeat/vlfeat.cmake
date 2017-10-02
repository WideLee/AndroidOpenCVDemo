get_filename_component(VLFEAT_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

add_definitions(-D__CMAKE__)

set(VLFEAT_INC ${VLFEAT_CMAKE_DIR})

set(VLFEAT_SRC
        ${VLFEAT_CMAKE_DIR}/aib.c
        ${VLFEAT_CMAKE_DIR}/array.c
        ${VLFEAT_CMAKE_DIR}/covdet.c
        ${VLFEAT_CMAKE_DIR}/dsift.c
        ${VLFEAT_CMAKE_DIR}/fisher.c
        ${VLFEAT_CMAKE_DIR}/generic.c
        ${VLFEAT_CMAKE_DIR}/getopt_long.c
        ${VLFEAT_CMAKE_DIR}/gmm.c
        ${VLFEAT_CMAKE_DIR}/hikmeans.c
        ${VLFEAT_CMAKE_DIR}/hog.c
        ${VLFEAT_CMAKE_DIR}/homkermap.c
        ${VLFEAT_CMAKE_DIR}/host.c
        ${VLFEAT_CMAKE_DIR}/ikmeans.c
        ${VLFEAT_CMAKE_DIR}/imopv_sse2.c
        ${VLFEAT_CMAKE_DIR}/imopv.c
        ${VLFEAT_CMAKE_DIR}/kdtree.c
        ${VLFEAT_CMAKE_DIR}/kmeans.c
        ${VLFEAT_CMAKE_DIR}/lbp.c
        ${VLFEAT_CMAKE_DIR}/liop.c
        ${VLFEAT_CMAKE_DIR}/mathop_avx.c
        ${VLFEAT_CMAKE_DIR}/mathop_sse2.c
        ${VLFEAT_CMAKE_DIR}/mathop.c
        ${VLFEAT_CMAKE_DIR}/mser.c
        ${VLFEAT_CMAKE_DIR}/pgm.c
        ${VLFEAT_CMAKE_DIR}/quickshift.c
        ${VLFEAT_CMAKE_DIR}/random.c
        ${VLFEAT_CMAKE_DIR}/rodrigues.c
        ${VLFEAT_CMAKE_DIR}/scalespace.c
        ${VLFEAT_CMAKE_DIR}/sift.c
        ${VLFEAT_CMAKE_DIR}/slic.c
        ${VLFEAT_CMAKE_DIR}/stringop.c
        ${VLFEAT_CMAKE_DIR}/svm.c
        ${VLFEAT_CMAKE_DIR}/svmdataset.c
        ${VLFEAT_CMAKE_DIR}/vlad.c)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVL_DISABLE_SSE2 -DVL_DISABLE_AVX")
