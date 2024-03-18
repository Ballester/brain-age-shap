library(xgboost)
library(SHAPforxgboost)

# setwd('<your_path>')

df = read.csv('freesurfer_data.csv')
df_demo = read.csv('subjids_age_sex.csv')
rownames(df) = df$X
rownames(df_demo) = df_demo$ID
df_demo = df_demo[rownames(df),]
df_demo$Sex = df_demo$Gender
df_demo$age = df_demo$AgeScan
df = df[complete.cases(df_demo$Sex),]
df_demo = df_demo[complete.cases(df_demo$Sex),]

df$X = NULL
df_demo$ID = NULL
df_demo$AgeScan = NULL
df_demo$Gender = NULL

# maybe age-correct the predictions independently for male and female too
df_male = df[df_demo$Sex == 1,]
df_demo_male = df_demo[df_demo$Sex == 1,]
df_female = df[df_demo$Sex == 2,]
df_demo_female = df_demo[df_demo$Sex == 2,]

load('path_to_brainage_models_kaufmann/brainageModels.RData')
mdl_agepred_male$feature_names = colnames(df)
mdl_agepred_female$feature_names = colnames(df)
pred_male = predict(mdl_agepred_male, xgb.DMatrix(as.matrix(df_male)))
write.csv(data.frame(rownames(df_male), pred_male), "pred_male.csv")
pred_female = predict(mdl_agepred_female, xgb.DMatrix(as.matrix(df_female)))
write.csv(data.frame(rownames(df_female), pred_female), "pred_female.csv")

df_male$pred = pred_male
df_female$pred = pred_female

df[rownames(df_male), 'pred'] = df_male$pred
df[rownames(df_female), 'pred'] = df_female$pred

df_analysis = df_demo[rownames(df),]
df_analysis$pred = df$pred
#df_analysis

df_analysis$pred - df_analysis$age
plot(df_analysis$pred, df_analysis$age)
plot(df_analysis$age, df_analysis$pred-df_analysis$age)

### separate analyses for males and females here?
df_male$pred = NULL
df_female$pred = NULL
shap_values_male = shap.values(xgb_model=mdl_agepred_male, X_train=as.matrix(df_male))
shap_values_female = shap.values(xgb_model=mdl_agepred_female, X_train=as.matrix(df_female))
#xgb.plot.shap.summary(data=as.matrix(df_male), model=mdl_agepred_male)
#xgb.plot.shap.summary(data=as.matrix(df_female), model=mdl_agepred_female)

shap.plot.summary.wrap2(shap_values_male$shap_score, X=as.matrix(df_male), top_n=10)

shap_long_male <- shap.prep(shap_contrib = shap_values_male$shap_score, X_train = as.matrix(df_male))
shap_long_female <- shap.prep(shap_contrib = shap_values_female$shap_score, X_train = as.matrix(df_female))
shap.plot.dependence(data_long = rbind(shap_long_male, shap_long_female), x = "X3rd.Ventricle", color_feature="lh_L_STSvp_ROI_thickness")

top_n_male = shap_values_male$mean_shap_score[1:10]
top_n_female = shap_values_female$mean_shap_score[1:10]
top_n_names = c(names(top_n_male), names(top_n_female))
top_n_names = unique(top_n_names)

df_shap_male = data.frame(shap_values_male$shap_score)
rownames(df_shap_male) = rownames(df_demo_male)
df_shap_female = data.frame(shap_values_female$shap_score)
rownames(df_shap_female) = rownames(df_demo_female)
df_shap = rbind(df_shap_male, df_shap_female)
write.csv(df_shap, "shap_values.csv")
