The functions in this folder convert images into wav files using Canny edge detection to find the bins to fill with the right frequencies. 

Batch_Image_To_Audio        - Run this to convert all the PNGs in the "PNGs to Convert" folder into wav files.
Callabrate_FFT              - Run this in a separate matlab instance while another one runs the FFT code in the parent folder. This code makes some sound that works to check the waterfall code in a fun way ;)
Internal_FFT_Waterfall_test - This code preforms an optimal recovery test. It can serve as a test for the Image to Audio code and also a test of how well any image might be able to decoded.












