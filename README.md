# Gray matter volume drives the brain age gap in schizophrenia: a SHAP study

This repository reproduces the results of the paper *Gray matter volume drives the brain age gap in schizophrenia: a SHAP study*.

- The file run_kaufmann.R is an R script that runs the Kaufmann's brain age models and extracts their SHAP values 
- Then, analysis.ipynb is a Jupyter Notebook (Python) that uses that data to perform the statistical analyses seen in the paper


## Additional information
The results are based on pretrained brain age models available through Kaufmann et al. paper at:
https://www.nature.com/articles/s41593-019-0471-7.

Kaufmann et al. models can be downloaded at:
https://github.com/tobias-kaufmann/brainage.

In order to run this experiment for a new dataset, follow the directions in the paper to run FreeSurfer with the HCP atlas and extract the 1,084 features that are needed to run the models.