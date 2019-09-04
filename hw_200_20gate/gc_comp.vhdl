
--*********************************************************************
--*  ENTITY  gc_comp                                                  *
--*  Created    :  Wed Apr 05 14:01:54 2017                           *
--*********************************************************************

LIBRARY   ieee;
USE       ieee.std_logic_1164.all;
USE       ieee.numeric_std.all;


package dma_package IS
    TYPE   arr_19x0_31x0     rS ARRAY  ( 19 DOWNTO 0 )  OF   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
    TYPE   arr_2x0_31x0      IS ARRAY  ( 2  DOWNTO 0 )  OF   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
    TYPE   arr_39x0_31x0     IS ARRAY  ( 39 DOWNTO 0 )  OF   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
END dma_package;

package gc_comp_const is  
    CONSTANT GATE_NUM		 integer := 20;
    TYPE	locid	 			IS ARRAY (GATE_NUM - 1 DOWNTO 0) OF std_logic_vector(31 downto 0);
    TYPE    locid_xor			IS ARRAY (GATE_NUM - 1 DOWNTO 0) OF std_logic_vector(31 downto 0);
    TYPE    twodim  			IS ARRAY (GATE_NUM - 1 DOWNTO 0) OF std_logic_vector(79 downto 0);
    TYPE    andid	 			IS ARRAY (GATE_NUM - 1 DOWNTO 0) OF std_logic_vector(63 downto 0);
    TYPE    arr_and_gt_id		IS ARRAY (2*GATE_NUM -1 DOWNTO 0) OF std_logic_vector(31 downto 0);
    TYPE	arr_num_1x0			IS ARRAY (GATE_NUM - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(1 downto 0);
end package;    


LIBRARY   ieee;
USE       ieee.std_logic_1164.all;
USE       ieee.numeric_std.all;
LIBRARY   work;
USE       work.dma_package.all;
USE       work.gc_comp_const.all;


ENTITY   gc_comp   IS
    PORT(
            clrn                           	: IN    STD_LOGIC;                          -- 0: global reset 
            lclk                           	: IN    STD_LOGIC;                          -- Clock
            addr_1v                     	: IN    locid;										 --STD_LOGIC_VECTOR( 31 DOWNTO 0 );
            addr_2v                        	: IN    locid;
            addr_3v                        	: IN    locid;
            addr_1v_xor			            : IN	locid_xor;
            addr_2v_xor			            : IN    locid_xor;
            addr_3v_xor			            : IN    locid_xor;
            R				                : IN	arr_2x0_31x0; -- 96 ( use 80 )
            and_gt_id                      	: IN    arr_and_gt_id;
            xor_gt_id			            : IN    locid_xor;
            layer_num			            : IN	STD_LOGIC_VECTOR(31 downto 0);  --can be shared.
            gc_and_en                      	: IN	STD_LOGIC_VECTOR(GATE_NUM -1 downto 0);       -- (00000000,00000001, 00000011, 00000111,... to 11111111)
            gc_xor_en			            : IN    STD_LOGIC_VECTOR(GATE_NUM -1 downto 0);
            comp_done                      	: OUT   STD_LOGIC;
            Bank_B_ready                   	: IN    STD_LOGIC;                          -- 1: Memory controller is ready for use, 0: Initializing (due to reset)
            select_gc                      	: OUT   STD_LOGIC;                          -- Port select (enable) signal. Should be high until ready comes to transfer current datatransfers data on each port clock
            data_gc_in                     	: OUT   STD_LOGIC_VECTOR( 511 DOWNTO 0 );   -- Data to port gc of MultiPort mp
            data_gc_out                    	: IN    STD_LOGIC_VECTOR( 511 DOWNTO 0 );   -- Data from port gc of MultiPort mp
            gc_be                          	: OUT   STD_LOGIC_VECTOR( 63 DOWNTO 0 );    -- Random port byte enable bits
            addr_gc                        	: OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );    -- Port address. Apply the new address to this bus before selecting the port (select=VCC)
            write_gc                       	: OUT   STD_LOGIC;                          -- Port read\write signal. Assert high to write to the port
            ready_gc                       	: IN    STD_LOGIC                           -- Port ready flag (goes high when the data is ready)
        );
END   gc_comp;  

ARCHITECTURE  gc_comp_arch  OF  gc_comp  IS

    constant ZERO48BIT	    :	std_logic_vector(47 downto 0) := (others => '0');
    constant ZERO56BIT	    :	std_logic_vector(55 downto 0) := (others => '0');
    constant ZERO60BIT	    :	std_logic_vector(59 downto 0) := (others => '0');
    constant ONE60BIT	    :	std_logic_vector(59 downto 0) := (others => '1');
    constant ONE52BIT	    :	std_logic_vector(51 downto 0) := (others => '1');
    constant ONE54BIT	    :	std_logic_vector(53 downto 0) := (others => '1');
    constant ONE53BIT	    :	std_logic_vector(52 downto 0) := (others => '1');
    constant ZERO352BIT	:	std_logic_vector(351 downto 0):= (others => '0');
    constant ZERO480BIT	:	std_logic_vector(479 downto 0):= (others => '0');
    constant ZERO448BIT	:	std_logic_vector(447 downto 0):= (others => '0');
    constant ZERO416BIT	:	std_logic_vector(415 downto 0):= (others => '0');
    constant ZERO432BIT	:	std_logic_vector(431 downto 0):= (others => '0');
    constant ZERO424BIT	:	std_logic_vector(423 downto 0):= (others => '0');
    constant ALLONE		:	std_logic_vector(GATE_NUM - 1 downto 0) := (others => '1');

    signal addr_1v_reg	:	locid;
    signal addr_2v_reg	:	locid;
    signal addr_3v_reg	:	locid;

    signal ok_to_wr 	:	std_logic_vector(GATE_NUM -1 downto 0);
    signal isand		:	std_logic;
    signal isxor		:	std_logic;

    signal addr_1v_xor_reg	:	locid;
    signal addr_2v_xor_reg	:	locid;
    signal addr_3v_xor_reg	:	locid;
    signal gc_xor_en_reg	:	STD_LOGIC_VECTOR(GATE_NUM -1 downto 0);
    signal gc_xor_en_reg1	:	STD_LOGIC_VECTOR(GATE_NUM -1 downto 0);
 --signal flag_xor_done	:	std_logic;
 --signal comp_done_xor_reg:	std_logic;

    signal and_gt_id_reg	:	arr_and_gt_id;

    signal gc_rst_done	    :	std_logic;
    signal comp_done_reg   :	std_logic;
    signal addr_new		:	std_logic;
    signal reg_cnt		    :	arr_num_1x0;
    signal gc_done		    :	std_logic_vector(GATE_NUM - 1 downto 0);

    signal gc_done_and	    :	std_logic;

    signal gc_res			:	twodim; 			--std_logic_vector(79 downto 0);
    signal read_in		    :	std_logic_vector(GATE_NUM - 1 downto 0);

    signal data1_rd		:	twodim; 			-- std_logic_vector(79 downto 0);
    signal data2_rd		:	twodim; 			-- std_logic_vector(79 downto 0);

    signal r_input		    :	std_logic_vector(79 downto 0);
    signal and_id_input	:	andid; 				--std_logic_vector(63 downto 0);

    signal cyp_and0_2	    :	twodim; 				--std_logic_vector(79 downto 0);
    signal cyp_and0_3	    :	twodim;
    signal cyp_and0_4	    :	twodim;

    signal ready_comp	    :	std_logic_vector(GATE_NUM - 1 downto 0);
    signal gc_clrn		    :	std_logic_vector(GATE_NUM - 1 downto 0);
    signal new_sig_vld     :	std_logic_vector(GATE_NUM - 1 downto 0);
    signal new_sig_vld_xor : std_logic_vector(GATE_NUM -1 downto 0);

 -- signal step_s		:	std_logic_vector(7 downto 0);
    signal gc_and_en_reg   :	std_logic_vector(GATE_NUM -1 downto 0);
    signal gc_and_en_reg1  :	std_logic_vector(GATE_NUM -1 downto 0);

    signal reg_clr		    :	std_logic;

    signal layer_cnt		:	std_logic_vector(31 downto 0);
    signal layer_num_reg   :	std_logic_vector(31 downto 0);
    signal xor_gt_id_reg   :	locid_xor;

 --signal layer_cnt_xor  :  std_logic_vector(31 downto 0);


    type state_type is (s0, s1, s1_1, s2, s3, s3_1, s4, s5, s5_1, s6, s7, s7_1, s8, s9, s9_1, s10, s11, s11_1, s12, s12_01, s12_01_1, s12_02, s12_03, s12_03_1, s12_04, s12_11, s12_12, s12_13, s12_14, s12_21, s12_22, s12_23, s12_24, s12_31, s12_32, s12_33, s12_34, s12_41, s12_42, s12_43, s12_44, s12_51, s12_52, s12_53, s12_54, s12_61, s12_62, s12_63, s12_64, s13, s14, s15, s16, s17, s18, s19, s20, s21, s21_01, s21_02, s21_03, s21_11, s21_12, s21_13, s21_21, s21_22, s21_23, s21_31, s21_32, s21_33, s21_41, s21_42, s21_43, s21_51, s21_52, s21_53, s21_61, s21_62, s21_63, s12_11_1, s12_13_1, s12_21_1, s12_23_1, s12_31_1, s12_33_1, s12_41_1, s12_43_1, s12_51_1, s12_53_1, s12_61_1, s12_63_1, s12_71, s12_71_1, s12_72, s12_73, s12_73_1, s12_74, s12_81, s12_81_1, s12_82, s12_83, s12_83_1, s12_84, s12_91, s12_91_1, s12_92, s12_93, s12_93_1, s12_94, s12_a1, s12_a1_1, s12_a2, s12_a3, s12_a3_1, s12_a4, s12_b1, s12_b1_1, s12_b2, s12_b3, s12_b3_1, s12_b4, s12_c1, s12_c1_1, s12_c2, s12_c3, s12_c3_1, s12_c4, s12_d1, s12_d1_1, s12_d2, s12_d3, s12_d3_1, s12_d4, s12_e1, s12_e1_1, s12_e2, s12_e3, s12_e3_1, s12_e4, s12_f1, s12_f1_1, s12_f2, s12_f3, s12_f3_1, s12_f4, s12_g1, s12_g1_1, s12_g2, s12_g3, s12_g3_1, s12_g4, s21_71, s21_72, s21_73, s21_81, s21_82, s21_83, s21_91, s21_92, s21_93, s21_a1, s21_a2, s21_a3, s21_b1, s21_b2, s21_b3, s21_c1, s21_c2, s21_c3, s21_d1, s21_d2, s21_d3, s21_e1, s21_e2, s21_e3, s21_f1, s21_f2, s21_f3, s21_g1, s21_g2, s21_g3);
    signal state : state_type;

    type std_array is array (0 to 255) of std_logic_vector(79 downto 0);  -- last 8 bit as location
    signal cache_reg       :  std_array;

    signal address_sig 	:		STD_LOGIC_VECTOR (15 DOWNTO 0);
    signal data_sig		:		STD_LOGIC_VECTOR (107 DOWNTO 0);
    signal wren_sig		:		STD_LOGIC;
    signal q_sig			:		STD_LOGIC_VECTOR (107 DOWNTO 0);

    COMPONENT evaluator_and
        PORT
        (
            clk		        :	 IN STD_LOGIC;
            reset_n		    :	 IN STD_LOGIC;
            input_valid	    :	 IN STD_LOGIC;
            R		        :	 IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            Ga		        :	 IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            Gb		        :	 IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            g_id		    :	 IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            ready		    :	 out	std_logic;
            output_valid	:	 OUT STD_LOGIC;
            Gc		        :	 OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
            toSend01	    :	 OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
            toSend10	    :	 OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
            toSend11	    :	 OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
        );
    END COMPONENT;

    component ram_cache
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (107 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		    : OUT STD_LOGIC_VECTOR (107 DOWNTO 0)
        );
    end component;


