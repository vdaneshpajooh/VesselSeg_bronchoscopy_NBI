function scores = quant_eval(pred,gt)
% this function outputs the following performance metrics:
% accuracy, precision, sensitivity, specificity, and F1 score

pred_1s = pred==1;
pred_0s = pred==0;

gt_1s = gt==1;
gt_0s = gt==0;

TP_matrix = and(gt_1s,pred_1s);
TN_matrix = and(gt_0s,pred_0s);
FP_matrix = and(pred_1s,gt_0s);
FN_matrix = and(pred_0s,gt_1s);

TP = sum(TP_matrix(:));
TN = sum(TN_matrix(:));
FP = sum(FP_matrix(:));
FN = sum(FN_matrix(:));

scores.accuracy = (TP+TN)/(TP+TN+FP+FN);

precision = TP/(TP+FP);
recall = TP/(TP+FN);
scores.F1_score = 2*(precision*recall)/(precision+recall);

scores.sensitivity = recall;
scores.specificity = TN/(TN+FP);
scores.precision = precision;

end