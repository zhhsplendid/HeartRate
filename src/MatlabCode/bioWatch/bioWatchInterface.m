function [predicted_bpm, peak, finalTimedData] = bioWatchInterface(data)
% This function gives interface of BioWatch
% Paper reference: http://affect.media.mit.edu/pdfs/15.Hernandez-McDuff-Picard-PervasiveHealth.pdf
% Input:
%   data: n * 4 matrix. (acceleration or gyroscope data) 
%         The four columns are: timestampe, x, y, z
% Output:
%   predicted_bpm: 1 real value. Predicted heart beat per minute
%   peak: Maximum Amplitude, used for combination of sensors
%     see bioWatchSensorCombination or paper for the combination
% finalTimedData: n * 2 matrix. The two columns are time stamp, processed data
%                 

  AVG_FILTER_SIZE = 14;
  LOW_BAND = 0.66;
  HIGH_BAND = 2.5;
  
  rawData = zscore([data(:,2), data(:,3), data(:,4)]);
  
  %1/7th of Second ~10 point moving average for 100Hz Data
  B = 1/ AVG_FILTER_SIZE * ones(AVG_FILTER_SIZE, 1);
  outData = [filter(B,1, rawData(:,1)) filter(B,1, rawData(:,2)) filter(B,1, rawData(:,3))];
  
  [b,a] = butter(2, [4 11]/(100/2), 'bandpass');
  butData = [filter(b,a,outData(:,1)) filter(b,a,outData(:,2)) filter(b,a,outData(:,3))];
  
  sumData = sqrt(butData(:,1).^2 + butData(:,2).^2 + butData(:,3).^2);
  
  [b1,a1] = butter(2, [0.66 2.5]/(100/2), 'bandpass');
  finalRawData = filter(b1, a1, sumData);
  %finalTimedData = [(data(:,1) - data(1,1))/1000, finalRawData];
  finalTimedData = [data(:,1), finalRawData];
  
  %Calculating FFT
  fs = 100;
  m = length(finalRawData);   % Window length
  n = pow2(nextpow2(m));      % Transform length
  y = fft(finalRawData, n);   % DFT
  f = (0:n-1) * (fs/n);       % Frequency range
  power = y.*conj(y)/n;       % Power of the DFT
  
  fnew = f(f >= LOW_BAND & f <= HIGH_BAND);
  pnew = [];
  
  for k = 1:1:size(f,2)
    if f(1,k) >= LOW_BAND && f(1,k) <= HIGH_BAND
      pnew = [pnew, power(k, 1)];
    end
  end
  
  %Finding Maximum Amplitude Frequency Index
  peak = max(pnew);
  %ix = find(pnew == p);
  ix = (pnew == peak);
  %The frequency
  if size(ix, 1) == 0
    predicted_bpm = 0;
    return;
  end
  peakIndex = -1;
  for i = 1: length(ix)
    if ix(i)
      if peakIndex == -1
        peakIndex = i;
      else %multi maximum amplitude
        ix = false(size(ix));
        ix(peakIndex) = true;
        break;
      end
    end
  end
  
  predicted_bpm = 60 * fnew(1,ix);
  
end 