BEGIN

    g_and : for i in (GATE_NUM - 1) downto 0 generate 
        evaluator_and0: evaluator_and port map(
                                                  clk					    =>	lclk,
                                                  reset_n				    =>	gc_clrn(i),
                                                  input_valid			    =>  read_in(i),
                                                  R						=>	r_input,
                                                  Ga						=>	data1_rd(i),
                                                  Gb						=>	data2_rd(i),
                                                  g_id					=>	and_id_input(i),
                                                  ready					=>  ready_comp(i),
                                                  output_valid		    =>	gc_done(i),
                                                  Gc						=>	gc_res(i),
                                                  toSend01				=>	cyp_and0_2(i),
                                                  toSend10				=>	cyp_and0_3(i),
                                                  toSend11				=>	cyp_and0_4(i)
                                              );
    end generate g_and;


    ram_inst : ram_cache PORT MAP (
                                      address	 => address_sig,
                                      clock	 => lclk,
                                      data	 => data_sig,
                                      wren	 => wren_sig,
                                      q	     => q_sig
                                  );


    process_reg_assign: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if(clrn = '0') then
                reset_lp: for i in 0 to GATE_NUM - 1 loop
                    addr_1v_reg(i)	    <=	(others => '0');
                    addr_2v_reg(i)	    <=	(others => '0');
                    addr_3v_reg(i)	    <=	(others => '0');
                    and_gt_id_reg(2*i)  <=  (others => '0');
                    and_gt_id_reg(2*i+1)<=  (others => '0');
                    addr_1v_xor_reg(i)	<=	(others => '0');
                    addr_2v_xor_reg(i)	<=	(others => '0');
                    addr_3v_xor_reg(i)	<=	(others => '0');
                end loop reset_lp;
            else
                gen_and: for i in 0 to GATE_NUM-1 loop
                    if(ok_to_wr(i) = '1') then
                        addr_1v_reg(i)      <=  addr_1v(i);
                        addr_2v_reg(i)	    <=	addr_2v(i);
                        addr_3v_reg(i)	    <=	addr_3v(i);
                        and_gt_id_reg(2*i)  <=  and_gt_id(2*i);
                        and_gt_id_reg(2*i+1)<=  (others => '0');

                        addr_1v_xor_reg(i)	<=	addr_1v_xor(i);
                        addr_2v_xor_reg(i)	<=	addr_2v_xor(i);
                        addr_3v_xor_reg(i)	<=	addr_3v_xor(i);
                        xor_gt_id_reg(i)	<=  xor_gt_id(i);
                    end if;
                end loop gen_and;
            end if;
        end if;
    end process process_reg_assign;
--and_gt_id_reg(0)(0) = '1'  then ok_to_wr(0) <= '0'
--and_gt_id_reg(2)(0) = '1' ...(28)  total is 15




    process_new_sig: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if reg_clr = '1' then
                new_sig_vld <= (others => '0');
            else
                new_for: for i in 0 to GATE_NUM-1 loop
                    if and_gt_id_reg(2*i) /= and_gt_id(2*i) then
                        new_sig_vld(i) <= '1';
                    end if;
                end loop new_for;
            end if;
        end if;
    end process process_new_sig;

    process_new_sig_xor: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if reg_clr = '1' then
                new_sig_vld_xor <= (others => '0');
            else
                new_for_xor: for i in 0 to GATE_NUM-1 loop
                    if xor_gt_id_reg(i) /= xor_gt_id(i) then
                        new_sig_vld_xor(i) <= '1';
                    end if;
                end loop new_for_xor;
            end if;
        end if;
    end process process_new_sig_xor;


    process_newreg: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if(clrn = '0') then
                addr_new 	<= '0';	 -- send layer_num, then gc_and_en, then and_gt_id one by one..
                isand		<=	'0';
                isxor		<=	'0';
            elsif (gc_and_en /= "00000000000000000000" and gc_and_en_reg1 = "00000000000000000000") or (gc_xor_en /= "00000000000000000000" and gc_xor_en_reg1 = "00000000000000000000") then
                addr_new 	<= '1';
                layer_num_reg 	<= layer_num;
                if(gc_and_en /= "00000000000000000000" and gc_and_en_reg1 = "00000000000000000000") then
                    gc_and_en_reg	<=	gc_and_en;
                    gc_xor_en_reg	<=	(others => '0');
                    isand			<=  '1';
                    isxor			<=	'0';
            --addr_lp: for i in 0 to GATE_NUM - 1 loop 
            --	addr_1v_reg(i)	<= addr_1v(i);
            --	addr_2v_reg(i) <= addr_2v(i);
            --	addr_3v_reg(i) <= addr_3v(i);
            --end loop;
            --and_id_lp: for i in 0 to 2*GATE_NUM-1 loop
            --	and_gt_id_reg(i)	<=	and_gt_id(i);
            --end loop;

            --addr_1v_xor_reg<=	(others => '0');
            --addr_2v_xor_reg<=	(others => '0');
            --addr_3v_xor_reg<=	(others => '0');
                elsif(gc_xor_en /= "00000000000000000000" and gc_xor_en_reg1 = "00000000000000000000") then
                    gc_xor_en_reg	<=	gc_xor_en;
                    gc_and_en_reg   <=  (others => '0');
                    isand           <=  '0';
                    isxor			<=	'1';
            --reset_lp2: for i in 0 to GATE_NUM - 1 loop
            --	addr_1v_reg(i)	<=	(others => '0');
            --	addr_2v_reg(i)	<=	(others => '0');
            --	addr_3v_reg(i)	<=	(others => '0');
            --end loop;
            --addr_1v_xor_reg	<=	addr_1v_xor;
            --addr_2v_xor_reg	<=	addr_2v_xor;
            --addr_3v_xor_reg	<=	addr_3v_xor;
                end if;
            elsif(state = s1) then
                addr_new 	<= '0';
            elsif(reg_clr = '1') then
                gc_xor_en_reg	<= (others => '0');
                gc_and_en_reg	<= (others => '0');
                isand			<= '0';
                isxor			<= '0';
            end if;
        end if;
    end process;	

    process_and_en: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if(clrn = '0') then
                gc_and_en_reg1 <=	(others => '0');
                gc_xor_en_reg1 <=	(others => '0');
            else
                gc_and_en_reg1 <=	gc_and_en;
                gc_xor_en_reg1 <=	gc_xor_en;
            end if;
        end if;
    end process;


