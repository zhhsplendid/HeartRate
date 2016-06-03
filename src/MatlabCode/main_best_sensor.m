clear;


wavelet_methods = {'db1'};

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
result = cell(1 + length(wavelet_r) * length(wavelet_orders) * 4, 7);
result(1,:) = {'UseCancel', 'UseWavelet', 'wavelet_order', 'wavelet_r', 'wavelet_method', 'abs_error', 'sensor'};
rp = 1;

bio_err = zeros(4, 6);
can_err = zeros(2, 6);
for expr_id = 1:6
    if expr_id ~= 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % baseline: Biowatch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [bpm, prediction] = alignmentWaveletExpr(expr_id, false, false, 0, 0, '');
        for j = 1:length(prediction) 
            bio_err(j, expr_id) = abs(bpm - prediction(j)) ;
        end
        fprintf(['%d Biowatch\t', ...
            '\t', num2str(bpm), '\n'], expr_id);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % cancel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [bpm, prediction] = alignmentWaveletExpr(expr_id, true, false, 0, 0, '');
        for j = 1:length(prediction) 
            can_err(j, expr_id) = abs(bpm - prediction(j)) ;
        end
        fprintf(['%d Align without Wavelet\t', ...
            '\t', num2str(bpm), '\n'], expr_id);
    end
end
bio_avg = sum(bio_err, 2) / 5;
can_avg = sum(can_err, 2) / 5;

[bio_best, bio_sensor] = min(bio_avg);
[can_best, can_sensor] = min(can_avg);

tmpCell = {0, 0, 0, 0, 'None', bio_best, bio_sensor};
for j = 1:length(tmpCell)
    result{rp+1, j} = tmpCell{j};
end
tmpCell = {1, 0, 0, 0, 'None', can_best, can_sensor};
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
        cw_err = zeros(2, 6);
        w_err = zeros(4, 6);
        for expr_id = 1:6
          if expr_id ~= 3
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % cancel and wavelet
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, true, true, r, order, method);
            
            for j = 1:length(prediction) 
              cw_err(j, expr_id) = abs(bpm - prediction(j));
            end
            fprintf(['%d Align and Wavelet\t', num2str(r), '\t', num2str(order), ...
                '\t', method, '\t', num2str(bpm), '\n'], expr_id);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % wavelet
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [bpm, prediction] = alignmentWaveletExpr(expr_id, false, true, r, order, method);
            
            for j = 1:length(prediction) 
              w_err(j, expr_id) = abs(bpm - prediction(j));
            end
            fprintf(['%d Wavelet\t', num2str(r), '\t', num2str(order), ...
                '\t', method, '\t', num2str(bpm), '\n'], expr_id);
          end
          fprintf('\n');  
        end
        cw_avg = sum(cw_err, 2) / 5;
        w_avg = sum(w_err, 2) / 5;
        [cw_best, cw_sensor] = min(cw_avg);
        [w_best, w_sensor] = min(w_avg);
        
        tmpCell = {1, 1, order, r, method, cw_best, cw_sensor};
        for j = 1:length(tmpCell)
            result{rp+1,j} = tmpCell{j};
        end
                
        tmpCell = {0, 1, order, r, method, w_best, w_sensor};
        for j = 1:length(tmpCell)
            result{rp+2,j} = tmpCell{j};
        end
       
        rp = rp + 2;     
      end
  end
end

save('result_sensor.mat', 'result');