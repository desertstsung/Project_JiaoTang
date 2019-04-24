FUNCTION unzip, tgzFn
  dirName = FILE_DIRNAME(tgzFn)
  baseName = FILE_BASENAME(tgzFn)
  outDir = dirName + '\' + baseName.Remove(-7) + '_temp'
  outTar = outDir + '.tar'
  FILE_GUNZIP, tgzFn, outTar
  FILE_UNTAR, outTar, outDir
  FILE_DELETE, outTar

  RETURN, outDir
END