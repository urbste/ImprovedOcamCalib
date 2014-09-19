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
nr_tests   = 4;

%% load scaramuzza data
for i=1:nr_tests  
    path = sprintf('CalibData%i.mat', i);
    calibMeth{i} = load(path);
end

for cam=1:nr_cams
    for meth = 1:nr_tests
        mse(cam,meth) = mean(calibMeth{meth}.calib_data{cam}.errMean);
    end
end

figure
bar(mse)
title('root mean square error')
xlabel('data set')
ylabel('root mean square error [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')

%% ocam_calib with and without iteration
for cam=1:nr_cams
    for meth = 1:nr_tests    
        mse(cam,meth) = mean(calibMeth{meth}.calib_data{cam}.errStd);
    end
end
figure
bar(mse)
title('Mean standard deviation')
xlabel('data set')
ylabel('mean standard deviation [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')

%% ocam_calib with and without iteration
for cam=1:nr_cams
    for meth = 1:nr_tests    
        mse(cam,meth) = calibMeth{meth}.calib_data{cam}.mse;
    end
end
figure
bar(mse)
title('Sum of squared errors')
xlabel('data set')
ylabel('sum of squared errors [pixel]')
legend('ocam standard','ocam subpixel', 'urban' ,'urban robust')


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
        for imgs = calibMeth{meth}.calib_data{cam}.ima_proc
            try
            if (isempty(calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO))
                stdEOangle(imgs,meth,cam) = 0;
                stdEOpos(imgs,meth,cam) = 0;
            else
                
                stdEOangle(imgs,meth,cam) = 1e3*mean([calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(1),...
                                              calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(2),...
                                              calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(3)]);
                stdEOpos(imgs,meth,cam)   = mean([calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(4),...
                                                  calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(5),...
                                                  calibMeth{meth}.calib_data{cam}.statEO{imgs}.stdEO(6)]);
               badIdx = [badIdx, imgs]
            end
            catch
                stdEOangle(imgs,meth,cam) = 0;
                stdEOpos(imgs,meth,cam) = 0;
            end
        end
        
        stdEOangleA(cam,meth) = mean(stdEOangle(calibMeth{meth}.calib_data{cam}.ima_proc,meth,cam));
        stdEOposA(cam,meth) = mean(stdEOpos(calibMeth{meth}.calib_data{cam}.ima_proc,meth,cam));
        badIdx = [];
    end
end

lauf = 0;
for cam=1:nr_cams
    for meth = 3:nr_tests
        for imgs = calibMeth{meth}.calib_data{cam}.ima_proc
                stdEOangle(imgs,meth,cam) = 1e3*mean([calibMeth{meth}.calib_data{cam}.statEO.stdEO(lauf+1),...
                                              calibMeth{meth}.calib_data{cam}.statEO.stdEO(2+lauf),...
                                              calibMeth{meth}.calib_data{cam}.statEO.stdEO(3+lauf)]);
                stdEOpos(imgs,meth,cam)   = mean([calibMeth{meth}.calib_data{cam}.statEO.stdEO(4+lauf),...
                                              calibMeth{meth}.calib_data{cam}.statEO.stdEO(5+lauf),...
                                              calibMeth{meth}.calib_data{cam}.statEO.stdEO(6+lauf)]);
            lauf = lauf+6;
        end
        lauf = 0;
        stdEOangleA(cam,meth) = mean(stdEOangle(calibMeth{meth}.calib_data{cam}.ima_proc,meth,cam));
        stdEOposA(cam,meth) = mean(stdEOpos(calibMeth{meth}.calib_data{cam}.ima_proc,meth,cam));
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