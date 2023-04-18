function dispNestedStruct(S)
%DISPNESTEDSTRUCT Display nested struct.
%   dispNestedStruct(S) displays the content of a nested struct array S.
%
%   See also disp.
%
%   Copyright (c) 2023 Kentaro Tao
%   Released under the MIT license.
%   See https://opensource.org/license/mit/
    
arguments
    S struct {mustBeScalarOrEmpty(S)}
end
    
fprintf(getFormattedStr(S));
fprintf('\n')
    
end % dispNestedStruct
    
    
%% Private functions
function formattedStr = getFormattedStr(S,depth,fieldWidth)
    % GETSTRARRAY Recursively extracts the formatted display text
    %     of a nested struct and returns a formatted string.
    arguments
        S struct {mustBeScalarOrEmpty(S)}
        depth = 1
        fieldWidth = getFieldWidth(S)
    end
    
    formattedTextArray = strsplit(evalc('disp(S)'),'\n');
    formattedStr = '';
    
    fieldNames = fieldnames(S);
    
    for ii=1:numel(fieldNames)
        str = formattedTextArray{ii};
        padding = repmat(' ', 1, fieldWidth(depth) - strfind(str,':') + 1);
        formattedStr = [formattedStr padding str '\n'];
    
        % Recursively extract the field names
        if isstruct(S.(fieldNames{ii}))
            formattedStr = [formattedStr ...
                getFormattedStr(S.(fieldNames{ii}),depth+1,fieldWidth)];
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
    
function maxLength = getMaxLength(S,depth,maxLength)
    %GETMAXLENGTH Finds max field name length at each nested struct level.
    %   maxLength = getMaxLength(S) returns a vector containing the maximum
    %   length of field names at each level of the nested struct S.
    arguments
        S struct
        depth = 1
        maxLength = []
    end

    fieldNames = fieldnames(S);
    
    if depth > length(maxLength)
        maxLength(depth) = 0;
    end
    
    maxLength(depth) = max(max(cellfun(@length,fieldNames)),maxLength(depth));
    
    for ii=1:length(fieldNames)
        if isstruct(S.(fieldNames{ii}))
            maxLength = getMaxLength(S.(fieldNames{ii}),depth+1,maxLength);
        end
    end
end % getMaxLength

