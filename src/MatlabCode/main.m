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


%wavelet_r = 0: 0.1 :1;
wavelet_r = 0.1;
wavelet_orders = 1: 1: 10;

fprintf(['DataId\tWeatherWavelet\torder\tr\t\tMethod\tBPM_PPG\tBPM_watch1_acc\tBPM_watch1_gyro\tBPM_watch2_acc\tBPM_watch2_gyro\n']);


for r = wavelet_r
  for i = 1:p
      method = wavelet_methods{i};
      for order = wavelet_orders
        for expr_id = 1:6
          if expr_id ~= 3
            fclose('all'); % To prevent openning too many files
            [bpm, prediction] = waveletExpr(expr_id, true, r, order, method);
            %[bpm, prediction] = alignmentWaveletExpr(expr_id, true, true, r, order, method);
            %fprintf(['Experiment Data ID: ', num2str(expr_id), '\n']);
            fprintf([num2str(expr_id), '\t\t\ttrue\t\t\t', num2str(order), '\t', num2str(r), '\t\t', '%-8s', num2str(bpm)], method);
            
            for i = 1:length(prediction)
              fprintf(['\t\t\t', num2str(prediction(i))]);
            end
            fprintf('\n');

            [bpm, prediction] = waveletExpr(expr_id, false, r, method);
            fprintf([num2str(expr_id), '\t\t\tfalse\t\t\t0\tNone\t%-8s', num2str(bpm)], 'None');
            
            for i = 1:length(prediction)
              fprintf(['\t\t\t', num2str(prediction(i))]);
            end
            fprintf('\n');

          end
          fprintf('\n');
        end
      end
  end
end