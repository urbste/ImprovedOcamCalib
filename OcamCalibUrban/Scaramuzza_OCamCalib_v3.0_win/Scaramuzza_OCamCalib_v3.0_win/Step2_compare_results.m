%     Steffen Urban email: steffen.urban@kit.edu
%     Copyright (C) 2014  Steffen Urban
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

clear all
close all

% change those if you changed Step1_perform_test_calibrations.m
nr_cams    = 7;
nr_tests   = 5;

%% load scaramuzza data
for i=1:nr_tests  
    path = sprintf('CalibData_ALL%i.mat', i);
    calibMeth{i} = load(path);
end

for cam=1:nr_cams
    for meth = 1:nr_tests
        rms(cam,meth) = calibMeth{meth}.calib_data{cam}.rms;
    end
end


figure
bar(rms)
title('root mean square error')
xlabel('data set')
ylabel('root mean square error [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


for cam=1:nr_cams
    for meth = 1:nr_tests
        runtime(cam,meth) = calibMeth{meth}.calib_data{cam}.runtime;
    end
end


figure
bar(runtime)
title('root mean square error')
xlabel('data set')
ylabel('root mean square error [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


for cam=1:nr_cams
    for meth = 1:2
        rmsAfterCenter(cam,meth) = calibMeth{meth}.calib_data{cam}.rmsAfterCenter;
        rmsAfterCenter1(cam,meth) = calibMeth{meth}.calib_data{cam}.rms;
    end
end


figure
bar(rmsAfterCenter)
title('root mean square error')
xlabel('data set')
ylabel('root mean square error [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


% 
% %% ocam_calib with and without iteration
% for cam=1:nr_cams
%     for meth = 1:nr_tests    
%         mse(cam,meth) = mean(calibMeth{meth}.calib_data{cam}.errStd);
%     end
% end
% figure
% bar(mse)
% title('Mean standard deviation')
% xlabel('data set')
% ylabel('mean standard deviation [pixel]')
% legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')
% 
% %% ocam_calib with and without iteration
% for cam=1:nr_cams
%     for meth = 1:nr_tests    
%         mse(cam,meth) = calibMeth{meth}.calib_data{cam}.mse;
%     end
% end
% figure
% bar(mse)
% title('Sum of squared errors')
% xlabel('data set')
% ylabel('sum of squared errors [pixel]')
% legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


% for cam=1:nr_cams
%     for meth = 1:2
%         for imgs = calibMeth{meth}.calib_data{cam}.ima_proc
%             stdEOangle(imgs,meth,cam) = mean(calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(1:3,:));
%             stdEOpos(imgs,meth,cam)   = mean(extractEulerFromRUrban(rodrigues(calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(4:6,:))));
%         end
%         stdEOangleA(cam,meth) = mean(stdEOangle(:,meth,cam));
%         stdEOposA(cam,meth) = mean(stdEOpos(:,meth,cam));
%     end
% end


badIdx = [];
for cam=1:nr_cams
    for meth = 1:2
        stdEOangle = [];
        stdEOpos = [];
        for imgs = calibMeth{meth}.calib_data{cam}.ima_proc
            try % if an image was omitted during corner extraction
            if (~isempty(calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO))
                stdEOangle = [stdEOangle 
                              1e3*[calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(1)
                                   calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(2)
                                   calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(3)]];
                stdEOpos   = [stdEOpos 
                              [calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(4)
                              calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(5)
                              calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(6)]];
               badIdx = [badIdx, imgs];
            end
            catch

            end
        end       
        stdEOangleA(cam,meth) = mean(stdEOangle);
        stdEOposA(cam,meth) = mean(stdEOpos);
        badIdx = [];
    end
end

lauf = 0;
for cam=1:nr_cams
    for meth = 3:nr_tests
        stdEOangle = [];
        stdEOpos = [];
        for imgs = 1:length(calibMeth{meth}.calib_data{cam}.ima_proc)
            stdEOangle = [stdEOangle
                          1e3*[calibMeth{meth}.calib_data{cam}.statEO.stdEO(1+lauf)
                               calibMeth{meth}.calib_data{cam}.statEO.stdEO(2+lauf)
                               calibMeth{meth}.calib_data{cam}.statEO.stdEO(3+lauf)]];
            stdEOpos   = [stdEOpos
                          [calibMeth{meth}.calib_data{cam}.statEO.stdEO(4+lauf)
                          calibMeth{meth}.calib_data{cam}.statEO.stdEO(5+lauf)
                          calibMeth{meth}.calib_data{cam}.statEO.stdEO(6+lauf)]];
            lauf = lauf+6;
        end
        lauf = 0;
        stdEOangleA(cam,meth) = median(stdEOangle);
        stdEOposA(cam,meth) = median(stdEOpos);
    end
end


figure
bar(stdEOangleA)
title('mean standard deviation of camera orientations') 
xlabel('data set')
ylabel('mean standard deviation[mrad]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


figure
bar(stdEOposA)
title('mean standard deviation of camera positions')
xlabel('data set')
ylabel('standard deviation [mm]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')

%% IO covariance matrix
lauf = 0;
for cam=1:nr_cams
    for meth = 1:nr_tests
        offset = calibMeth{meth}.calib_data{cam}.ima_proc(end) * 6;
        stdIOcde = [calibMeth{meth}.calib_data{cam}.statIO.stdIO(3)
                    calibMeth{meth}.calib_data{cam}.statIO.stdIO(4)
                    calibMeth{meth}.calib_data{cam}.statIO.stdIO(5)];
        stdIOxcyc   = [calibMeth{meth}.calib_data{cam}.statIO.stdIO(1)
                       calibMeth{meth}.calib_data{cam}.statIO.stdIO(2)];
        stdIOss   = [calibMeth{meth}.calib_data{cam}.statIO.stdIO(6:end)'];
        
        stdEOcdeA(cam,meth) = median(stdIOcde);
        stdEOxcycA(cam,meth) = median(stdIOxcyc);
        stdEOssA(cam,meth) = median(stdIOss);
    end
end









% %% degree
% for i=4:6
%     path = sprintf('CalibData%i3.mat', i);
%     calibDegree{i-3} = load(path);
% end
% mseDeg =[]
% for cam=1:nr_cams
%     for meth = 1:3
%         mseDeg(cam,meth) = mean(calibDegree{meth}.calib_data{cam}.errMean);
%     end
% end
% 
% figure
% bar(mseDeg)
% xlabel('image')
% ylabel('mean squared error [pixel]')
% legend()



%% find center procedure
% for i=1:nr_tests-2
%     path = sprintf('CalibDataPP%i.mat', i+1);
%     calibCenter{i} = load(path);
% end
% msePP =[]
% msePPstd = [];
% for cam=1:nr_cams
%     for meth = 1:nr_tests-2
% %         msePP(cam,meth) = mean(calibCenter{meth}.calib_data{cam}.errMean);    % with refinement
% %         msePPstd(cam,meth) = mean(calibCenter{meth}.calib_data{cam}.errStd);    % with refinement
%         msePPstd(cam,meth) = mean(calibCenter{meth}.calib_data{cam}.errStdPP);    % without refinement
%         msePP(cam,meth) = mean(calibCenter{meth}.calib_data{cam}.errMeanPP);    % without refinement
%         
%     end
% end
% 
% for cam=1:nr_cams
%   a(cam) = mean(calibCenter{2}.calib_data{cam}.errMeanPP)
% end
% figure
% bar(msePP)
% xlabel('data set')
% ylabel('mean squared error [pixel]')
% legend('scaramuzza subpixel', 'urban')

% for cam=1:nr_cams
%     for meth = 1:nr_tests
%         M = [calibMeth{meth}.calib_data{cam}.Xt,calibMeth{meth}.calib_data{cam}.Yt,ones(size(calibMeth{meth}.calib_data{cam}.Xt,1),1)];
%         
%         if (nr_cams <=3)
%             [err,stderr,MSE] = reprojectpoints_adv(calibMeth{meth}.calib_data{cam}.ocam_model, ...
%                                           calibMeth{meth}.calib_data{cam}.RRfin, calibMeth{meth}.calib_data{cam}.ima_proc, ...
%                                           calibMeth{meth}.calib_data{cam}.Xp_abs, calibMeth{meth}.calib_data{cam}.Yp_abs, M);
%         else
%             [err,stderr,MSE] = reprojectpoints_advUrban(calibMeth{meth}.calib_data{cam}.ocam_model, ...
%                                           calibMeth{meth}.calib_data{cam}.RRfin, calibMeth{meth}.calib_data{cam}.ima_proc, ...
%                                           calibMeth{meth}.calib_data{cam}.Xp_abs, calibMeth{meth}.calib_data{cam}.Yp_abs, M ,calibMeth{meth}.calib_data{cam}.weights);
%         end                            
%         calibMeth{meth}.calib_data{cam}.errMean = err;
%         calibMeth{meth}.calib_data{cam}.errStd = stderr;
%         calibMeth{meth}.calib_data{cam}.mse = MSE;
%      end
% end