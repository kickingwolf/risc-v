`define D_BASE_ADDR        22'b0000_0000_0000_0000_0000_00//在这次实验中基地址设为全零，所以给朱朱开辟的基地址相当于是0000...0001，这里没有做任意基地址的拓展，相当于只能进行最低位为0的拓展，在此标注以免忘记。
`define D_BASE_ADDR_WIDTH  22
`define DBUFFER_SRAM_DEPTH 256
`define DBUFFER_SRAM_ADDR_WIDTH 8