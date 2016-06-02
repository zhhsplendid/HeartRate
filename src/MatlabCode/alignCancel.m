function [cancelled_data] = alignCancel(data, data_pairs)
% input:
%   data: size k cell. In each cell, contains raw data of one sensor
%        the raw data is m * 4 matrix. m is the length of raw data
%        four columns are: timestamp, x, y, z
%   data_pairs: h * 2 matrix, each row has two integer [x, y],
%        means, data{x} should be cancelled from data{y} (data{x} - data{y})  
%                              
% output:
%   cannelled data as cell

  n = size(data_pairs, 1);
  cancelled_data = cell(1, length(data) - n);
  
  % cancel data 
  for i = 1: n
      
    %cancelation is target - source
    sourceTimedData = data{data_pairs(i, 2)};
    targetTimedData = data{data_pairs(i, 1)};
    
    % select those points with same timestamps
    sourceTimestamps = sourceTimedData(:, 1);
    targetTimestamps = targetTimedData(:, 1);
    
    sourceBaseTime = sourceTimestamps(1);
    targetBaseTime = targetTimestamps(1);
    
    sLen = length(sourceTimestamps);
    tLen = length(targetTimestamps);
    
    s = 1;
    t = 1;
    
    sourceData = [];
    targetData = [];
    
    while s <= sLen && t <= tLen
      sourceTime = sourceTimestamps(s) - sourceBaseTime;
      targetTime = targetTimestamps(t) - targetBaseTime;
      diff = sourceTime - targetTime;
      if diff == 0
        sourceData = [sourceData; sourceTimedData(s, 2:end)];
        targetData = [targetData; targetTimedData(t, 2:end)];
        s = s + 1;
        t = t + 1;
      elseif diff < 0
        s = s + 1;
      else
        t = t + 1;
      end
    end
    
    %if isempty(sourceData)
    %  fprintf('Warning: we did not find data with same relative time\n');
    %else
    %  fprintf('Size of aligment data: %d\n', length(sourceData));
    %end
    
    
    % compute rotation R and translation t for alignment
    % That is min. sum_i ||R*sourceData(i,:) + t - targetData(i,:)||^2
    
    [regParams, Bfit, ErrorStats] = absor(sourceData', targetData');
    
    rotMatrix = regParams.R;
    trans = regParams.t;
    
    targetFit = (rotMatrix * sourceTimedData(:,2:end)' + repmat(trans, 1, size(sourceTimedData, 1)))';
    sourceRelaTime = sourceTimedData(:, 1) - sourceBaseTime;
    targetRelaTime = targetTimedData(:, 1) - targetBaseTime;
    
    cancelledTarget = zeros(size(targetTimedData));
    cancelledTarget(:, 1) = targetTimedData(:, 1);
    
    % To remove duplicate timestamp in our data
    uniqueSrcRelaTime = sourceRelaTime(1);
    uniqueFit = targetFit(1,:);
    for j = 2: length(sourceRelaTime)
      if sourceRelaTime(j) ~= sourceRelaTime(j - 1);
        uniqueSrcRelaTime = [uniqueSrcRelaTime; sourceRelaTime(j)];
        uniqueFit = [uniqueFit; targetFit(j, :)];
      end
    end
    sourceRelaTime = uniqueSrcRelaTime;
    targetFit = uniqueFit;
   
    cancelledTarget(:, 2:end) = targetTimedData(:, 2:end) - interp1(sourceRelaTime, targetFit, targetRelaTime, 'cubic');
    
    cancelled_data{i} = cancelledTarget;
  end
  
  % add remaining data, which doesn't need to be cancelled.
  p = n;
  for i = 1: length(data)
    if size(find(i == data_pairs), 1) == 0 % row not in pairs
      p = p + 1;
      cancelled_data{p} = data{i};
    end
  end
  
  if p ~= length(data) - n
    fprintf('Warning: something may be wrong in cancelling\n');
  end
end