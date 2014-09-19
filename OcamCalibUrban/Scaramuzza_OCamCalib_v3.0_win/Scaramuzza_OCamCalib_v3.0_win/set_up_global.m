
%Prepares workspace for toolbox

%Initialize global variable class
if ~exist('calib_data','var')
    calib_data = C_calib_data;
else
    calib_props = properties(calib_data);
    for i=1:size(calib_props,1)
        if strcmp(calib_props{i},'ocam_model')
            eval(['prop_fields = fieldnames(calib_data.' calib_props{i} ');']);
            for j = 1:size(prop_fields,1)
                eval(['calib_data.' calib_props{i} '.' prop_fields{j} '=[];']);
            end
        else
            eval(['calib_data.' calib_props{i} '=[];']);
        end
    end
    
    clear i j calib_props prop_fields;
end