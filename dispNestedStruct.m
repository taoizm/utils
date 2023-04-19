function dispNestedStruct(S)
%DISPNESTEDSTRUCT Display nested struct.
%   dispNestedStruct(S) displays the content of a nested struct array S.
%
%   See also disp.

%   Copyright (c) 2023 Kentaro Tao
%   Released under the MIT license.
%   See https://opensource.org/license/mit/

arguments
    S struct {mustBeScalarOrEmpty(S)}
end

fprintf(getFormattedStr(S));

s = settings;
if strcmp(s.matlab.commandwindow.DisplayLineSpacing.ActiveValue,'loose')
    fprintf('\n');
end

end % dispNestedStruct


%% Private functions
function formattedStr = getFormattedStr(S,level,fieldWidth)
    % GETFORMATTEDSTR Recursively extracts the formatted display text
    %     of a nested struct and returns a formatted string.
    arguments
        S struct {mustBeScalarOrEmpty(S)}
        level = 1
        fieldWidth = getFieldWidth(S)
    end
    
    formattedTextArray = strsplit(evalc('disp(S)'),'\n');
    formattedStr = '';

    fields = fieldnames(S);

    for ii=1:numel(fields)
        str = formattedTextArray{ii};
        padding = repmat(' ', 1, fieldWidth(level) - strfind(str,':') + 1);
        formattedStr = [formattedStr padding str '\n'];

        % Recursively extract the field names
        if isstruct(S.(fields{ii}))
            formattedStr = [formattedStr ...
                getFormattedStr(S.(fields{ii}),level+1,fieldWidth)];
        end
    end
end % getStrArray

function fieldWidth = getFieldWidth(S)
    %GETFIELDWIDTH
    arguments
        S struct
    end
    
    maxLength = getMaxLength(S);
    nestDepth = length(maxLength);

    fieldWidth = 4 * (1:nestDepth); % indent width is fixed to 4
    fieldWidth = 4 + fieldWidth + max(maxLength-fieldWidth);
end % getFieldWidth

function maxLength = getMaxLength(S,level,maxLength)
    %GETMAXLENGTH Finds max field name length at each nested struct level.
    %   maxLength = getMaxLength(S) returns a vector containing the maximum
    %   length of field names at each level of the nested struct S.
    arguments
        S struct
        level = 1
        maxLength = []
    end
    
    fields = fieldnames(S);

    if level > length(maxLength)
        maxLength(level) = 0;
    end
    
    maxLength(level) = max(max(cellfun(@length,fields)),maxLength(level));

    for ii=1:length(fields)
        if isstruct(S.(fields{ii}))
            maxLength = getMaxLength(S.(fields{ii}),level+1,maxLength);
        end
    end
end % getMaxLength

