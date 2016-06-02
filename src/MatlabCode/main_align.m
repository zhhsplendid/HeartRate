clear;

wavelet_methods = {};

p = 0;
for i = 1:5
  p = p + 1;
  wavelet_methods{p} = ['db', num2str(i)];
end

for i = 1:5
  p = p + 1;
  wavelet_methods{p} = ['coif', num2str(i)];
end
for i = 1:5
  p = p + 1;
  wavelet_methods{p} = ['sym', num2str(i)];
end


wavelet_r = 0: 0.1 :1;
wavelet_orders = 1: 1: 10;

%fprintf(['DataId\tCancel\tWavelet\torder\tr\t\tMethod\tBPM_PPG\tBPM_watch1_acc\tBPM_watch1_gyro\tBPM_watch2_acc\tBPM_watch2_gyro\n']);
result = cell(1 + length(wavelet_r) * length(wavelet_orders) * 4, 6);
result(1,:) = {'UseCancel', 'UseWavelet', 'wavelet_order', 'wavelet_r', 'wavelet_method', 'abs_error'};
rp = 1;
for r = wavelet_r
  for i = 1:p
      method = wavelet_methods{i};
      for order = wavelet_orders
        err = zeros(4, 6);
        for expr_id = 1:6
          if expr_id ~= 3
            fclose('all'); % To prevent openning too many files
            [bpm, prediction] = alignmentWaveletExpr(expr_id, true, true, r, order, method);
            min_err = 10000;
            best_prediction = 0;
            for j = 1:length(prediction) % find best prediction as min error
             if abs(bpm - prediction(j)) < min_err
               min_err = abs(bpm - prediction(j));
               best_prediction = prediction(j);
             end
            end
            fprintf(['%d Align and Wavelet\t', num2str(r), '\t', num2str(order), ...
                '\t', method, '\t', num2str(bpm), '\t', num2str(best_prediction), ...
                '\t', num2str(min_err), '\n'], expr_id);
            err(1, expr_id) = min_err;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, true, false, r, order, method);
            min_err = 10000;
            best_prediction = 0;
            for j = 1:length(prediction) % find best prediction as min error
             if abs(bpm - prediction(j)) < min_err
               min_err = abs(bpm - prediction(j));
               best_prediction = prediction(j);
             end
            end
            fprintf(['%d Align without Wavelet\t', ...
                '\t', num2str(bpm), '\t', num2str(best_prediction), ...
                '\t', num2str(min_err), '\n'], expr_id);
            err(2, expr_id) = min_err;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, false, true, r, order, method);
            min_err = 10000;
            best_prediction = 0;
            for j = 1:length(prediction) % find best prediction as min error
             if abs(bpm - prediction(j)) < min_err
               min_err = abs(bpm - prediction(j));
               best_prediction = prediction(j);
             end
            end
            fprintf(['%d Wavelet\t', num2str(r), '\t', num2str(order), ...
                '\t', method, '\t', num2str(bpm), '\t', num2str(best_prediction), ...
                '\t', num2str(min_err), '\n'], expr_id);
            err(3, expr_id) = min_err;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, false, false, r, order, method);
            min_err = 10000;
            best_prediction = 0;
            for j = 1:length(prediction) % find best prediction as min error
             if abs(bpm - prediction(j)) < min_err
               min_err = abs(bpm - prediction(j));
               best_prediction = prediction(j);
             end
            end
            fprintf(['%d Biowatch\t', ...
                '\t', num2str(bpm), '\t', num2str(best_prediction), ...
                '\t', num2str(min_err), '\n'], expr_id);
            err(4, expr_id) = min_err;
            
          end
          fprintf('\n');  
        end
        avg_err = sum(err, 2) / 5;
        tmpCell = {1, 1, order, r, method, avg_err(1)};
        for j = 1:length(tmpCell)
            result{rp+1,j} = tmpCell{j};
        end
        
        tmpCell = {1, 0, 0, 0, 'None', avg_err(2)};
        for j = 1:length(tmpCell)
            result{rp+2,j} = tmpCell{j};
        end
        
        tmpCell = {0, 1, order, r, method, avg_err(3)};
        for j = 1:length(tmpCell)
            result{rp+3,j} = tmpCell{j};
        end
        
        tmpCell = {0, 0, 0, 0, 'None', avg_err(4)};
        for j = 1:length(tmpCell)
            result{rp+4,j} = tmpCell{j};
        end
       
        rp = rp + 4;     
      end
  end
end

save('result.mat', 'result');