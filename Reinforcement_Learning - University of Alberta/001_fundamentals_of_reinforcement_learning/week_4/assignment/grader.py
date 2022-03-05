import numpy as np

def near(arr1, arr2, thresh):
    arr1 = np.array(arr1)
    arr2 = np.array(arr2)
    return np.all(np.abs(arr1 - arr2) < thresh)