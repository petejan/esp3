function update_ytick_labels(~,~,ax)

ytick=get(ax,'ytick');

yticklabel=format_label(ytick,'Distance');

set(ax,'YTickLabel',yticklabel);

end