function [] = nicePrinterNewFormat(str);
    load(str);
    fprintf(['Printing ', str, '\n']);

    fprintf(['Baseline Biowatch average min error = ', num2str(result{2, 6}), '\n']);

    fprintf(['Biowatch + Cancellatiion average min error = ', num2str(result{3, 6}), '\n']);

    best_err = 10000;
    best_i = 1;
    for i = 5:2:size(result, 1)
      if result{i, 6} < best_err
        best_err = result{i, 6};
        best_i = i;
      end
    end

    fprintf(['Wavelet best average min error = ', num2str(best_err), '\n']);
    fprintf('parameters  = ');
    for j = 3:5
      fprintf(['\t', num2str(result{best_i, j})]);
    end
    fprintf('\n');

    best_err = 10000;
    best_i = 1;
    for i = 4:2:size(result, 1)
      if result{i, 6} < best_err
        best_err = result{i, 6};
        best_i = i;
      end
    end

    fprintf(['Wavelet + Cancellation best average min error = ', num2str(best_err), '\n']);
    fprintf('parameters  = ');
    for j = 3:5
      fprintf(['\t', num2str(result{best_i, j})]);
    end
    fprintf('\n');
end
