clear;
DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/';
DATA_FILES = {[DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_acc.txt'], ...
                   [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_acc.txt'], ...
                   [DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
                   [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
                   [DATA_PATH, 'heartrate/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
                   [DATA_PATH, 'heartrate/rawHRData-', int2str(EXPR_ID), '.csv'], ...
                  };
numData = length(DATA_FILES);
for i = 1: numData
    %DATA_FILES{i}
    data{i} = importdata(DATA_FILES{i}, ':');
end

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

bio_err = zeros(6);
can_err = zeros(6);
for expr_id = 1:6
    if expr_id ~= 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % baseline: Biowatch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [bpm, prediction] = alignmentWaveletExpr(expr_id, false, false, r, order, method, data);
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
        bio_err(expr_id) = min_err;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % cancel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [bpm, prediction] = alignmentWaveletExpr(expr_id, true, false, r, order, method, data);
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
        can_err(2, expr_id) = min_err;
    end
end
bio_avg = sum(bio_err) / 5;
can_avg = sum(can_avg) / 5;
tmpCell = {0, 0, 0, 0, 'None', bio_avg};
for j = 1:length(tmpCell)
    result{rp+1, j} = tmpCell{j};
end
tmpCell = {1, 0, 0, 0, 'None', can_avg};
for j = 1:length(tmpCell)
    result{rp+2, j} = tmpCell{j};
end
rp = rp + 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wavelet with & without cancel
%%%%%%%%%%%%%%%%%%%%%%%%%%

for r = wavelet_r
  for i = 1:p
      method = wavelet_methods{i};
      for order = wavelet_orders
        err = zeros(2, 6);
        for expr_id = 1:6
          if expr_id ~= 3
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % cancel and wavelet
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, true, true, r, order, method, data);
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % wavelet
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, false, true, r, order, method, data);
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
            err(2, expr_id) = min_err;
          end
          fprintf('\n');  
        end
        avg_err = sum(err, 2) / 5;
        tmpCell = {1, 1, order, r, method, avg_err(1)};
        for j = 1:length(tmpCell)
            result{rp+1,j} = tmpCell{j};
        end
                
        tmpCell = {0, 1, order, r, method, avg_err(2)};
        for j = 1:length(tmpCell)
            result{rp+2,j} = tmpCell{j};
        end
       
        rp = rp + 2;     
      end
  end
end

save('result.mat', 'result');