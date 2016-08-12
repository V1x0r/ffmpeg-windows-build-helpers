# can pass param like "3.1.1" for that ffmpeg release

if [[ $1 != "" ]]; then
  desired_ffmpeg_ver="--ffmpeg-git-checkout-version=n$1"
fi

# synchronize git versions, in case it's doing a git master build (the default)
# so that packaging doesn't detect discrepancies and barf :)
for dir in sandbox/*/ffmpeg_git*; do
  if [[ -d $dir ]]; then # else there were none, and it passes through the string "sandbox/*..." <sigh>
    cd $dir
    if [[ $1 == "" ]]; then
      git pull
    fi 
    # else don't do git pull as it resets the git hash so forces a rebuild even if it's already previously built to that hash, ex: release build
    rm -f already*
    cd ../../.. 
  fi
done

# all are both 32 and 64 bit
./cross_compile_ffmpeg.sh --compiler-flavors=multi --disable-nonfree=y --git-get-latest=n --build-ffmpeg-shared=y $desired_ffmpeg_ver && # normal static and shared
./cross_compile_ffmpeg.sh --compiler-flavors=multi --disable-nonfree=y --git-get-latest=n --build-intel-qsv=n $desired_ffmpeg_ver && # windows xp static
./cross_compile_ffmpeg.sh --compiler-flavors=multi --disable-nonfree=y --git-get-latest=y --high-bitdepth=y $desired_ffmpeg_ver # high bit depth static

rm -rf sandbox/distros # free up space from previous distros
if [[ $1 != "" ]]; then
  prettified_ver=v$1
fi

./patches/all_zip_distros.sh $prettified_ver

