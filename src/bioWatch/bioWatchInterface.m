function [predicted_bpm, peak] = bioWatchInterface(data)
% This function gives interface of BioWatch
% Paper reference: http://affect.media.mit.edu/pdfs/15.Hernandez-McDuff-Picard-PervasiveHealth.pdf
% Input:
%   data: n * 4 matrix. (acceleration or gyroscope data) 
%         The four columns are: timestampe, x, y, z
% Output:
%    predicted_bpm: 1 real value. Predicted heart beat per minute
%    peak: Maximum Amplitude, used for combination of sensors
%          see bioWatchSensorCombination or paper for the combination


  AVG_FILTER_SIZE = 14;

  rawData = zscore([data(:,2), data(:,3), data(:,4)]);
  
  %1/7th of Second ~10 point moving average for 100Hz Data
  B = 1/ AVG_FILTER_SIZE * ones(AVG_FILTER_SIZE, 1);
  outData = [filter(B,1, rawData(:,1)) filter(B,1, rawData(:,2)) filter(B,1, rawData(:,3))];
  
  [b,a] = butter(2, [4 11]/(100/2), 'bandpass');
  butData = [filter(b,a,outData(:,1)) filter(b,a,outData(:,2)) filter(b,a,outData(:,3))];
  
  sumData = sqrt(butData(:,1).^2 + butData(:,2).^2 + butData(:,3).^2);
  
  [b1,a1] = butter(2, [0.66 2.5]/(100/2), 'bandpass');
  finalRawData = filter(b1, a1, sumData);
  finalTimedData = [(data(:,1) - data(1,1))/1000, finalRawData];
  
  %Calculating FFT
  fs = 100;
  m = length(finalRawData);   % Window length
  n = pow2(nextpow2(m));      % Transform length
  y = fft(finalRawData, n);   % DFT
  f = (0:n-1) * (fs/n);       % Frequency range
  power = y.*conj(y)/n;       % Power of the DFT
  
  fnew = f(f >= 0.66 & f <= 2.5);
  pnew = [];
  
  for k = 1:1:size(f,2)
    if f(1,k) >= 0.66 && f(1,k) <= 2.5
      pnew = [pnew, power(k, 1)];
    end
  end
  
  %Finding Maximum Amplitude Frequency Index
  peak = max(pnew);
  %ix = find(pnew == p);
  ix = (pnew == peak);
  
  %The frequency
  predicted_bpm = 60 * fnew(1,ix);
  
end 
