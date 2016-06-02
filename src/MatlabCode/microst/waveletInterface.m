function [heartRate] = waveletInterface(data, order)
  r = [0.1,0.8,1.5];
  lowb = 0.5;
  highb = 3;
  % TODO parameters fine-tuning
  % TODO bug fix: cannot run correctly now 05/18/2016
  
  numData = size(data, 1);
  lenR = length(r);
  data_m = cell(numData, lenR);
  for j = 1:lenR
    for k = 1:numData
      data_m{k,j} = abs(fft(wavelet_process(data(k,:), r(j), order)));
    end
  end
  peaks = cell(numData, lenR);
  for j = 1:lenR
    for k = 1:numData
      [peaki,peakm] = peakfinder(data_m{k,j},0);
      peaki = peaki - 1;
      peaki = toFreq(peaki);
      peakm = peakm(peaki>lowb & peaki < highb);
      peaki = peaki(peaki>lowb & peaki < highb);
      temp.peaki = peaki;
      temp.peakm = peakm;
      peaks{k,j} = temp;
    end
  end
  heartRate = estimate_first(peaks);
end