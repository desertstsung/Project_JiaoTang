# About
This Extension can automatically process GaoFen optical imageries taken by GF1-WFV, GF1-PMS, GF2-PMS, GF4-PMS, GF6-WFV, GF6-PMS.

The process of images mainly contains orthorectification, spatialSubset(if a shapefile is provided), calibration, registration(if PAN is included), fusion(if PAN is included) and QUAC.


# Install
[```Surf_Ref.task```](https://github.com/desertstsung/Project_JiaoTang/blob/master/userFile/Surf_Ref.task) -> 'xx\Exelis\ENVI53\custom_code'

[```jiaotang.sav```](https://github.com/desertstsung/Project_JiaoTang/raw/master/userFile/jiaotang.sav) -> 'xx\Exelis\ENVI53\extensions'

You'll find this extension at 'Toolbox\Extensions\Optical GaoFen Auto Process' when you restart ENVI


# Usage
```TGZ Files(required)```:original TGZ file(s) with name ends with '.tar.gz'

```DEM```:Digital Elevation Model used to RPCOrthorectification(default: e.Root_Dir + 'data\GMTED2010.jp2')

```Shapefile```:shapefile(s) used to subset and mask the imagery(default: !NULL)

```Registration```:whether do registration based on PAN(default: false)

```Fusion Method```:imagery fusion method(default: NNDiffusePanSharpening)

```QUAC```:whether do QUick Atmospheric Correction(default: true)

```Divide 10k```:whether divide 10000 on the outcome of QUAC(default: false)

```Display Result```:whether diplay result on screen(default: CIR)

```Output(required)```:output file(s) in ENVI format


# Note
+ **IDL85/ENVI53** and higher is required
+ One-output for one-input or multi-output for identity amount input
+ One-shapefile for Multi/one-input or multi-shapefile for identity amount input


# Egg
Update check is available by choose 'Divide 10k' without 'QUAC'


# CSDN BLOG
https://blog.csdn.net/desertsTsung/article/details/84679969
