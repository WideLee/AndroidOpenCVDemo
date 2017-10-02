
## Android中编译以及使用OpenCV

> Created  By MingkuanLi On 2017-09-26

### 1. 概述

项目中需要在Android中使用OpenCV中图像处理，提取特征点等功能，于是折腾了很久，从最开始的Eclipse+Android.mk的方式编译把OpenCV集成到Android项目中，到后来Android Studio支持NDK开发，使用cmake构建项目的native部分，发现其实在Android中使用OpenCV并不是一件特别困难的事情，参考如下过程可以快速搭建起工程环境。

下边使用的OpenCV版本是2.4，对于OpenCV 3以上，可能还有些不一样，具体编译等可以参考[这个](http://www.cnblogs.com/hrlnw/p/4720977.html)博客。

### 2. 直接使用OpenCV for Android

- 在OpenCV官网[这里](http://opencv.org/platforms/android/)可以下载到AndroidSDK，并且里面有一篇教程，不过是针对Eclipse的，并且最原始的版本需要另外安装一个OpenCV Loader类似的应用才能使用。
- 下载下来的OpenCV android sdk目录结构大概如下所示，主要使用的是`sdk`目录
  - `java`目录包括SDK的Eclilpse工程，把这个工程导入到项目中后就可以使用OpenCV提供的Java API
  - `native`目录主要是C++的头文件以及针对于各种移动CPU架构的动态/静态链接库

```
OpenCV-2.4.13-android-sdk
|_ doc
|_ samples
|_ sdk
|    |_ etc
|    |_ java
|    |_ native
|          |_ 3rdparty
|          |_ jni
|          |_ libs
|               |_ armeabi
|               |_ armeabi-v7a
|               |_ x86
|
|_ LICENSE
|_ README.android
```

- 新建一个Android工程，勾选`C++ support`，如下图所示：

![创建工程](img/in-post/opencv-android/1.png)

- 在项目那里右键打开`Module Setting`，导入`sdk`目录中的`java`文件夹，即OpenCV的Java API，如果项目中只需要在C++中使用OpenCV，那么不需要导入这一步

![导入OpenCV的Java API](img/in-post/opencv-android/2.png)

- 把OpenCV中native中jni的`include`目录以及libs目录复制到工程项目内，这里放到了`app/libs/opencv/include`以及`app/libs/opencv/libs`
- 修改`build.gradle`
  - 通过`abiFilters`指定要编译的CPU架构
  - 通过`jniLibs.srcDirs`指定要加载的库的路径（如果不指定可能会出现找不到某个函数实现的错误）

```c++
apply plugin: 'com.android.application'

android {
    compileSdkVersion 25
    buildToolsVersion "26.0.1"
    defaultConfig {
        applicationId "indoor.sysu.mobile.limk.opencvtest"
        minSdkVersion 19
        targetSdkVersion 25
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
        externalNativeBuild {
            cmake {
                cppFlags "-frtti -fexceptions"
            }
        }
      	ndk {
            abiFilters 'armeabi-v7a'
        }
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    externalNativeBuild {
        cmake {
            path "CMakeLists.txt"
        }
    }

    sourceSets {
        main {
            jniLibs.srcDirs = ['libs/opencv/libs']
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    compile 'com.android.support:appcompat-v7:25.3.1'
    compile 'com.android.support.constraint:constraint-layout:1.0.2'
    testCompile 'junit:junit:4.12'
}
```

- **(重要)**修改`CMakeList.txt`
  - 通过`set(name "value")`设置变量可以供CMakeList后面使用
  - 通过`include_directories()`设置include的路径，使用`${CMAKE_SOURCE_DIR}`指定相对路径
  - `add_library(libopencv_java SHARED IMPORTED )`通过`SHARED`指定`.so`文件的动态链接库
  - `add_library(libopencv_calib3d STATIC IMPORTED )`通过`STATIC`指定各种`.a`静态链接库
  - `set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fexceptions -frtti")`设置`g++`编译时候的参数
  - 项目里要编译的库的名字为`native-lib`，最后通过`target_link_libraries()`添加opencv相关的链接库

```cmake
cmake_minimum_required(VERSION 3.6)

set(CMAKE_VERBOSE_MAKEFILE on)

set(libs "${CMAKE_SOURCE_DIR}/libs/opencv/libs")

include_directories(${CMAKE_SOURCE_DIR}/libs/opencv/include)

add_library(libopencv_java SHARED IMPORTED )
set_target_properties(libopencv_java PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_java.so")

add_library(libopencv_calib3d STATIC IMPORTED )
set_target_properties(libopencv_calib3d PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_calib3d.a")

add_library(libopencv_contrib STATIC IMPORTED )
set_target_properties(libopencv_contrib PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_contrib.a")

add_library(libopencv_core STATIC IMPORTED )
set_target_properties(libopencv_core PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_core.a")

add_library(libopencv_features2d STATIC IMPORTED )
set_target_properties(libopencv_features2d PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_features2d.a")

add_library(libopencv_flann STATIC IMPORTED )
set_target_properties(libopencv_flann PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_flann.a")

add_library(libopencv_highgui STATIC IMPORTED )
set_target_properties(libopencv_highgui PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_highgui.a")

add_library(libopencv_imgproc STATIC IMPORTED )
set_target_properties(libopencv_imgproc PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_imgproc.a")

add_library(libopencv_legacy STATIC IMPORTED )
set_target_properties(libopencv_legacy PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_legacy.a")

add_library(libopencv_ml STATIC IMPORTED )
set_target_properties(libopencv_ml PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_ml.a")

add_library(libopencv_objdetect STATIC IMPORTED )
set_target_properties(libopencv_objdetect PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_objdetect.a")

add_library(libopencv_photo STATIC IMPORTED )
set_target_properties(libopencv_photo PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_photo.a")

add_library(libopencv_stitching STATIC IMPORTED )
set_target_properties(libopencv_stitching PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_stitching.a")

add_library(libopencv_superres STATIC IMPORTED )
set_target_properties(libopencv_superres PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_superres.a")

add_library(libopencv_video STATIC IMPORTED )
set_target_properties(libopencv_video PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_video.a")

add_library(libopencv_videostab STATIC IMPORTED )
set_target_properties(libopencv_videostab PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_videostab.a")

add_library(libopencv_ts STATIC IMPORTED )
set_target_properties(libopencv_ts PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_ts.a")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fexceptions -frtti")

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             src/main/cpp/native-lib.cpp)

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log)

target_link_libraries(native-lib android log
    libopencv_java
    libopencv_calib3d
    libopencv_contrib
    libopencv_core
    libopencv_features2d
    libopencv_flann
    libopencv_highgui
    libopencv_imgproc
    libopencv_legacy
    libopencv_ml
    libopencv_objdetect
    libopencv_photo
    libopencv_stitching
    libopencv_superres
    libopencv_video
    libopencv_videostab
    libopencv_ts
    ${log-lib}
    )
```

- 在`native-lib.cpp`中编写测试代码

```c++
#include <jni.h>
#include <string>
#include "opencv2/opencv.hpp"

extern "C"
JNIEXPORT jstring JNICALL
Java_indoor_sysu_mobile_limk_opencvtest_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    char hello[100] = {"Hello from JNI"};
    cv::Mat mat = cv::imread("/sdcard/test.jpeg", CV_LOAD_IMAGE_COLOR);
    char spec[20] = {};
    sprintf(spec, ", image size: %d x %d", mat.rows, mat.cols);
    strcat(hello, spec);

    return env->NewStringUTF(hello);
}
```

- 在`MainActivity.java`中加载`opencv_java`动态链接库以及`native-lib`链接库

```java
package indoor.sysu.mobile.limk.opencvtest;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("opencv_java");
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
        TextView tv = (TextView) findViewById(R.id.sample_text);
        tv.setText(stringFromJNI());

        checkPermission();
    }

    @TargetApi(Build.VERSION_CODES.M)
    private void checkPermission() {
        if(checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 0x10);
        }
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}

```

- 测试是否能正确编译运行（读写存储卡中的图片记得动态申请读写外部存储的权限），下图所示能正确读出给定图片的大小

![运行结果-1](img/in-post/opencv-android/3.png)

---

- 下面使用`opencv`提取`SURF`特征点，由于`SURF`模块属于`opencv`中`nonfree`的模块，所以在官方提供的`opencv for android sdk`中并没有提供这个模块的内容，如果不想折腾想迅速搭建起环境，可以使用我编译好的nonfree模块
- 下载[这个](img/in-post/opencv-android/libnonfree.so)动态链接库，放到`libs/opencv/libs/armeabi-v7a/`目录下
- 下载[这个](img/in-post/opencv-android/headers_nonfree.zip)头文件，解压放到`libs/opencv/include/opencv2/nonfree`目录
- 在`CMakeList.txt`中添加如下加载动态链接库

```cmake
add_library(libopencv_nonfree SHARED IMPORTED )
set_target_properties(libopencv_nonfree PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libnonfree.so")

// something...

target_link_libraries(native-lib android log
    libopencv_java
    libopencv_calib3d
    libopencv_contrib
    libopencv_core
    libopencv_features2d
    libopencv_flann
    libopencv_highgui
    libopencv_imgproc
    libopencv_legacy
    libopencv_ml
    libopencv_objdetect
    libopencv_photo
    libopencv_stitching
    libopencv_superres
    libopencv_video
    libopencv_videostab
    libopencv_ts
    libopencv_nonfree
    ${log-lib}
    )
```

- 编写测试代码

```c++
#include <jni.h>
#include <string>
#include "opencv2/opencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"

extern "C"
JNIEXPORT jstring JNICALL
Java_indoor_sysu_mobile_limk_opencvtest_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    char hello[100] = {"Hello from JNI"};
    cv::Mat mat = cv::imread("/sdcard/test.jpeg", CV_LOAD_IMAGE_GRAYSCALE);

    cv::SurfFeatureDetector detector;
    std::vector<cv::KeyPoint> keypoints;
    detector.detect(mat, keypoints);

    char spec[20] = {};
    sprintf(spec, ", image size: %d x %d\nSurf keypoints: %d",
            mat.rows, mat.cols, keypoints.size());
    strcat(hello, spec);

    return env->NewStringUTF(hello);
}
```

- 运行结果如下所示，第二行能够正确显示提取到的surf特征点个数

![运行结果-2](img/in-post/opencv-android/4.png)

### 3. 编译OpenCV for Android

- 有时候想使用一些`OpenCV for Android SDK`中不支持的功能，例如`ocl`模块，`nonfree`模块等，因此自己编译opencv源码可能会更方便

- 以下内容参考[这篇博客](http://www.cnblogs.com/hrlnw/p/4720977.html)，感谢[handspeaker](http://home.cnblogs.com/u/hrlnw/)给出的解决方案

- 首先在[这里下载](https://github.com/opencv/opencv/archive/2.4.11.zip)`OpenCV`源码，解压后在platform目录下新建一个`build_opencv`文件夹

- 在`opencv_path\modules\ocl\src\cl_runtime\cl_runtime.cpp`文件中，做如下修改：

    第48行，`#if defined(__linux__) 改为 #if defined(__linux__)&&!defined(__ANDROID__)`

  　　第70行后，添加如下代码：

```c++
#if defined(__ANDROID__)
    #include <dlfcn.h>
    #include <sys/stat.h>

#if defined(__ARM_ARCH_8A__) || defined(_X64_)
    static const char *default_so_paths[] = {
                                            "/system/lib64/libOpenCL.so",
                                            "/system/vendor/lib64/libOpenCL.so",
                                            "/system/vendor/lib64/egl/libGLES_mali.so"
                                          };
#else
    static const char *default_so_paths[] = {
                                            "/system/lib/libOpenCL.so",
                                            "/system/vendor/lib/libOpenCL.so",
                                            "/system/vendor/lib/egl/libGLES_mali.so"
                                          };
#endif

static int access_file(const char *filename)
    {
        struct stat buffer;
        return (stat(filename, &buffer) == 0);
    }

    static void* GetProcAddress (const char* name)
    {
        static void* h = NULL;
        unsigned int i;
        if (!h)
        {
            const char* name;
            for(i=0; i<(sizeof(default_so_paths)/sizeof(char*)); i++)
            {
                if(access_file(default_so_paths[i])) {
                    name = (char *)default_so_paths[i];
                    h = dlopen(name, RTLD_LAZY);
                    if (h) break;
                }
            }
            if (!h)
                return NULL;
        }

        return dlsym(h, name);
    }
    #define CV_CL_GET_PROC_ADDRESS(name) GetProcAddress(name)
#endif
```

- 添加`TBB`支持：`Thread Building Blocks`线程构建模块，是Intel公司开发的并行编程开发的工具，启用这个工具可以加速SURF等运算的过程，在实际测试中，未启用tbb大约提取一张800x600的图片的特征点需要5s以上，而开始了tbb之后在华为Mate 7手机上只需要2s左右
  - 编译`TBB`可能会出现下载失败等错误，需要[手动下载](img/in-post/opencv-android/tbb43_20141204oss_src.tgz)后放入到`opencv_path\3rdparty\tbb`目录内再重新编译即可

```
-- Detected version of GNU GCC: 49 (409)
CMake Warning at 3rdparty/tbb/CMakeLists.txt:109 (message):
  Local copy of TBB source tarball has invalid MD5 hash:
  d41d8cd98f00b204e9800998ecf8427e (expected:
  e903dd92d9433701f097fa7ca29a3c1f)


-- Downloading tbb43_20141204oss_src.tgz
CMake Error at 3rdparty/tbb/CMakeLists.txt:121 (message):
  Failed to download TBB sources (1;"Unsupported protocol"):
  http://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb43_20141204oss_src.tgz
```

- 设置NDK路径到环境变量内`.zshrc/.bashrc`等

```
# /Users/limkuan/.zshrc

ANDROID_NDK=/Users/limkuan/Library/Android/sdk/android-ndk-r12b
```

- cmake编译

```sh
cmake -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DWITH_EIGEN=off -DCMAKE_TOOLCHAIN_FILE=../android/android.toolchain.cmake -DWITH_TBB=on -DANDROID_ABI=armeabi-v7a -DANDROID_NATIVE_API_LEVEL=android-22 ../..

make -j8
```

- 经过漫长的等待编译结束后，opencv链接库都在lib目录内

```
 armeabi-v7a
    ├── libnative_camera_r2.2.0.so
    ├── libnative_camera_r2.3.3.so
    ├── libnative_camera_r3.0.1.so
    ├── libnative_camera_r4.0.0.so
    ├── libnative_camera_r4.0.3.so
    ├── libnative_camera_r4.1.1.so
    ├── libnative_camera_r4.2.0.so
    ├── libnative_camera_r4.3.0.so
    ├── libnative_camera_r4.4.0.so
    ├── libopencv_androidcamera.a
    ├── libopencv_calib3d.a
    ├── libopencv_contrib.a
    ├── libopencv_core.a
    ├── libopencv_features2d.a
    ├── libopencv_flann.a
    ├── libopencv_gpu.a
    ├── libopencv_highgui.a
    ├── libopencv_imgproc.a
    ├── libopencv_info.so
    ├── libopencv_java.so
    ├── libopencv_legacy.a
    ├── libopencv_ml.a
    ├── libopencv_nonfree.a
    ├── libopencv_objdetect.a
    ├── libopencv_ocl.a
    ├── libopencv_photo.a
    ├── libopencv_stitching.a
    ├── libopencv_superres.a
    ├── libopencv_ts.a
    ├── libopencv_video.a
    └── libopencv_videostab.a
```

- 把这些文件复制到工程内，我这里复制到了`libs/opencv/libs_new`，这样就不需要nonfree模块内的代码编译到了`libopencv_nonfree.a`静态链接库里了，不需要另外再编译
- 修改`build.gradle`

```
sourceSets {
    main {
        jniLibs.srcDirs = ['libs/opencv/libs_new']
    }
}
```

- 修改`CMakeList.txt`

```cmake
cmake_minimum_required(VERSION 3.6)

set(CMAKE_VERBOSE_MAKEFILE on)

set(libs "${CMAKE_SOURCE_DIR}/libs/opencv/libs_new")

include_directories(${CMAKE_SOURCE_DIR}/libs/opencv/include)

add_library(libopencv_java SHARED IMPORTED )
set_target_properties(libopencv_java PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_java.so")

add_library(libopencv_info SHARED IMPORTED )
set_target_properties(libopencv_info PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_info.so")

add_library(libopencv_androidcamera STATIC IMPORTED )
set_target_properties(libopencv_androidcamera PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_androidcamera.a")

add_library(libopencv_calib3d STATIC IMPORTED )
set_target_properties(libopencv_calib3d PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_calib3d.a")

add_library(libopencv_contrib STATIC IMPORTED )
set_target_properties(libopencv_contrib PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_contrib.a")

add_library(libopencv_core STATIC IMPORTED )
set_target_properties(libopencv_core PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_core.a")

add_library(libopencv_features2d STATIC IMPORTED )
set_target_properties(libopencv_features2d PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_features2d.a")

add_library(libopencv_flann STATIC IMPORTED )
set_target_properties(libopencv_flann PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_flann.a")

add_library(libopencv_gpu STATIC IMPORTED )
set_target_properties(libopencv_gpu PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_gpu.a")

add_library(libopencv_highgui STATIC IMPORTED )
set_target_properties(libopencv_highgui PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_highgui.a")

add_library(libopencv_imgproc STATIC IMPORTED )
set_target_properties(libopencv_imgproc PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_imgproc.a")

add_library(libopencv_legacy STATIC IMPORTED )
set_target_properties(libopencv_legacy PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_legacy.a")

add_library(libopencv_ml STATIC IMPORTED )
set_target_properties(libopencv_ml PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_ml.a")

add_library(libopencv_nonfree STATIC IMPORTED )
set_target_properties(libopencv_nonfree PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_nonfree.a")

add_library(libopencv_objdetect STATIC IMPORTED )
set_target_properties(libopencv_objdetect PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_objdetect.a")

add_library(libopencv_ocl STATIC IMPORTED )
set_target_properties(libopencv_ocl PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_ocl.a")

add_library(libopencv_photo STATIC IMPORTED )
set_target_properties(libopencv_photo PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_photo.a")

add_library(libopencv_stitching STATIC IMPORTED )
set_target_properties(libopencv_stitching PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_stitching.a")

add_library(libopencv_superres STATIC IMPORTED )
set_target_properties(libopencv_superres PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_superres.a")

add_library(libopencv_ts STATIC IMPORTED )
set_target_properties(libopencv_ts PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_ts.a")

add_library(libopencv_video STATIC IMPORTED )
set_target_properties(libopencv_video PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_video.a")

add_library(libopencv_videostab STATIC IMPORTED )
set_target_properties(libopencv_videostab PROPERTIES
    IMPORTED_LOCATION "${libs}/${ANDROID_ABI}/libopencv_videostab.a")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fexceptions -frtti")

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             src/main/cpp/native-lib.cpp)

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log)

target_link_libraries(native-lib android log
    libopencv_java
    libopencv_info
    libopencv_androidcamera
    libopencv_calib3d
    libopencv_contrib
    libopencv_core
    libopencv_features2d
    libopencv_flann
    libopencv_gpu
    libopencv_highgui
    libopencv_imgproc
    libopencv_legacy
    libopencv_ml
    libopencv_nonfree
    libopencv_objdetect
    libopencv_ocl
    libopencv_photo
    libopencv_stitching
    libopencv_superres
    libopencv_ts
    libopencv_video
    libopencv_videostab
    ${log-lib}
    )
```

- 编译运行后结果应该和上面带nonfree的结果一致

### 4. 其他

- **添加VLFeat支持**：有时候可能需要使用`VLFeat`中的`kdtree`/`kmeans`等实现
  - 下载VLFeat源码，[这个](img/in-post/opencv-android/vlfeat_src.zip)我精简过一些并且添加了`vlfeat.cmake`文件
  - 解压后放入`app/src/main/cpp/vlfeat`目录内
  - 修改**CMakeList.txt**文件，添加如下代码后，重新编译即可`#include "vlfeat/xxxx"`使用`VLFeat`的相关模块

```cmake
# import cmake file of vlfeat
include(src/main/cpp/vlfeat/vlfeat.cmake)

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             src/main/cpp/native-lib.cpp
             # import sourcecode of vlfeat
             ${VLFEAT_SRC})
```

- 参考项目Demo：https://github.com/WideLee/AndroidOpenCVDemo

