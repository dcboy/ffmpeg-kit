./android.sh --lts --enable-android-media-codec --enable-x264 --enable-gpl --disable-x86 --disable-x86-64

新增 mediacodec encoder 支持使用 android 原生编码

-vcode h264_hlmediacodec

// ==
./android.sh --lts --enable-android-media-codec --enable-x264 --enable-gpl --disable-x86 --disable-x86-64 --disable-arm64-v8a --disable-arm-v7a-neon --no-ffmpeg-kit-protocols

## latest

```
./android.sh --enable-x264 --enable-gpl --disable-x86 --disable-x86-64 --disable-arm64-v8a --disable-arm-v7a-neon --no-ffmpeg-kit-protocols


./android.sh --lts --api-level=22 --enable-android-media-codec --enable-x264 --enable-gpl --disable-x86 --disable-x86-64 --disable-arm64-v8a --no-ffmpeg-kit-protocols

-vcode h264_hlmediacodec
```
