 
--*********************************************************************
--*  ENTITY  gc_comp                                                  *
--*  Created    :  Wed Aug 02 09:12:53 2017                           *
--*********************************************************************





 LIBRARY   ieee;
 USE       ieee.std_logic_1164.all;
 USE       ieee.std_logic_unsigned.all;
 USE       ieee.std_logic_arith.all;
 LIBRARY   work;
 USE       work.dma_package.all;




  
 ENTITY   gc_comp   IS
     PORT(
                
               --Internal Bus Connections
                clrn                           : IN    STD_LOGIC;                          -- 0: global reset 
                lclk                           : IN    STD_LOGIC;                          -- Clock
                addr_1v                        : IN    arr_14x0_31x0;
                addr_2v                        : IN    arr_14x0_31x0;
                addr_3v                        : IN    arr_14x0_31x0;
                comp_done                      : OUT   STD_LOGIC;
                gc_and_en                      : IN    STD_LOGIC_VECTOR( 14 DOWNTO 0 );
                R                              : IN    arr_2x0_31x0;
                and_gt_id                      : IN    arr_29x0_31x0;
                layer_num                      : IN    STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                addr_1v_xor                    : IN    arr_14x0_31x0;
                addr_2v_xor                    : IN    arr_14x0_31x0;
                addr_3v_xor                    : IN    arr_14x0_31x0;
                gc_xor_en                      : IN    STD_LOGIC_VECTOR( 14 DOWNTO 0 );
                Bank_B_ready                   : IN    STD_LOGIC;                          -- 1: Memory controller is ready for use, 0: Initializing (due to reset)
                select_gc                      : OUT   STD_LOGIC;                          -- Port select (enable) signal. Should be high until ready comes to transfer current datatransfers data on each port clock
                data_gc_in                     : OUT   STD_LOGIC_VECTOR( 511 DOWNTO 0 );   -- Data to port gc of MultiPort mp
                data_gc_out                    : IN    STD_LOGIC_VECTOR( 511 DOWNTO 0 );   -- Data from port gc of MultiPort mp
                gc_be                          : OUT   STD_LOGIC_VECTOR( 63 DOWNTO 0 );    -- Random port byte enable bits
                addr_gc                        : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );    -- Port address. Apply the new address to this bus before selecting the port (select=VCC)
                write_gc                       : OUT   STD_LOGIC;                          -- Port read\write signal. Assert high to write to the port
                ready_gc                       : IN    STD_LOGIC                           -- Port ready flag (goes high when the data is ready)
     );
 END   gc_comp;
  
  



 ARCHITECTURE  gc_comp_arch  OF  gc_comp  IS



 BEGIN


 comp_done                    <=  '0';
 select_gc                    <=  '0';
 write_gc                     <=  '0';
 data_gc_in                   <=  ( others => '0' );
 gc_be                        <=  ( others => '0' );
 addr_gc                      <=  ( others => '0' );






 END  gc_comp_arch;



