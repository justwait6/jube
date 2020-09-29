import os
import shutil
import platform

print "====> Clear source path\n"
sourcePath = "." + os.sep + "frameworks" + os.sep + "runtime-src" + os.sep +"proj.android" + os.sep+ "app" + os.sep + "build" + os.sep + "outputs" + os.sep + "apk" + os.sep + "release"
if os.path.exists(sourcePath):
   shutil.rmtree(sourcePath)