import os
import shutil
print("start copy apks....")
desPath = "." + os.sep + "apk"
sourcePath = "." + os.sep + "frameworks" + os.sep + "runtime-src" + os.sep +"proj.android" + os.sep+ "app" + os.sep + "build" + os.sep + "outputs" + os.sep + "apk" + os.sep + "release"
if os.path.exists(desPath):
   shutil.rmtree(desPath)

#os.makedirs(desPath)
if os.path.exists(sourcePath):
    print("copytree")
    print(sourcePath)
    print(desPath)
    shutil.copytree(sourcePath, desPath + os.sep)

print("copy apks success!")