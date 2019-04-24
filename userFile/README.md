# What Is This Extension
This Extension can automaticlly process GaoFen optical imageries taken by GF1-WFV, GF1-PMS, GF2-PMS, GF4-PMS, GF6-WFV, GF6-PMS.

The process of images mainly contains orthorectification, spatialSubset(if a shapefile is provided), calibration, registration(if PAN is included), fusion(if PAN is included) and QUAC.


# How To Install
[Surf_Ref.task](https://github.com/desertstsung/Project_JiaoTang/blob/master/userFile/Surf_Ref.task) -> 'xx\Exelis\ENVI53\custom_code'

[jiaotang.sav](https://github.com/desertstsung/Project_JiaoTang/raw/master/userFile/jiaotang.sav) -> 'xx\Exelis\ENVI53\extensions'

You'll find this extension at 'Toolbox\Extensions\Optical GaoFen Auto Process' when you restart ENVI


# Parameters Guide
TGZ Files(required): original TGZ files with name ends with '.tar.gz'

DEM: Digital Elevation Model used to RPCOrthorectification(default: e.Root_Dir + 'data\GMTED2010.jp2')

Shapefile: shapefile used to subset and mask the imagery(default: !NULL)

Registration: whether do registration based on PAN(default: false)

Fusion Method: imagery fusion method(default: NNDiffusePanSharpening)

QUAC: whether do QUick Atmospheric Correction(default: true)

Divide 10k: whether divide 10000 on the outcome of QUAC(default: false)

Display Result: whether diplay result on screen(default: CIR)

Output(required): output file name in ENVI format


# Reminder
1. ENVI52 & ENVI51 are NOT supported yet
2. One-output for one-input or multi-output for identity amount input
3. One shapefile for Multi/one-input or multi-shapefile for identity amount input


# Egg
Update check is available by choose 'Divide 10k' while not QUAC


# CSDN Blog of This Extension
https://blog.csdn.net/desertsTsung/article/details/84679969
