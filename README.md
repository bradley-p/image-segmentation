# Notable Results 

The code in this repository is a MATLAB implementation of the paper "Automatic Seeded Region Growing for Color Image Segmentation" by Shih and Cheng. The method consists of 4 main components:
1. Converting RGB image to the YCbCr color space
1. Automatically seed selection
1. Region growing based on the initial seeds
1. Merging similar regions (This may include further merging with different threshold values)

The images I used for experiments are randomly selected from the 2019 Kaggle image segmentation competition dataset. Some results are included below. 

-------
**underneath each image, the final similarity and size thresholds are given. Each image was initially merged with the similarity threshold of 0.1 and size of 1/150 of the total image size**

<img src='./fineTunedResults/colors.tif'>
similarity: 0.1, size: 1/150 I used this image as one way to verify that my method worked. If there were bugs, one way they would have manifest themselves is by improperly merging the distinct colors. 


----
<img src='./fineTunedResults/final_seal.tif'>
similarity: 0.2, size: 1/80

----

<img src='./fineTunedResults/final_mountains.tif'>

similarity: 0.15, size: 1/100

----
<img src='./fineTunedResults/final_tree.tif'>

similarity: 0.1, size: 1/100

----
<img src='./fineTunedResults/final_flowers.tif'>

similarity: 0.1, size: 1/100

----

<img src='./fineTunedResults/final_dolphins.tif'>
similarity: 0.14, size: 1/60

----

<img src='./fineTunedResults/final_moose.tif'>
similarity: 0.17, size: 150

-----

<img src='./fineTunedResults/final_castle.tif'>
similarity: 0.1, size: 1/15

-----
# The following results use 0.1 and 1/150 for the thresholds without further merging

----

<img src='./results3/result_0_10_150th_15.jpg'>

----
<img src='./results3/result_0_10_150th_1.jpg'>

----
<img src='./results3/result_0_10_150th_2.jpg'>

-----
<img src='./results3/result_0_10_150th_3.jpg'>

----
<img src='./results3/result_0_10_150th_4.jpg'>

----
<img src='./results3/result_0_10_150th_5.jpg'>

----
<img src='./results3/result_0_10_150th_6.jpg'>

----
<img src='./results3/result_0_10_150th_8.jpg'>

----
<img src='./results3/result_0_10_150th_9.jpg'>

----
<img src='./results3/result_0_10_150th_10.jpg'>

----
<img src='./results3/result_0_10_150th_11.jpg'>

----
<img src='./results3/result_0_10_150th_12.jpg'>

----
<img src='./results3/result_0_10_150th_13.jpg'>

----
<img src='./results3/result_0_10_150th_16.jpg'>

----
<img src='./results3/result_0_10_150th_15.jpg'>

----
<img src='./results3/result_0_10_150th_21.jpg'>

----
<img src='./results3/result_0_10_150th_18.jpg'>

----
<img src='./results3/result_0_10_150th_20.jpg'>

----
