function unzip, tgzFn
  dirName = FILE_DIRNAME(tgzFn)
  baseName = FILE_BASENAME(tgzFn)
  outDir = dirName + PATH_SEP() + $
    baseName.Remove(-7) + '_temp'
  FILE_UNTAR, tgzFn, outDir

  RETURN, outDir
end