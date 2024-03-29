

--------------------------------------------------------------------------------------
-- Gidel Copyright � 1993-2015  
-- Include file dma_rdif. Generated by Gidel  ProcWizard Application  version 9.5.0.0
-- dma_rdif is the bus interface for ****  device (IC) 1 ****
-- This file may only be used for initialization and usage of Gidel PROC boards.
-- Using this file, or any other related files, for any other purpose, is prohibited .
-- No other licenses are provided herein.

-- Created  Sat Aug 12 20:18:15 2017

-------------------------------------------------------------------------------------





  FUNCTION  dma_rdif
 (
    clk,                                                    -- local bus clock
    clrn,                                                   -- Global reset signal. Active low
    blast,                    
    ads,                      
    lw_r_i,                   
    wait_l,                   
    ad_i[255..0],             
    mem_data[255..0],         
    mem_ready,                                              -- assert this signal high when memory data is valid
    term,                                                   -- assert this signal high to enable burst mode
    comp_done,                
    rbf_version[7..0],                                      -- RBF_Info[7..0]
    almost_full_wr,                                         -- status_wr[1]
    empty_wr,                                               -- status_wr[2]
    almost_empty_rd,                                        -- status_rd[0]
    almost_full_rd,                                         -- status_rd[1]
    empty_rd,                                               -- status_rd[2]
    id2,                      
    id1,                      
    id0                       
 )
  RETURNS
 (
    blast_o,                  
    lw_r,                     
    bterm,                    
    ready,                    
    addr[31..0],                                            -- local bus address
    ad_o[255..0],             
    ad[255..0],               
    sel_mp_rd                 
 );