-- when select_gc	<=	'0'; ready_gc <= '0';

    state_proc:	process (lclk, clrn)
    begin
        if clrn = '0' then
            state <= s0;
            select_gc	<= '0';
            addr_gc		<= (others => '0');
            write_gc		<=	'0';
            data_gc_in	<=	(others => '0');
            layer_cnt		<=	(others => '0');
        --layer_cnt_xor	<=	(others => '0');
            clrn_clr: for i in 0 to GATE_NUM-1 loop
                gc_clrn(i)	<=	'0';
            end loop;
            read_in_cl: for i in 0 to GATE_NUM-1 loop
                read_in(i)		<=	'0';
            end loop;
      --flag_xor_done <=	'0';
            reg_clr <= '0';
            wren_sig <=	'0';
            ok_to_wr <= (others => '1');
        elsif (rising_edge(lclk)) then
            case state is
                when s0=>
                    ok_to_wr <= (others => '1');
                    if addr_new = '1' then

                        select_gc	<= '0';
                        addr_gc		<= (others => '0');
                        write_gc	<=	'0';
                        data_gc_in	<=	(others => '0');

                        clrn_clr2: for i in 0 to GATE_NUM-1 loop
                            gc_clrn(i)	<=	'0';
                        end loop;

                        layer_cnt		<=	(others => '0');
                    --layer_cnt_xor	<=	(others => '0');
                        read_in_cl2: for i in 0 to GATE_NUM-1 loop
                            read_in(i)		<=	'0';
                        end loop;
                        state <= s1;
                    else
                        state <= s0;
                    end if;
                    reg_clr <= '0';
                    wren_sig <=	'0';
                when s1=>
                    if ((gc_and_en_reg(0) = '1' and new_sig_vld(0) = '1') or (gc_xor_en_reg(0) = '1' and new_sig_vld_xor(0) = '1')) then
                        gc_clrn(0)				<=	'1';
                    --flag_xor_done 			<=	'0';
                        layer_cnt			    <=	(others => '0');
                        if isand = '1' then
                            if(addr_1v_reg(0)(0) = '0') then          -----  0 represent ddr; 1 represent register
                                state 			<= s2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(0);
                            else
                            --data1_rd(0)	<=	cache_reg(to_integer(unsigned(addr_1v_reg(0)(13 downto 1))));  -- so if using register, location should be 2*previous_address+1; reg is limited to #256. for more reg use ddr location. for ddr, 2*previous_address;
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(0)(16 downto 1);
                                state			<=	s1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(0)(0) = '0') then
                                state			<= s2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(0);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(0)(16 downto 1);
                                state			<= s1_1;
                            end if;
                        end if;
                    end if;
                when s1_1=>
                    data1_rd(0) <= q_sig(79 downto 0);
                    state <=	s3;
                when s2=>
                    if ready_gc = '1' then
                        select_gc	<=	'0';
                        data1_rd(0)			<=	data_gc_out(79 downto 0);
                        state <= s3;
                    end if;	

                when s3=>
                    if isand = '1' then
                        if(addr_2v_reg(0)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(0);
                            state			<=	s4;
                        else
                        --data2_rd(0)	<=	cache_reg(to_integer(unsigned(addr_2v_reg(0)(16 downto 1))));
                            wren_sig <=	'0';
                            address_sig	<=	addr_2v_reg(0)(16 downto 1);
                            state <=	s3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(0)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(0);
                            state			<=	s4;
                        else
                        --data2_rd(0)	<=	cache_reg(to_integer(unsigned(addr_2v_reg(0)(16 downto 1))));
                            wren_sig <=	'0';
                            address_sig	<=	addr_2v_xor_reg(0)(16 downto 1);
                            state <=	s3_1;
                        end if;
                    end if;

                when s3_1=>
                    data2_rd(0)	<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(0) = '1') then
                        read_in(0)	<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000000001" or gc_xor_en_reg = "00000000000000000001") then
                        state <= s13;
                    else
                        state <= s5;
                    end if;

                when s4=>
                    if (ready_gc = '1') then
                        data2_rd(0)<=	data_gc_out(79 downto 0);
                        select_gc	<=	'0';
                        if(gc_and_en_reg(0) = '1') then
                            read_in(0)	<=	'1';
                        end if;
                        if (gc_and_en_reg = "00000000000000000001" or gc_xor_en_reg = "00000000000000000001") then
                            state <= s13;
                        else
                            state <= s5;
                        end if;
                    end if;

            --				
                when s5=>
                    if (gc_and_en_reg(1) = '1' and new_sig_vld(1) = '1') or (gc_xor_en_reg(1) = '1' and new_sig_vld_xor(1) = '1') then 
                        gc_clrn(1)				<=	'1';
                        read_in(0)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(1)(0) = '0') then
                                state 			<= s6;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(1);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(1)(16 downto 1);
                                state			<=	s5_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(1)(0) = '0') then
                                state			<= s6;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(1);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(1)(16 downto 1);
                                state			<= s5_1;
                            end if;
                        end if;		
                    end if;

                when s5_1 =>
                    data1_rd(1) 		<= q_sig(79 downto 0);
                    state 				<=	s7;

                when s6=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s7;
                        data1_rd(1)		<=	data_gc_out(79 downto 0);
                    end if;
                when s7=>

                    if isand = '1' then
                        if(addr_2v_reg(1)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(1);
                            state			<=	s8;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(1)(16 downto 1);
                            state 			<=	s7_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(1)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(1);
                            state			<=	s8;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(1)(16 downto 1);
                            state 			<=	s7_1;
                        end if;
                    end if;

                when s7_1=>
                    data2_rd(1)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(1) = '1') then
                        read_in(1)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000000011" or gc_xor_en_reg = "00000000000000000011") then
                        state 				<= s13;
                    else
                        state 				<= s9;
                    end if;

                when s8=>
                    if(ready_gc = '1') then
                        data2_rd(1)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(1)			<=	'1';
                        if(gc_and_en_reg = "00000000000000000011" or gc_xor_en_reg = "00000000000000000011") then
                            state			<=	s13;
                        else 
                            state			<=	s9;
                        end if;
                    end if;
            --
            --		


                when s9=>
                    if (gc_and_en_reg(2) = '1' and new_sig_vld(2) = '1') or (gc_xor_en_reg(2) = '1' and new_sig_vld_xor(2) = '1') then 
                        gc_clrn(2)				<=	'1';
                        read_in(1)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(2)(0) = '0') then
                                state 			<= s10;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(2);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(2)(16 downto 1);
                                state			<=	s9_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(2)(0) = '0') then
                                state			<= s10;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(2);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(2)(16 downto 1);
                                state			<= s9_1;
                            end if;
                        end if;		
                    end if;

                when s9_1 =>
                    data1_rd(2) 		<= q_sig(79 downto 0);
                    state 				<=	s11;

                when s10=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s11;
                        data1_rd(2)		<=	data_gc_out(79 downto 0);
                    end if;
                when s11=>
                    if isand = '1' then
                        if(addr_2v_reg(2)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(2);
                            state			<=	s12;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(2)(16 downto 1);
                            state 			<=	s11_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(2)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(2);
                            state			<=	s12;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(2)(16 downto 1);
                            state 			<=	s11_1;
                        end if;
                    end if;

                when s11_1=>
                    data2_rd(2)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(2) = '1') then
                        read_in(2)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000000111" or gc_xor_en_reg = "00000000000000000111") then
                        state 				<= s13;
                    else
                        state 				<= s12_01;
                    end if;

                when s12=>
                    if(ready_gc = '1') then
                        data2_rd(2)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(2)			<=	'1';
                        if(gc_and_en_reg = "00000000000000000111" or gc_xor_en_reg = "00000000000000000111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_01;
                        end if;
                    end if;
            --				

            --	

                when s12_01=>
                    if (gc_and_en_reg(3) = '1' and new_sig_vld(3) = '1') or (gc_xor_en_reg(3) = '1' and new_sig_vld_xor(3) = '1') then 
                        gc_clrn(3)				<=	'1';
                        read_in(2)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(3)(0) = '0') then
                                state 			<= s12_02;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(3);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(3)(16 downto 1);
                                state			<=	s12_01_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(3)(0) = '0') then
                                state			<= s12_02;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(3);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(3)(16 downto 1);
                                state			<= s12_01_1;
                            end if;
                        end if;		
                    end if;

                when s12_01_1 =>
                    data1_rd(3) 		<= q_sig(79 downto 0);
                    state 				<=	s12_03;

                when s12_02=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_03;
                        data1_rd(3)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_03=>
                    if isand = '1' then
                        if(addr_2v_reg(3)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(3);
                            state			<=	s12_04;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(3)(16 downto 1);
                            state 			<=	s12_03_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(3)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(3);
                            state			<=	s12_04;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(3)(16 downto 1);
                            state 			<=	s12_03_1;
                        end if;
                    end if;

                when s12_03_1=>
                    data2_rd(3)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(3) = '1') then
                        read_in(3)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000001111" or gc_xor_en_reg = "00000000000000001111") then
                        state 				<= s13;
                    else
                        state 				<= s12_11;
                    end if;

                when s12_04=>
                    if(ready_gc = '1') then
                        data2_rd(3)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(3)			<=	'1';
                        if(gc_and_en_reg = "00000000000000001111" or gc_xor_en_reg = "00000000000000001111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_11;
                        end if;
                    end if;
            --				

            --				



                when s12_11=>
                    if (gc_and_en_reg(4) = '1' and new_sig_vld(4) = '1') or (gc_xor_en_reg(4) = '1' and new_sig_vld_xor(4) = '1') then 
                        gc_clrn(4)				<=	'1';
                        read_in(3)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(4)(0) = '0') then
                                state 			<= s12_12;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(4);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(4)(16 downto 1);
                                state			<=	s12_11_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(4)(0) = '0') then
                                state			<= s12_12;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(4);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(4)(16 downto 1);
                                state			<= s12_11_1;
                            end if;
                        end if;		
                    end if;

                when s12_11_1 =>
                    data1_rd(4) 		<= q_sig(79 downto 0);
                    state 				<=	s12_13;

                when s12_12=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_13;
                        data1_rd(4)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_13=>
                    if isand = '1' then
                        if(addr_2v_reg(4)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(4);
                            state			<=	s12_14;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(4)(16 downto 1);
                            state 			<=	s12_13_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(4)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(4);
                            state			<=	s12_14;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(4)(16 downto 1);
                            state 			<=	s12_13_1;
                        end if;
                    end if;

                when s12_13_1=>
                    data2_rd(4)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(4) = '1') then
                        read_in(4)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000011111" or gc_xor_en_reg = "00000000000000011111") then
                        state 				<= s13;
                    else
                        state 				<= s12_21;
                    end if;

                when s12_14=>
                    if(ready_gc = '1') then
                        data2_rd(4)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(4)			<=	'1';
                        if(gc_and_en_reg = "00000000000000011111" or gc_xor_en_reg = "00000000000000011111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_21;
                        end if;
                    end if;

            --			

                when s12_21=>
                    if (gc_and_en_reg(5) = '1' and new_sig_vld(5) = '1') or (gc_xor_en_reg(5) = '1' and new_sig_vld_xor(5) = '1') then 
                        gc_clrn(5)				<=	'1';
                        read_in(4)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(5)(0) = '0') then
                                state 			<= s12_22;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(5);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(5)(16 downto 1);
                                state			<=	s12_21_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(5)(0) = '0') then
                                state			<= s12_22;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(5);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(5)(16 downto 1);
                                state			<= s12_21_1;
                            end if;
                        end if;		
                    end if;

                when s12_21_1 =>
                    data1_rd(5) 		<= q_sig(79 downto 0);
                    state 				<=	s12_23;

                when s12_22=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_23;
                        data1_rd(5)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_23=>
                    if isand = '1' then
                        if(addr_2v_reg(5)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(5);
                            state			<=	s12_24;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(5)(16 downto 1);
                            state 			<=	s12_23_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(5)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(5);
                            state			<=	s12_24;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(5)(16 downto 1);
                            state 			<=	s12_23_1;
                        end if;
                    end if;

                when s12_23_1=>
                    data2_rd(5)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(5) = '1') then
                        read_in(5)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000000111111" or gc_xor_en_reg = "00000000000000111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_31;
                    end if;

                when s12_24=>
                    if(ready_gc = '1') then
                        data2_rd(5)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(5)			<=	'1';
                        if(gc_and_en_reg = "00000000000000111111" or gc_xor_en_reg = "00000000000000111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_31;
                        end if;
                    end if;		
            --

                when s12_31=>
                    if (gc_and_en_reg(6) = '1' and new_sig_vld(6) = '1') or (gc_xor_en_reg(6) = '1' and new_sig_vld_xor(6) = '1') then 
                        gc_clrn(6)				<=	'1';
                        read_in(5)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(6)(0) = '0') then
                                state 			<= s12_32;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(6);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(6)(16 downto 1);
                                state			<=	s12_31_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(6)(0) = '0') then
                                state			<= s12_32;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(6);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(6)(16 downto 1);
                                state			<= s12_31_1;
                            end if;
                        end if;		
                    end if;

                when s12_31_1 =>
                    data1_rd(6) 		<= q_sig(79 downto 0);
                    state 				<=	s12_33;

                when s12_32=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_33;
                        data1_rd(6)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_33=>
                    if isand = '1' then
                        if(addr_2v_reg(6)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(6);
                            state			<=	s12_34;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(6)(16 downto 1);
                            state 			<=	s12_33_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(6)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(6);
                            state			<=	s12_34;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(6)(16 downto 1);
                            state 			<=	s12_33_1;
                        end if;
                    end if;

                when s12_33_1=>
                    data2_rd(6)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(6) = '1') then
                        read_in(6)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000001111111" or gc_xor_en_reg = "00000000000001111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_41;
                    end if;

                when s12_34=>
                    if(ready_gc = '1') then
                        data2_rd(6)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(6)			<=	'1';
                        if(gc_and_en_reg = "00000000000001111111" or gc_xor_en_reg = "00000000000001111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_41;
                        end if;
                    end if;	


            --
                when s12_41=>
                    if (gc_and_en_reg(7) = '1' and new_sig_vld(7) = '1') or (gc_xor_en_reg(7) = '1' and new_sig_vld_xor(7) = '1') then 
                        gc_clrn(7)				<=	'1';
                        read_in(6)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(7)(0) = '0') then
                                state 			<= s12_42;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(7);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(7)(16 downto 1);
                                state			<=	s12_41_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(7)(0) = '0') then
                                state			<= s12_42;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(7);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(7)(16 downto 1);
                                state			<= s12_41_1;
                            end if;
                        end if;		
                    end if;

                when s12_41_1 =>
                    data1_rd(7) 		<= q_sig(79 downto 0);
                    state 				<=	s12_43;

                when s12_42=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_43;
                        data1_rd(7)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_43=>
                    if isand = '1' then
                        if(addr_2v_reg(7)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(7);
                            state			<=	s12_44;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(7)(16 downto 1);
                            state 			<=	s12_43_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(7)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(7);
                            state			<=	s12_44;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(7)(16 downto 1);
                            state 			<=	s12_43_1;
                        end if;
                    end if;

                when s12_43_1=>
                    data2_rd(7)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(7) = '1') then
                        read_in(7)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000011111111" or gc_xor_en_reg = "00000000000011111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_51;
                    end if;

                when s12_44=>
                    if(ready_gc = '1') then
                        data2_rd(7)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(7)			<=	'1';
                        if(gc_and_en_reg = "00000000000011111111" or gc_xor_en_reg = "00000000000011111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_51;
                        end if;
                    end if;	

            --
                when s12_51=>
                    if (gc_and_en_reg(8) = '1' and new_sig_vld(8) = '1') or (gc_xor_en_reg(8) = '1' and new_sig_vld_xor(8) = '1') then 
                        gc_clrn(8)				<=	'1';
                        read_in(7)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(8)(0) = '0') then
                                state 			<= s12_52;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(8);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(8)(16 downto 1);
                                state			<=	s12_51_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(8)(0) = '0') then
                                state			<= s12_52;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(8);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(8)(16 downto 1);
                                state			<= s12_51_1;
                            end if;
                        end if;		
                    end if;

                when s12_51_1 =>
                    data1_rd(8) 		<= q_sig(79 downto 0);
                    state 				<=	s12_53;

                when s12_52=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_53;
                        data1_rd(8)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_53=>
                    if isand = '1' then
                        if(addr_2v_reg(8)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(8);
                            state			<=	s12_54;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(8)(16 downto 1);
                            state 			<=	s12_53_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(8)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(8);
                            state			<=	s12_54;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(8)(16 downto 1);
                            state 			<=	s12_53_1;
                        end if;
                    end if;

                when s12_53_1=>
                    data2_rd(8)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(8) = '1') then
                        read_in(8)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000000111111111" or gc_xor_en_reg = "00000000000111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_61;
                    end if;

                when s12_54=>
                    if(ready_gc = '1') then
                        data2_rd(8)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(8)			<=	'1';
                        if(gc_and_en_reg = "00000000000111111111" or gc_xor_en_reg = "00000000000111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_61;
                        end if;
                    end if;


            --
                when s12_61=>
                    if (gc_and_en_reg(9) = '1' and new_sig_vld(9) = '1') or (gc_xor_en_reg(9) = '1' and new_sig_vld_xor(9) = '1') then 
                        gc_clrn(9)				<=	'1';
                        read_in(8)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(9)(0) = '0') then
                                state 			<= s12_62;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(9);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(9)(16 downto 1);
                                state			<=	s12_61_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(9)(0) = '0') then
                                state			<= s12_62;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(9);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(9)(16 downto 1);
                                state			<= s12_61_1;
                            end if;
                        end if;		
                    end if;

                when s12_61_1 =>
                    data1_rd(9) 		<= q_sig(79 downto 0);
                    state 				<=	s12_63;

                when s12_62=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_63;
                        data1_rd(9)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_63=>
                    if isand = '1' then
                        if(addr_2v_reg(9)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(9);
                            state			<=	s12_64;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(9)(16 downto 1);
                            state 			<=	s12_63_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(9)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(9);
                            state			<=	s12_64;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(9)(16 downto 1);
                            state 			<=	s12_63_1;
                        end if;
                    end if;

                when s12_63_1=>
                    data2_rd(9)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(9) = '1') then
                        read_in(9)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000001111111111" or gc_xor_en_reg = "00000000001111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_71;
                    end if;

                when s12_64=>
                    if(ready_gc = '1') then
                        data2_rd(9)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(9)			<=	'1';
                        if(gc_and_en_reg = "00000000001111111111" or gc_xor_en_reg = "00000000001111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_71;
                        end if;
                    end if;

            --	
                when s12_71=>
                    if (gc_and_en_reg(10) = '1' and new_sig_vld(10) = '1') or (gc_xor_en_reg(10) = '1' and new_sig_vld_xor(10) = '1') then 
                        gc_clrn(10)				<=	'1';
                        read_in(9)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(10)(0) = '0') then
                                state 			<= s12_72;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(10);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(10)(16 downto 1);
                                state			<=	s12_71_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(10)(0) = '0') then
                                state			<= s12_72;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(10);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(10)(16 downto 1);
                                state			<= s12_71_1;
                            end if;
                        end if;		
                    end if;

                when s12_71_1 =>
                    data1_rd(10) 		<= q_sig(79 downto 0);
                    state 				<=	s12_73;

                when s12_72=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_73;
                        data1_rd(10)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_73=>
                    if isand = '1' then
                        if(addr_2v_reg(10)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(10);
                            state			<=	s12_74;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(10)(16 downto 1);
                            state 			<=	s12_73_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(10)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(10);
                            state			<=	s12_74;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(10)(16 downto 1);
                            state 			<=	s12_73_1;
                        end if;
                    end if;

                when s12_73_1=>
                    data2_rd(10)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(10) = '1') then
                        read_in(10)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000011111111111" or gc_xor_en_reg = "00000000011111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_81;
                    end if;

                when s12_74=>
                    if(ready_gc = '1') then
                        data2_rd(10)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(10)			<=	'1';
                        if(gc_and_en_reg = "00000000011111111111" or gc_xor_en_reg = "00000000011111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_81;
                        end if;
                    end if;
            --
                when s12_81=>
                    if (gc_and_en_reg(11) = '1' and new_sig_vld(11) = '1') or (gc_xor_en_reg(11) = '1' and new_sig_vld_xor(11) = '1') then 
                        gc_clrn(11)				<=	'1';
                        read_in(10)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(11)(0) = '0') then
                                state 			<= s12_82;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(11);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(11)(16 downto 1);
                                state			<=	s12_81_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(11)(0) = '0') then
                                state			<= s12_82;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(11);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(11)(16 downto 1);
                                state			<= s12_81_1;
                            end if;
                        end if;		
                    end if;

                when s12_81_1 =>
                    data1_rd(11) 		<= q_sig(79 downto 0);
                    state 				<=	s12_83;

                when s12_82=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_83;
                        data1_rd(11)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_83=>
                    if isand = '1' then
                        if(addr_2v_reg(11)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(11);
                            state			<=	s12_84;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(11)(16 downto 1);
                            state 			<=	s12_83_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(11)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(11);
                            state			<=	s12_84;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(11)(16 downto 1);
                            state 			<=	s12_83_1;
                        end if;
                    end if;

                when s12_83_1=>
                    data2_rd(11)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(11) = '1') then
                        read_in(11)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000000111111111111" or gc_xor_en_reg = "00000000111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_91;
                    end if;

                when s12_84=>
                    if(ready_gc = '1') then
                        data2_rd(11)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(11)			<=	'1';
                        if(gc_and_en_reg = "00000000111111111111" or gc_xor_en_reg = "00000000111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_91;
                        end if;
                    end if;

            --                
                when s12_91=>
                    if (gc_and_en_reg(12) = '1' and new_sig_vld(12) = '1') or (gc_xor_en_reg(12) = '1' and new_sig_vld_xor(12) = '1') then 
                        gc_clrn(12)				<=	'1';
                        read_in(11)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(12)(0) = '0') then
                                state 			<= s12_92;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(12);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(12)(16 downto 1);
                                state			<=	s12_91_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(12)(0) = '0') then
                                state			<= s12_92;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(12);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(12)(16 downto 1);
                                state			<= s12_91_1;
                            end if;
                        end if;		
                    end if;

                when s12_91_1 =>
                    data1_rd(12) 		<= q_sig(79 downto 0);
                    state 				<=	s12_93;

                when s12_92=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_93;
                        data1_rd(12)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_93=>
                    if isand = '1' then
                        if(addr_2v_reg(12)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(12);
                            state			<=	s12_94;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(12)(16 downto 1);
                            state 			<=	s12_93_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(12)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(12);
                            state			<=	s12_94;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(12)(16 downto 1);
                            state 			<=	s12_93_1;
                        end if;
                    end if;

                when s12_93_1=>
                    data2_rd(12)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(12) = '1') then
                        read_in(12)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000001111111111111" or gc_xor_en_reg = "00000001111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_a1;
                    end if;

                when s12_94=>
                    if(ready_gc = '1') then
                        data2_rd(12)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(12)			<=	'1';
                        if(gc_and_en_reg = "00000001111111111111" or gc_xor_en_reg = "00000001111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_a1;
                        end if;
                    end if;

            -- 
                when s12_a1=>
                    if (gc_and_en_reg(13) = '1' and new_sig_vld(13) = '1') or (gc_xor_en_reg(13) = '1' and new_sig_vld_xor(13) = '1') then 
                        gc_clrn(13)				<=	'1';
                        read_in(12)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(13)(0) = '0') then
                                state 			<= s12_a2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(13);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(13)(16 downto 1);
                                state			<=	s12_a1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(13)(0) = '0') then
                                state			<= s12_a2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(13);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(13)(16 downto 1);
                                state			<= s12_a1_1;
                            end if;
                        end if;		
                    end if;

                when s12_a1_1 =>
                    data1_rd(13) 		<= q_sig(79 downto 0);
                    state 				<=	s12_a3;

                when s12_a2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_a3;
                        data1_rd(13)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_a3=>
                    if isand = '1' then
                        if(addr_2v_reg(13)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(13);
                            state			<=	s12_a4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(13)(16 downto 1);
                            state 			<=	s12_a3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(13)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(13);
                            state			<=	s12_a4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(13)(16 downto 1);
                            state 			<=	s12_a3_1;
                        end if;
                    end if;

                when s12_a3_1=>
                    data2_rd(13)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(13) = '1') then
                        read_in(13)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000011111111111111" or gc_xor_en_reg = "00000011111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_a4=>
                    if(ready_gc = '1') then
                        data2_rd(13)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(13)			<=	'1';
                        if(gc_and_en_reg = "00000011111111111111" or gc_xor_en_reg = "00000011111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --               

            -- 
                when s12_b1=>
                    if (gc_and_en_reg(14) = '1' and new_sig_vld(14) = '1') or (gc_xor_en_reg(14) = '1' and new_sig_vld_xor(14) = '1') then 
                        gc_clrn(14)				<=	'1';
                        read_in(13)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(14)(0) = '0') then
                                state 			<= s12_b2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(14);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(14)(16 downto 1);
                                state			<=	s12_b1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(14)(0) = '0') then
                                state			<= s12_b2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(14);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(14)(16 downto 1);
                                state			<= s12_b1_1;
                            end if;
                        end if;		
                    end if;

                when s12_b1_1 =>
                    data1_rd(14) 		<= q_sig(79 downto 0);
                    state 				<=	s12_b3;

                when s12_b2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_b3;
                        data1_rd(14)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_b3=>
                    if isand = '1' then
                        if(addr_2v_reg(14)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(14);
                            state			<=	s12_b4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(14)(16 downto 1);
                            state 			<=	s12_b3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(14)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(14);
                            state			<=	s12_b4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(14)(16 downto 1);
                            state 			<=	s12_b3_1;
                        end if;
                    end if;

                when s12_b3_1=>
                    data2_rd(14)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(14) = '1') then
                        read_in(14)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00000111111111111111" or gc_xor_en_reg = "00000111111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_b4=>
                    if(ready_gc = '1') then
                        data2_rd(14)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(14)			<=	'1';
                        if(gc_and_en_reg = "00000111111111111111" or gc_xor_en_reg = "00000111111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --        

            -- 
                when s12_c1=>
                    if (gc_and_en_reg(15) = '1' and new_sig_vld(15) = '1') or (gc_xor_en_reg(15) = '1' and new_sig_vld_xor(15) = '1') then 
                        gc_clrn(15)				<=	'1';
                        read_in(14)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(15)(0) = '0') then
                                state 			<= s12_c2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(15);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(15)(16 downto 1);
                                state			<=	s12_c1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(15)(0) = '0') then
                                state			<= s12_c2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(15);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(15)(16 downto 1);
                                state			<= s12_c1_1;
                            end if;
                        end if;		
                    end if;

                when s12_c1_1 =>
                    data1_rd(15) 		<= q_sig(79 downto 0);
                    state 				<=	s12_c3;

                when s12_c2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_c3;
                        data1_rd(15)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_c3=>
                    if isand = '1' then
                        if(addr_2v_reg(15)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(15);
                            state			<=	s12_c4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(15)(16 downto 1);
                            state 			<=	s12_c3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(15)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(15);
                            state			<=	s12_c4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(15)(16 downto 1);
                            state 			<=	s12_c3_1;
                        end if;
                    end if;

                when s12_c3_1=>
                    data2_rd(15)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(15) = '1') then
                        read_in(15)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00001111111111111111" or gc_xor_en_reg = "00001111111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_c4=>
                    if(ready_gc = '1') then
                        data2_rd(15)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(15)			<=	'1';
                        if(gc_and_en_reg = "00001111111111111111" or gc_xor_en_reg = "00001111111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --        

            -- 
                when s12_d1=>
                    if (gc_and_en_reg(16) = '1' and new_sig_vld(16) = '1') or (gc_xor_en_reg(16) = '1' and new_sig_vld_xor(16) = '1') then 
                        gc_clrn(16)				<=	'1';
                        read_in(15)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(16)(0) = '0') then
                                state 			<= s12_d2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(16);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(16)(16 downto 1);
                                state			<=	s12_d1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(16)(0) = '0') then
                                state			<= s12_d2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(16);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(16)(16 downto 1);
                                state			<= s12_d1_1;
                            end if;
                        end if;		
                    end if;

                when s12_d1_1 =>
                    data1_rd(16) 		<= q_sig(79 downto 0);
                    state 				<=	s12_d3;

                when s12_d2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_d3;
                        data1_rd(16)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_d3=>
                    if isand = '1' then
                        if(addr_2v_reg(16)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(16);
                            state			<=	s12_d4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(16)(16 downto 1);
                            state 			<=	s12_d3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(16)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(16);
                            state			<=	s12_d4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(16)(16 downto 1);
                            state 			<=	s12_d3_1;
                        end if;
                    end if;

                when s12_d3_1=>
                    data2_rd(16)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(16) = '1') then
                        read_in(16)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00011111111111111111" or gc_xor_en_reg = "00011111111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_d4=>
                    if(ready_gc = '1') then
                        data2_rd(16)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(16)			<=	'1';
                        if(gc_and_en_reg = "00011111111111111111" or gc_xor_en_reg = "00011111111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --        

            -- 
                when s12_e1=>
                    if (gc_and_en_reg(17) = '1' and new_sig_vld(17) = '1') or (gc_xor_en_reg(17) = '1' and new_sig_vld_xor(17) = '1') then 
                        gc_clrn(17)				<=	'1';
                        read_in(16)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(17)(0) = '0') then
                                state 			<= s12_e2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(17);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(17)(16 downto 1);
                                state			<=	s12_e1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(17)(0) = '0') then
                                state			<= s12_e2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(17);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(17)(16 downto 1);
                                state			<= s12_e1_1;
                            end if;
                        end if;		
                    end if;

                when s12_e1_1 =>
                    data1_rd(17) 		<= q_sig(79 downto 0);
                    state 				<=	s12_e3;

                when s12_e2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_e3;
                        data1_rd(17)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_e3=>
                    if isand = '1' then
                        if(addr_2v_reg(17)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(17);
                            state			<=	s12_e4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(17)(16 downto 1);
                            state 			<=	s12_e3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(17)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(17);
                            state			<=	s12_e4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(17)(16 downto 1);
                            state 			<=	s12_e3_1;
                        end if;
                    end if;

                when s12_e3_1=>
                    data2_rd(17)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(17) = '1') then
                        read_in(17)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "00111111111111111111" or gc_xor_en_reg = "00111111111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_e4=>
                    if(ready_gc = '1') then
                        data2_rd(17)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(17)			<=	'1';
                        if(gc_and_en_reg = "00111111111111111111" or gc_xor_en_reg = "00111111111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --        

            -- 
                when s12_f1=>
                    if (gc_and_en_reg(18) = '1' and new_sig_vld(18) = '1') or (gc_xor_en_reg(18) = '1' and new_sig_vld_xor(18) = '1') then 
                        gc_clrn(18)				<=	'1';
                        read_in(17)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(18)(0) = '0') then
                                state 			<= s12_f2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(18);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(18)(16 downto 1);
                                state			<=	s12_f1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(18)(0) = '0') then
                                state			<= s12_f2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(18);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(18)(16 downto 1);
                                state			<= s12_f1_1;
                            end if;
                        end if;		
                    end if;

                when s12_f1_1 =>
                    data1_rd(18) 		<= q_sig(79 downto 0);
                    state 				<=	s12_f3;

                when s12_f2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_f3;
                        data1_rd(18)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_f3=>
                    if isand = '1' then
                        if(addr_2v_reg(18)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(18);
                            state			<=	s12_f4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(18)(16 downto 1);
                            state 			<=	s12_f3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(18)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(18);
                            state			<=	s12_f4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(18)(16 downto 1);
                            state 			<=	s12_f3_1;
                        end if;
                    end if;

                when s12_f3_1=>
                    data2_rd(18)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(18) = '1') then
                        read_in(18)			<=	'1';
                    end if;
                    if (gc_and_en_reg = "01111111111111111111" or gc_xor_en_reg = "01111111111111111111") then
                        state 				<= s13;
                    else
                        state 				<= s12_b1;
                    end if;

                when s12_f4=>
                    if(ready_gc = '1') then
                        data2_rd(18)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(18)			<=	'1';
                        if(gc_and_en_reg = "01111111111111111111" or gc_xor_en_reg = "01111111111111111111") then
                            state			<=	s13;
                        else 
                            state			<=	s12_b1;
                        end if;
                    end if;
            --        
                when s12_g1=>
                    if (gc_and_en_reg(19) = '1' and new_sig_vld(19) = '1') or (gc_xor_en_reg(19) = '1' and new_sig_vld_xor(19) = '1') then 
                        gc_clrn(19)				<=	'1';
                        read_in(18)				<=	'0';
                        if isand = '1' then
                            if(addr_1v_reg(19)(0) = '0') then
                                state 			<= s12_g2;
                                select_gc		<= '1';
                                write_gc		<= '0';
                                addr_gc			<= addr_1v_reg(19);
                            else
                                wren_sig		<=	'0';
                                address_sig		<=  addr_1v_reg(19)(16 downto 1);
                                state			<=	s12_g1_1;
                            end if;
                        elsif isxor = '1' then
                        --layer_cnt_xor 		<= (others => '0');
                            if(addr_1v_xor_reg(19)(0) = '0') then
                                state			<= s12_g2;
                                select_gc 		<= '1';
                                write_gc 		<= '0';
                                addr_gc			<= addr_1v_xor_reg(19);
                            else
                                wren_sig		<=	'0';
                                address_sig		<= addr_1v_xor_reg(19)(16 downto 1);
                                state			<= s12_g1_1;
                            end if;
                        end if;		
                    end if;

                when s12_g1_1 =>
                    data1_rd(19) 		<= q_sig(79 downto 0);
                    state 				<=	s12_g3;

                when s12_g2=>
                    if (ready_gc = '1') then
                        select_gc		<=	'0';
                        state			<=	s12_g3;
                        data1_rd(19)		<=	data_gc_out(79 downto 0);
                    end if;
                when s12_g3=>
                    if isand = '1' then
                        if(addr_2v_reg(19)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_reg(19);
                            state			<=	s12_g4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_reg(19)(16 downto 1);
                            state 			<=	s12_g3_1;
                        end if;
                    elsif isxor = '1' then
                        if(addr_2v_xor_reg(19)(0) = '0') then
                            select_gc		<=	'1';
                            write_gc		<=	'0';
                            addr_gc			<=	addr_2v_xor_reg(19);
                            state			<=	s12_g4;
                        else
                            wren_sig 		<=	'0';
                            address_sig		<=	addr_2v_xor_reg(19)(16 downto 1);
                            state 			<=	s12_g3_1;
                        end if;
                    end if;

                when s12_g3_1=>
                    data2_rd(19)				<=	q_sig(79 downto 0);
                    if(gc_and_en_reg(19) = '1') then
                        read_in(19)			<=	'1';
                    end if;
                    state 				<= s13;

                when s12_g4=>
                    if(ready_gc = '1') then
                        data2_rd(19)			<=	data_gc_out(79 downto 0);
                        select_gc			<=	'0';
                        read_in(19)			<=	'1';
                        state			<=	s13;
                    end if;
            --               

            --	
                when s13=>
                    if (gc_done(0) = '1' or gc_xor_en_reg(0) = '1') then
                        if(isand = '1') then
                            if(addr_3v_reg(0)(0) = '0') then 
                                addr_gc			<=	addr_3v_reg(0);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(0) & ZERO48BIT & cyp_and0_3(0) & ZERO48BIT & cyp_and0_2(0) & ZERO48BIT & gc_res(0);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s14;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(0)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(0);
                                state			<=	s15;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(0)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(0);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(0) xor data2_rd(0));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s14;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(0)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(0) xor data2_rd(0));
                                state			<=	s15;
                            end if;
                        end if;
                    end if;
                    read_in_cl22: for i in 0 to GATE_NUM-1 loop
                        read_in(i)			<=	'0';
                    end loop;

                when s14=>
                    if ready_gc = '1' then
                        state 			<= s15;
                        select_gc		<=	'0';
                        write_gc		<=	'0';
                    end if;
                when s15=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(0)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(0) <= '1';
                --if(gc_and_en_reg(0) = '1') then
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);	
                --end if;
                --if(gc_xor_en_reg(0) = '1') then
                --	flag_xor_done		<=	'1';
                --else
                --	flag_xor_done		<=	'0';
                --end if;
                    if (gc_and_en_reg = "00000000000000000001" or gc_xor_en_reg = "00000000000000000001") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s16;
                    end if;
            --
            --				
                when s16=>
                    if (gc_done(1) = '1' or gc_xor_en_reg(1) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(1)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(1);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(1) & ZERO48BIT & cyp_and0_3(1) & ZERO48BIT & cyp_and0_2(1) & ZERO48BIT & gc_res(1);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s17;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(1)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(1);
                                state			<=	s18;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(1)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(1);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(1) xor data2_rd(1));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s17;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(1)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(1) xor data2_rd(1));
                                state			<=	s18;
                            end if;
                        end if;
                    end if;

                when s17=>
                    if ready_gc = '1' then
                        state <= s18;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                    end if;
                when s18=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(1)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(1) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000000000011" or gc_xor_en_reg = "00000000000000000011") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s19;
                    end if;
            --				

            --				
                when s19=>
                    if (gc_done(2) = '1' or gc_xor_en_reg(2) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(1)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(1);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(2) & ZERO48BIT & cyp_and0_3(2) & ZERO48BIT & cyp_and0_2(2) & ZERO48BIT & gc_res(2);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s20;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(2)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(2);
                                state			<=	s21;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(2)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(2);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(2) xor data2_rd(2));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s20;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(2)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(2) xor data2_rd(2));
                                state			<=	s21;
                            end if;
                        end if;
                    end if;
                when s20=>
                    if ready_gc = '1' then
                    --read_in(2)	<=	'0';
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                        state <= s21;
                    end if;
                when s21=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(2)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(2) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if(gc_and_en_reg = "00000000000000000111" or gc_xor_en_reg = "00000000000000000111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_01;
                    end if;
            --					
                when s21_01=>

                    if (gc_done(3) = '1' or gc_xor_en_reg(3) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(3)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(3);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(3) & ZERO48BIT & cyp_and0_3(3) & ZERO48BIT & cyp_and0_2(3) & ZERO48BIT & gc_res(3);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_02;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(3)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(3);
                                state			<=	s21_03;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(3)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(3);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(3) xor data2_rd(3));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_02;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(3)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(3) xor data2_rd(3));
                                state			<=	s21_03;
                            end if;
                        end if;
                    end if;

                when s21_02=>
                    if ready_gc = '1' then
                        state <= s21_03;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(3)	<=	'0';
                    end if;
                when s21_03=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(3)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(3) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000000001111" or gc_xor_en_reg = "00000000000000001111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_11;
                    end if;
            --
            --					
                when s21_11=>
                    if (gc_done(4) = '1' or gc_xor_en_reg(4) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(4)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(4);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(4) & ZERO48BIT & cyp_and0_3(4) & ZERO48BIT & cyp_and0_2(4) & ZERO48BIT & gc_res(4);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_12;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(4)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(4);
                                state			<=	s21_13;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(4)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(4);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(4) xor data2_rd(4));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_12;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(4)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(4) xor data2_rd(4));
                                state			<=	s21_13;
                            end if;
                        end if;
                    end if;
                when s21_12=>
                    if ready_gc = '1' then
                        state <= s21_13;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(4)	<=	'0';
                    end if;
                when s21_13=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(4)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(4) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000000011111" or gc_xor_en_reg = "00000000000000011111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_21;
                    end if;

            --					
                when s21_21=>
                    if (gc_done(5) = '1' or gc_xor_en_reg(5) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(5)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(5);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(5) & ZERO48BIT & cyp_and0_3(5) & ZERO48BIT & cyp_and0_2(5) & ZERO48BIT & gc_res(5);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_22;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(5)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(5);
                                state			<=	s21_23;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(5)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(5);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(5) xor data2_rd(5));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_22;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(5)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(5) xor data2_rd(5));
                                state			<=	s21_23;
                            end if;
                        end if;
                    end if;
                when s21_22=>
                    if ready_gc = '1' then
                        state <= s21_23;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(5)	<=	'0';
                    end if;
                when s21_23=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(5)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(5) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000000111111" or gc_xor_en_reg = "00000000000000111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_31;
                    end if;

            --					
                when s21_31=>
                    if (gc_done(6) = '1' or gc_xor_en_reg(6) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(6)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(6);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(6) & ZERO48BIT & cyp_and0_3(6) & ZERO48BIT & cyp_and0_2(6) & ZERO48BIT & gc_res(6);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_32;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(6)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(6);
                                state			<=	s21_33;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(6)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(6);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(6) xor data2_rd(6));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_32;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(6)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(6) xor data2_rd(6));
                                state			<=	s21_33;
                            end if;
                        end if;
                    end if;
                when s21_32=>
                    if ready_gc = '1' then
                        state <= s21_33;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(6)	<=	'0';
                    end if;
                when s21_33=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(6)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(6) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000001111111" or gc_xor_en_reg = "00000000000001111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_41;
                    end if;				
            --					
                when s21_41=>
                    if (gc_done(7) = '1' or gc_xor_en_reg(7) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(7)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(7);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(7) & ZERO48BIT & cyp_and0_3(7) & ZERO48BIT & cyp_and0_2(7) & ZERO48BIT & gc_res(7);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_42;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(7)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(7);
                                state			<=	s21_43;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(7)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(7);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(7) xor data2_rd(7));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_42;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(7)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(7) xor data2_rd(7));
                                state			<=	s21_43;
                            end if;
                        end if;
                    end if;
                when s21_42=>
                    if ready_gc = '1' then
                        state <= s21_43;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(7)	<=	'0';
                    end if;
                when s21_43=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(7)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(7) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000011111111" or gc_xor_en_reg = "00000000000011111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_51;
                    end if;
            --					
                when s21_51=>
                    if (gc_done(8) = '1' or gc_xor_en_reg(8) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(8)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(8);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(8) & ZERO48BIT & cyp_and0_3(8) & ZERO48BIT & cyp_and0_2(8) & ZERO48BIT & gc_res(8);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_52;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(8)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(8);
                                state			<=	s21_53;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(8)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(8);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(8) xor data2_rd(8));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_52;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(8)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(8) xor data2_rd(8));
                                state			<=	s21_53;
                            end if;
                        end if;
                    end if;
                when s21_52=>
                    if ready_gc = '1' then
                        state <= s21_53;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(8)	<=	'0';
                    end if;
                when s21_53=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(8)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(8) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000000111111111" or gc_xor_en_reg = "00000000000111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_61;
                    end if;
            --					
                when s21_61=>
                    if (gc_done(9) = '1' or gc_xor_en_reg(9) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(9)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(9);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(9) & ZERO48BIT & cyp_and0_3(9) & ZERO48BIT & cyp_and0_2(9) & ZERO48BIT & gc_res(9);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_62;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(9)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(9);
                                state			<=	s21_63;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(9)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(9);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(9) xor data2_rd(9));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_62;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(9)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(9) xor data2_rd(9));
                                state			<=	s21_63;
                            end if;
                        end if;
                    end if;
                when s21_62=>
                    if ready_gc = '1' then
                        state <= s21_63;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(9)	<=	'0';
                    end if;
                when s21_63=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(9)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(9) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if(gc_and_en_reg = "00000000001111111111" or gc_xor_en_reg = "00000000001111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_71;
                    end if;



            --					
                when s21_71=>
                    if (gc_done(10) = '1' or gc_xor_en_reg(10) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(10)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(10);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(10) & ZERO48BIT & cyp_and0_3(10) & ZERO48BIT & cyp_and0_2(10) & ZERO48BIT & gc_res(10);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_72;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(10)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(10);
                                state			<=	s21_73;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(10)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(10);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(10) xor data2_rd(10));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_72;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(10)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(10) xor data2_rd(10));
                                state			<=	s21_73;
                            end if;
                        end if;
                    end if;
                when s21_72=>
                    if ready_gc = '1' then
                        state <= s21_73;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(10)	<=	'0';
                    end if;
                when s21_73=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(10)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(10) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000011111111111" or gc_xor_en_reg = "00000000011111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_81;
                    end if;

            --					
                when s21_81=>
                    if (gc_done(11) = '1' or gc_xor_en_reg(11) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(11)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(11);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(11) & ZERO48BIT & cyp_and0_3(11) & ZERO48BIT & cyp_and0_2(11) & ZERO48BIT & gc_res(11);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_82;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(11)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(11);
                                state			<=	s21_83;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(11)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(11);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(11) xor data2_rd(11));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_82;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(11)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(11) xor data2_rd(11));
                                state			<=	s21_83;
                            end if;
                        end if;
                    end if;
                when s21_82=>
                    if ready_gc = '1' then
                        state <= s21_83;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(11)	<=	'0';
                    end if;
                when s21_83=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(11)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(11) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000000111111111111" or gc_xor_en_reg = "00000000111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_91;
                    end if;

            --					
                when s21_91=>
                    if (gc_done(12) = '1' or gc_xor_en_reg(12) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(12)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(12);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(12) & ZERO48BIT & cyp_and0_3(12) & ZERO48BIT & cyp_and0_2(12) & ZERO48BIT & gc_res(12);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_92;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(12)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(12);
                                state			<=	s21_93;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(12)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(12);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(12) xor data2_rd(12));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_92;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(12)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(12) xor data2_rd(12));
                                state			<=	s21_93;
                            end if;
                        end if;
                    end if;
                when s21_92=>
                    if ready_gc = '1' then
                        state <= s21_93;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(12)	<=	'0';
                    end if;
                when s21_93=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(12)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(12) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000001111111111111" or gc_xor_en_reg = "00000001111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_a1;
                    end if;

            --					
                when s21_a1=>
                    if (gc_done(13) = '1' or gc_xor_en_reg(13) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(13)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(13);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(13) & ZERO48BIT & cyp_and0_3(13) & ZERO48BIT & cyp_and0_2(13) & ZERO48BIT & gc_res(13);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_a2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(13)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(13);
                                state			<=	s21_a3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(13)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(13);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(13) xor data2_rd(13));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_a2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(13)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(13) xor data2_rd(13));
                                state			<=	s21_a3;
                            end if;
                        end if;
                    end if;
                when s21_a2=>
                    if ready_gc = '1' then
                        state <= s21_a3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(13)	<=	'0';
                    end if;
                when s21_a3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(13)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(13) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000011111111111111" or gc_xor_en_reg = "00000011111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_b1;
                    end if;


            --					
                when s21_b1=>
                    if (gc_done(14) = '1' or gc_xor_en_reg(14) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(14)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(14);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(14) & ZERO48BIT & cyp_and0_3(14) & ZERO48BIT & cyp_and0_2(14) & ZERO48BIT & gc_res(14);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_b2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(14)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(14);
                                state			<=	s21_b3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(14)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(14);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(14) xor data2_rd(14));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_b2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(14)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(14) xor data2_rd(14));
                                state			<=	s21_b3;
                            end if;
                        end if;
                    end if;
                when s21_b2=>
                    if ready_gc = '1' then
                        state <= s21_b3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(14)	<=	'0';
                    end if;
                when s21_b3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(14)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(14) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00000111111111111111" or gc_xor_en_reg = "00000111111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_c1;
                    end if;

            --					
                when s21_c1=>
                    if (gc_done(15) = '1' or gc_xor_en_reg(15) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(15)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(15);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(15) & ZERO48BIT & cyp_and0_3(15) & ZERO48BIT & cyp_and0_2(15) & ZERO48BIT & gc_res(15);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_c2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(15)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(15);
                                state			<=	s21_c3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(15)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(15);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(15) xor data2_rd(15));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_c2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(15)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(15) xor data2_rd(15));
                                state			<=	s21_c3;
                            end if;
                        end if;
                    end if;
                when s21_c2=>
                    if ready_gc = '1' then
                        state <= s21_c3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(15)	<=	'0';
                    end if;
                when s21_c3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(15)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(15) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00001111111111111111" or gc_xor_en_reg = "00001111111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_d1;
                    end if;

            --					
                when s21_d1=>
                    if (gc_done(16) = '1' or gc_xor_en_reg(16) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(16)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(16);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(16) & ZERO48BIT & cyp_and0_3(16) & ZERO48BIT & cyp_and0_2(16) & ZERO48BIT & gc_res(16);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_d2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(16)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(16);
                                state			<=	s21_d3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(16)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(16);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(16) xor data2_rd(16));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_d2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(16)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(16) xor data2_rd(16));
                                state			<=	s21_d3;
                            end if;
                        end if;
                    end if;
                when s21_d2=>
                    if ready_gc = '1' then
                        state <= s21_d3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(16)	<=	'0';
                    end if;
                when s21_d3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(16)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(16) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00011111111111111111" or gc_xor_en_reg = "00011111111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_e1;
                    end if;

            --					
                when s21_e1=>
                    if (gc_done(17) = '1' or gc_xor_en_reg(17) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(17)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(17);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(17) & ZERO48BIT & cyp_and0_3(17) & ZERO48BIT & cyp_and0_2(17) & ZERO48BIT & gc_res(17);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_e2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(17)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(17);
                                state			<=	s21_e3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(17)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(17);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(17) xor data2_rd(17));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_e2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(17)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(17) xor data2_rd(17));
                                state			<=	s21_e3;
                            end if;
                        end if;
                    end if;
                when s21_e2=>
                    if ready_gc = '1' then
                        state <= s21_e3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(17)	<=	'0';
                    end if;
                when s21_e3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(17)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(17) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "00111111111111111111" or gc_xor_en_reg = "00111111111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_f1;
                    end if;

            --					
                when s21_f1=>
                    if (gc_done(18) = '1' or gc_xor_en_reg(18) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(18)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(18);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(18) & ZERO48BIT & cyp_and0_3(18) & ZERO48BIT & cyp_and0_2(18) & ZERO48BIT & gc_res(18);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_f2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(18)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(18);
                                state			<=	s21_f3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(18)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(18);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(18) xor data2_rd(18));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_f2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(18)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(18) xor data2_rd(18));
                                state			<=	s21_f3;
                            end if;
                        end if;
                    end if;
                when s21_f2=>
                    if ready_gc = '1' then
                        state <= s21_f3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(18)	<=	'0';
                    end if;
                when s21_f3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(18)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(18) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    if (gc_and_en_reg = "01111111111111111111" or gc_xor_en_reg = "01111111111111111111") then
                        state <= s0;
                        reg_clr <= '1';
                    else
                        state <= s21_g1;
                    end if;

            --					
                when s21_g1=>
                    if (gc_done(19) = '1' or gc_xor_en_reg(19) = '1') then
                        if(isand = '1') then
                            if addr_3v_reg(19)(0) = '0' then 
                                addr_gc			<=	addr_3v_reg(19);
                                data_gc_in		<=	ZERO48BIT & cyp_and0_4(19) & ZERO48BIT & cyp_and0_3(19) & ZERO48BIT & cyp_and0_2(19) & ZERO48BIT & gc_res(19);
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_g2;
                            else		
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(19)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & gc_res(19);
                                state			<=	s21_g3;
                            end if;
                        elsif isxor = '1' then
                            if addr_3v_xor_reg(19)(0) = '0' then
                                addr_gc			<=	addr_3v_xor_reg(19);
                                data_gc_in		<=	(ZERO432BIT) & (data1_rd(19) xor data2_rd(19));
                                select_gc		<=	'1';
                                write_gc		<=	'1';
                                state			<=	s21_g2;
                            else
                                wren_sig 		<=	'1';
                                address_sig		<=	addr_3v_reg(19)(16 downto 1);
                                data_sig		<=	"0000000000000000000000000000" & (data1_rd(19) xor data2_rd(19));
                                state			<=	s21_g3;
                            end if;
                        end if;
                    end if;
                when s21_g2=>
                    if ready_gc = '1' then
                        state <= s21_g3;
                        select_gc	<=	'0';
                        write_gc		<=	'0';
                --read_in(19)	<=	'0';
                    end if;
                when s21_g3=>
                    select_gc	<= '0';
                    addr_gc		<= (others => '0');
                    write_gc		<=	'0';
                    gc_clrn(19)		<=	'0';
                    data_gc_in	<=	(others => '0');
                    ok_to_wr(19) <= '1';
                    layer_cnt <= std_logic_vector(unsigned(layer_cnt)+1);
                    state <= s0;
                    reg_clr <= '1';
                    wren_sig <=	'0';


            end case;

        end if;
    end process;


    comp_done_proc: process(lclk)
    begin
        if(rising_edge(lclk)) then
            if(clrn = '0') then
                comp_done_reg <= '0';
            elsif(layer_num_reg = layer_cnt and layer_num_reg /= "00000000000000000000000000000000") then
                comp_done_reg <= '1';
            else
                comp_done_reg <= '0';
            end if;
        end if;
    end process;

 -- comp_done_xor_proc: process(lclk)
 -- begin
 -- if(rising_edge(lclk)) then
 -- if(clrn = '0') then
 -- comp_done_xor_reg <= '0';
 -- elsif(flag_xor_done = '1') then
 -- comp_done_xor_reg <= '1';
 -- else
 -- comp_done_xor_reg <= '0';
 -- end if;
 -- end if;
 -- end process;



    gc_done_and <= '1' when gc_done = ALLONE else '0';
    comp_done <= comp_done_reg;

    r_input <= r(2)(15 downto 0) & r(1) & r(0);
    gc_be			<=	(others => '0');

    and_id: process(and_gt_id_reg)
    begin
        for i in 0 to GATE_NUM - 1 loop
            and_id_input(i) <= and_gt_id_reg(2*i+1) & and_gt_id_reg(2*i);
        end loop;
    end process;

END  gc_comp_arch;








