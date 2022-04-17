parameter DATA_WIDTH = 32;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 5;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 5;
parameter NUMBER_OF_OUTPUT_NODE = 3;

// function for clog2
function integer clog2;
input integer value;
begin
	value = value-1;
	for (clog2=0; value>0; clog2=clog2+1)
		value = value>>1;
end
endfunction