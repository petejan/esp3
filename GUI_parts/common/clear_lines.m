function clear_lines(ah)
u=get(ah,'children');
for ii=1:length(u)
    if (isa(u(ii),'matlab.graphics.primitive.Line')||isa(u(ii),'matlab.graphics.chart.primitive.Line'))...
            &&~strcmp(get(u(ii),'tag'),'bottom')...
            &&~strcmp(get(u(ii),'tag'),'track')...
            &&~strcmp(get(u(ii),'tag'),'region')
        delete(u(ii));
    end
end

end