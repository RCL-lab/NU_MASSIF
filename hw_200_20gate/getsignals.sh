cat gc_comp.vhd | grep constant;
cat gc_comp.vhd | awk '/^ *signal/ {str = sub(/;/, ,); print ,}'
